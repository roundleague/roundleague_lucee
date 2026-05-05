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

      <!--- Sync Summary Modal Trigger --->
      <button type="button" class="btn btn-outline-secondary btn-sm" onclick="openSyncModal()" style="margin-bottom: 15px;">
        <i class="nc-icon nc-bullet-list-67"></i> Division Sync Summary <span id="syncBadge" class="badge badge-secondary" style="font-size: 11px; margin-left: 6px;">0 / 0</span>
      </button>

      <!--- Sync Summary Modal --->
      <div class="sync-modal-overlay" id="syncModalOverlay" style="display: none;" onclick="closeSyncModalOverlay(event)">
        <div class="sync-modal">
          <div class="sync-modal-header">
            <h5><i class="nc-icon nc-bullet-list-67"></i> Division Sync Summary</h5>
            <button type="button" class="sync-modal-close" onclick="closeSyncModal()">&times;</button>
          </div>
          <div class="sync-modal-body">
            <p class="text-muted small">Tracks your progress as you sync each division's schedule. Data is saved in your browser for this season.</p>
            <div id="syncSummaryContent"></div>
          </div>
          <div class="sync-modal-footer">
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="clearSyncSummary()">Clear Summary</button>
            <button type="button" class="btn btn-outline-default btn-sm" onclick="closeSyncModal()">Close</button>
          </div>
        </div>
      </div>

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
            <label>Paste schedule from Rich's Google Sheet, or upload the schedule image:</label>
            <div style="margin-bottom: 10px;">
              <input type="file" id="scheduleImageInput" accept="image/*" style="display:none;">
              <button type="button" class="btn btn-outline-secondary btn-sm" id="uploadImageBtn">
                <i class="fa fa-image"></i> Upload Schedule Image
              </button>
              <span id="imageParseStatus" style="margin-left:10px; font-size:13px; color:##666;"></span>
            </div>
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
                <strong style="color:##c0392b;">DELETE EXISTING SCHEDULE FOR THIS DIVISION?</strong>
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
  var divisionsData = [
    <cfloop query="getDivisions">
      { id: #getDivisions.divisionID#, name: "#jsStringFormat(getDivisions.divisionName)#" }<cfif getDivisions.currentRow LT getDivisions.recordCount>,</cfif>
    </cfloop>
  ];
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="scheduleImport.js?v=<cfoutput>#GetFileInfo(ExpandPath('scheduleImport.js')).lastModified.getTime()#</cfoutput>"></script>
<script>
var extractedSchedule = null;

document.getElementById('uploadImageBtn').addEventListener('click', function() {
  document.getElementById('scheduleImageInput').click();
});

document.getElementById('scheduleImageInput').addEventListener('change', function() {
  var file = this.files[0];
  if (!file) return;

  var status = document.getElementById('imageParseStatus');
  status.textContent = 'Extracting schedule...';
  extractedSchedule = null;

  var divisionNames = divisionsData.map(function(d) { return d.name; });

  var reader = new FileReader();
  reader.onload = function(e) {
    var base64 = e.target.result.split(',')[1];

    fetch('/admin-dashboard/pages/scheduler/parseScheduleImage.cfm', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ image: base64, divisions: divisionNames })
    })
    .then(function(res) {
      return res.text().then(function(text) {
        console.log('parseScheduleImage raw response:', text);
        var start = text.indexOf('{');
        var end = text.lastIndexOf('}');
        if (start === -1 || end === -1) throw new Error('No JSON found in response: ' + text.substring(0, 300));
        try {
          return JSON.parse(text.substring(start, end + 1));
        } catch(e) {
          throw new Error('JSON parse failed: ' + e.message);
        }
      });
    })
    .then(function(data) {
      if (data.schedule) {
        extractedSchedule = data.schedule;
        var count = Object.keys(extractedSchedule).length;
        status.textContent = count + ' division(s) extracted - select a division to load its schedule.';
        console.log('Extracted division keys:', Object.keys(extractedSchedule));
        console.log('Available DB divisions:', divisionsData.map(function(d) { return d.name; }));
        populateFromExtracted();
      } else {
        status.textContent = 'Error: ' + (data.error || 'Unknown error');
        console.error('parseScheduleImage API error:', data);
      }
    })
    .catch(function(err) {
      status.textContent = 'Request failed: ' + err;
      console.error('parseScheduleImage error:', err);
    });
  };
  reader.readAsDataURL(file);
});

document.getElementById('divisionSelect').addEventListener('change', function() {
  populateFromExtracted();
});

function populateFromExtracted() {
  if (!extractedSchedule) return;
  var divisionSelect = document.getElementById('divisionSelect');
  if (!divisionSelect.value) return;
  var divisionName = divisionSelect.options[divisionSelect.selectedIndex].text;

  // Exact match first, then case-insensitive fallback
  var matchedKey = null;
  if (extractedSchedule[divisionName]) {
    matchedKey = divisionName;
  } else {
    var lower = divisionName.toLowerCase();
    Object.keys(extractedSchedule).forEach(function(key) {
      if (key.toLowerCase() === lower) matchedKey = key;
    });
  }

  if (matchedKey) {
    document.getElementById('pasteArea').value = extractedSchedule[matchedKey];
    document.getElementById('imageParseStatus').textContent = 'Loaded ' + divisionName + '.';
    parseScheduleData();
  } else {
    console.warn('No match for division "' + divisionName + '" in extracted keys:', Object.keys(extractedSchedule));
  }
}
</script>
