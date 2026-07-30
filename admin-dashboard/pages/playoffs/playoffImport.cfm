<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/assets/css/toast.css" rel="stylesheet">
<style>
  .team-match { color: #4caf50; font-weight: 600; }
  .team-nomatch { color: #e53935; font-weight: 600; }
  .team-placeholder { color: #9e9e9e; font-style: italic; }
  .bracket-badge { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; color: #fff; margin-right: 4px; }
  .round-badge { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 11px; background: #607d8b; color: #fff; }
  .available-teams-list { display: flex; flex-wrap: wrap; gap: 6px; }
  .team-tag { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; padding: 2px 8px; border-radius: 10px; font-size: 12px; }
  #previewTable td, #previewTable th { vertical-align: middle; font-size: 13px; }
  .warning-row td { background: #fff8e1; }
</style>

<cfparam name="successMsg" default="">
<cfparam name="errorMsg" default="">

<cfif isDefined("form.importData")>
  <cftry>
    <cfinclude template="processPlayoffImport.cfm">
    <cfcatch type="any">
      <cfset errorMsg = "Import failed: #cfcatch.message#">
    </cfcatch>
  </cftry>
</cfif>

<cfquery name="getTeams" datasource="roundleague">
  SELECT teamID, teamName
  FROM teams
  WHERE status = 'Active'
  AND seasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
  ORDER BY teamName
</cfquery>

<cfset teamLookup = {}>
<cfloop query="getTeams">
  <cfset teamLookup[lCase(trim(getTeams.teamName))] = {
    "teamID": getTeams.teamID,
    "teamName": getTeams.teamName
  }>
</cfloop>

<cfquery name="getBrackets" datasource="roundleague">
  SELECT Playoffs_bracketID, Name
  FROM playoffs_bracket
  WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
  ORDER BY SortOrder, Name
</cfquery>

<cfquery name="getMaxRounds" datasource="roundleague">
  SELECT Playoffs_BracketID, MAX(BracketRoundID) AS maxRound
  FROM playoffs_schedule
  WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
  GROUP BY Playoffs_BracketID
</cfquery>

<cfset bracketMaxRound = {}>
<cfloop query="getMaxRounds">
  <cfset bracketMaxRound[getMaxRounds.Playoffs_BracketID] = getMaxRounds.maxRound>
</cfloop>

<cfoutput>
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Playoff Schedule Import</h3>
      <p class="text-muted">Upload (or paste) Rich's schedule image for one bracket, one round at a time. Games are added incrementally &mdash; other rounds/brackets are left untouched. These are added as manual/no-auto-advance brackets: StatsApp will save scores as usual, but nobody's slot gets auto-filled &mdash; Rich uploads the next round himself once he knows the matchups.</p>

      <cfif len(successMsg)>
        <div class="alert alert-success">#successMsg#</div>
      </cfif>
      <cfif len(errorMsg)>
        <div class="alert alert-danger">#errorMsg#</div>
      </cfif>

      <!--- Step 0: Bracket & Round --->
      <div class="card">
        <div class="card-header">
          <h5>Step 1 &mdash; Bracket &amp; Round</h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <label>Bracket</label>
            <select id="bracketSelect" class="form-control" style="max-width:320px;" onchange="onBracketSelectChange()">
              <cfloop query="getBrackets">
                <option value="#getBrackets.Playoffs_bracketID#">#htmlEditFormat(getBrackets.Name)#</option>
              </cfloop>
              <option value="__new__">+ New bracket&hellip;</option>
            </select>
          </div>
          <div class="form-group" id="newBracketRow" style="display:<cfif getBrackets.recordCount EQ 0>block<cfelse>none</cfif>;">
            <label>New Bracket Name</label>
            <input type="text" id="newBracketName" class="form-control" style="max-width:320px;" placeholder="e.g. Winners Bracket, East Division">
          </div>
          <div class="form-group">
            <label>Round Number</label>
            <input type="number" id="roundNumberInput" class="form-control" style="max-width:120px;" min="1" value="1">
            <small class="text-muted">Auto-filled to the next round for the selected bracket. Change it if you're re-targeting an earlier round.</small>
          </div>
        </div>
      </div>

      <!--- Step 1: Paste / Upload --->
      <div class="card">
        <div class="card-header">
          <h5>Step 2 &mdash; Paste or Upload Schedule</h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <label>Upload Schedule Image</label><br>
            <input type="file" accept="image/*" onchange="uploadPlayoffImage(this)">
            <div id="uploadStatus" class="text-muted small" style="margin-top:4px;"></div>
          </div>
          <div class="form-group">
            <label>...or paste the schedule text</label>
            <textarea id="pasteArea" class="form-control" rows="14" placeholder="Paste this round's schedule here...

Example:
Sunday, April 12th (Semi-Finals)
10:30AM - (1) Emerald BC vs (4) Taste Ticklers
11:35AM - (2) CrossinOver Toddlers vs (3) Hustle Gang"></textarea>
          </div>
          <button type="button" class="btn btn-outline-primary" onclick="parseSchedule()">
            Parse &amp; Preview
          </button>
        </div>
      </div>

      <!--- Available Teams --->
      <div class="card">
        <div class="card-header">
          <h5>Active Teams This Season (#getTeams.recordCount#)</h5>
        </div>
        <div class="card-body">
          <div class="available-teams-list">
            <cfloop query="getTeams">
              <span class="team-tag">#getTeams.teamName#</span>
            </cfloop>
            <cfif getTeams.recordCount EQ 0>
              <p class="text-muted">No active teams found for this season.</p>
            </cfif>
          </div>
        </div>
      </div>

      <!--- Step 2: Preview --->
      <div class="card" id="previewCard" style="display:none;">
        <div class="card-header" style="display:flex; align-items:center; justify-content:space-between;">
          <h5 style="margin:0;">Step 3 &mdash; Preview</h5>
          <div>
            <span id="matchSummary" class="text-muted small"></span>
          </div>
        </div>
        <div class="card-body">
          <div id="unknownTeamsAlert" class="alert alert-warning" style="display:none;">
            <strong>Unmatched teams</strong> &mdash; these names weren't found in the active roster:
            <span id="unknownTeamsList"></span>
          </div>

          <div class="table-responsive">
            <table class="table table-sm table-striped" id="previewTable">
              <thead>
                <tr>
                  <th>##</th>
                  <th>Round</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Home</th>
                  <th>Away</th>
                </tr>
              </thead>
              <tbody id="previewBody"></tbody>
            </table>
          </div>
        </div>
      </div>

      <!--- Step 3: Confirm --->
      <div class="card" id="confirmCard" style="display:none;">
        <div class="card-header">
          <h5>Step 4 &mdash; Confirm Import</h5>
        </div>
        <div class="card-body">
          <div id="importSummary" class="mb-3"></div>
          <div class="alert alert-info" style="font-size:13px;">
            Only the bracket &amp; round(s) shown above are affected. If any of those games already have a recorded score, the import will be blocked instead of overwriting results.
          </div>
          <form method="POST" id="importForm">
            <input type="hidden" name="importData" id="formImportData">
            <button type="submit" class="btn btn-primary btn-round" id="importBtn">
              Import
            </button>
            <button type="button" class="btn btn-default btn-round" onclick="resetImport()">
              Start Over
            </button>
          </form>
        </div>
      </div>

    </div>
  </div>
</div>

<script>
  var teamLookup = #serializeJSON(teamLookup)#;
  var bracketMaxRound = #serializeJSON(bracketMaxRound)#;
  var currentSeasonID = #session.currentSeasonID#;
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="playoffImport.js?v=<cfoutput>#GetFileInfo(ExpandPath('playoffImport.js')).lastModified.getTime()#</cfoutput>"></script>
