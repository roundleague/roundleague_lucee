<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="scheduleImport.css?v=1.2" rel="stylesheet">

<cfparam name="toastMsg" default="">
<cfparam name="toastClass" default="">

<!--- Process Import --->
<cfif isDefined("form.importScheduleBtn")>
  <cfinclude template="processScheduleImport.cfm">
</cfif>

<!--- Get all divisions for current season --->
<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  WHERE SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  ORDER BY DivisionName
</cfquery>

<!--- Get all active teams for current season --->
<cfquery name="getAllTeams" datasource="roundleague">
  SELECT teamID, teamName, divisionID
  FROM teams
  WHERE status = 'Active'
  AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  ORDER BY teamName
</cfquery>

<!--- Get all inactive teams (any season) for reactivation checks --->
<cfquery name="getInactiveTeams" datasource="roundleague">
  SELECT teamID, teamName, divisionID, seasonID
  FROM teams
  WHERE status = 'Inactive'
  ORDER BY teamName
</cfquery>

<!--- Build team lookup JSON for JavaScript --->
<cfset teamLookup = {}>
<cfloop query="getAllTeams">
  <cfset teamLookup[lCase(trim(getAllTeams.teamName))] = {
    "teamID": getAllTeams.teamID,
    "teamName": getAllTeams.teamName,
    "divisionID": getAllTeams.divisionID
  }>
</cfloop>

<!--- Build inactive team lookup JSON for JavaScript --->
<cfset inactiveTeamLookup = {}>
<cfloop query="getInactiveTeams">
  <cfset inactiveTeamLookup[lCase(trim(getInactiveTeams.teamName))] = {
    "teamID": getInactiveTeams.teamID,
    "teamName": getInactiveTeams.teamName,
    "divisionID": getInactiveTeams.divisionID,
    "seasonID": getInactiveTeams.seasonID
  }>
</cfloop>

<cfoutput>
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Schedule Import</h3>
      <p>Paste schedule data directly from Rich's Google Sheet. The format should have week headers (e.g., "Week 1 - Monday, February 23rd") followed by game lines with time and teams.</p>
      
      <cfif len(toastMsg)>
        <div class="alert #toastClass#">#toastMsg#</div>
      </cfif>

      <!--- Step 1: Paste Data --->
      <div class="card">
        <div class="card-header">
          <h5>Step 1: Paste Schedule Data</h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <label for="divisionSelect">Select Division</label>
            <select id="divisionSelect" class="form-control" style="max-width: 300px;">
              <option value="">-- Select Division --</option>
              <cfloop query="getDivisions">
                <option value="#getDivisions.divisionID#">#getDivisions.divisionName#</option>
              </cfloop>
            </select>
          </div>
          
          <div class="form-group">
            <label>Paste schedule from Rich's Google Sheet</label>
            <textarea id="pasteArea" class="form-control" rows="12" placeholder="Paste your schedule data here...

Example format:
Week 1 - Monday, February 23rd	
6:15 PM	Thunder vs Lightning
7:20 PM	Blazers vs Heat
Week 2 - Monday, March 2nd	
6:15 PM	Lightning vs Blazers
7:20 PM	Heat vs Thunder"></textarea>
          </div>
          
          <button type="button" class="btn btn-outline-primary" onclick="parseScheduleData()">
            Parse & Preview
          </button>
        </div>
      </div>

      <!--- Available Teams Reference --->
      <div class="card">
        <div class="card-header">
          <h5>Available Teams in Database (<span id="teamCount">#getAllTeams.recordCount#</span>)</h5>
        </div>
        <div class="card-body">
          <div class="available-teams-list">
            <cfloop query="getAllTeams">
              <span class="team-tag">#getAllTeams.teamName#</span>
            </cfloop>
            <cfif getAllTeams.recordCount EQ 0>
              <p class="text-muted">No active teams found for this season. Add teams in the Divisions page first.</p>
            </cfif>
          </div>
        </div>
      </div>

      <!--- Team Diff/Sync Panel --->
      <div class="card" id="teamDiffCard" style="display: none;">
        <div class="card-header">
          <h5>Team Diff/Sync</h5>
        </div>
        <div class="card-body">
          <!--- Rename Suggestions --->
          <div id="renamesSection" style="display: none;" class="mb-3">
            <h6 class="text-info"><i class="nc-icon nc-tag-content"></i> Team Renames Detected</h6>
            <p class="text-muted small">These teams appear to have new names (format: "New Name (Old Name)").</p>
            <div id="renamesList" class="team-diff-list"></div>
          </div>
          <div class="row">
            <!--- New Teams (in schedule but not in DB) --->
            <div class="col-md-6">
              <h6 class="text-success"><i class="nc-icon nc-simple-add"></i> New Teams in Schedule</h6>
              <p class="text-muted small">These teams are in the schedule but not in your database.</p>
              <div id="newTeamsList" class="team-diff-list">
                <p class="text-muted">No new teams found.</p>
              </div>
            </div>
            <!--- Missing Teams (in DB but not in schedule) --->
            <div class="col-md-6">
              <h6 class="text-warning"><i class="nc-icon nc-simple-remove"></i> Teams Not in Schedule</h6>
              <p class="text-muted small">These teams are in your database but not in the pasted schedule.</p>
              <div id="missingTeamsList" class="team-diff-list">
                <p class="text-muted">All database teams found in schedule.</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!--- Step 2: Preview & Validation --->
      <div class="card" id="previewCard" style="display: none;">
        <div class="card-header">
          <h5>Step 2: Preview & Validation</h5>
        </div>
        <div class="card-body">
          <!--- Team Warnings --->
          <div id="teamWarnings" class="alert alert-warning" style="display: none;">
            <strong>Unknown Teams Found:</strong>
            <ul id="unknownTeamsList"></ul>
            <p class="mb-0">Use the "Team Diff/Sync" panel above to quick-add these teams.</p>
          </div>
          
          <!--- Preview Table --->
          <div class="table-responsive">
            <table class="table table-striped" id="previewTable">
              <thead>
                <tr>
                  <th>Row</th>
                  <th>Home Team</th>
                  <th>Away Team</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Week</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody id="previewBody">
              </tbody>
            </table>
          </div>
          
          <div id="importSummary" class="mt-3"></div>
        </div>
      </div>

      <!--- Step 3: Confirm Import --->
      <div class="card" id="confirmCard" style="display: none;">
        <div class="card-header">
          <h5>Step 3: Confirm Import</h5>
        </div>
        <div class="card-body">
          <form method="POST" id="importForm">
            <input type="hidden" name="importScheduleBtn" value="1">
            <input type="hidden" name="divisionID" id="formDivisionID">
            <input type="hidden" name="scheduleData" id="formScheduleData">
            
            <p><strong id="validGameCount">0</strong> games ready to import.</p>
            
            <div class="form-group">
              <label>
                <input type="checkbox" id="clearExisting" name="clearExisting" value="1" checked> 
                Clear existing schedule for this division before importing
              </label>
            </div>
            
            <button type="submit" class="btn btn-outline-danger btn-round" id="importBtn" disabled>
              Import Schedule
            </button>
          </form>
        </div>
      </div>

    </div>
  </div>
</div>

<!--- Pass team data to JavaScript --->
<script>
  var teamLookup = #serializeJSON(teamLookup)#;
  var inactiveTeamLookup = #serializeJSON(inactiveTeamLookup)#;
  var currentSeasonID = #session.currentSeasonID#;
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="scheduleImport.js?v=1.3"></script>
