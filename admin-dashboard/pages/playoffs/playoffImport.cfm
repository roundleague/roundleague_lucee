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
  .bracket-select { min-width: 160px; font-size: 12px; }
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

<cfoutput>
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Playoff Schedule Import</h3>
      <p class="text-muted">Paste Rich's playoff schedule text, assign games to brackets, then import. This will <strong>replace all existing playoff data</strong> for the current season.</p>

      <cfif len(successMsg)>
        <div class="alert alert-success">#successMsg#</div>
      </cfif>
      <cfif len(errorMsg)>
        <div class="alert alert-danger">#errorMsg#</div>
      </cfif>

      <!--- Step 1: Paste --->
      <div class="card">
        <div class="card-header">
          <h5>Step 1 &mdash; Paste Schedule Text</h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <label>Paste Rich's playoff schedule, or upload a flyer image:</label>
            <div style="margin-bottom: 10px; display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
              <input type="file" id="playoffImageInput" accept="image/*" style="display:none;">
              <button type="button" class="btn btn-outline-secondary btn-sm" id="uploadPlayoffImageBtn">
                <i class="fa fa-image"></i> Upload Flyer Image
              </button>
              <input type="text" id="uploadBracketName" class="form-control" style="max-width:220px; display:inline-block;" placeholder="Bracket for this schedule (optional)">
              <span id="imageParseStatus" style="font-size:13px; color:##666;"></span>
            </div>
            <p class="text-muted small" style="margin-bottom:8px;">Fill in "Bracket for this schedule" before parsing/uploading to auto-assign every game below to that bracket instead of leaving them unassigned.</p>
            <textarea id="pasteArea" class="form-control" rows="14" placeholder="Paste the full playoff schedule here...

Example:
Sunday, April 12th (Semi-Finals)
10:30AM - (1) Emerald BC vs (4) Taste Ticklers
11:35AM - (2) CrossinOver Toddlers vs (3) Hustle Gang

Monday, April 13th (Championships)
6:30PM - East Division Championship"></textarea>
          </div>
          <button type="button" class="btn btn-outline-primary" onclick="parseScheduleAndAssignBracket()">
            Parse &amp; Preview
          </button>
        </div>
      </div>

      <!--- Brackets --->
      <div class="card">
        <div class="card-header">
          <h5>Brackets</h5>
        </div>
        <div class="card-body">
          <p class="text-muted small">Brackets are auto-detected from the pasted/extracted text, but you can add one manually here &mdash; before pasting, or for a bracket the parser doesn't pick up.</p>
          <div class="form-group" style="display:flex; gap:8px; align-items:center; max-width:420px;">
            <input type="text" id="newBracketNameInput" class="form-control" placeholder="e.g. Premiere Tier 1">
            <button type="button" class="btn btn-outline-primary btn-sm" id="addBracketBtn" style="white-space:nowrap;">Add Bracket</button>
          </div>
          <div id="manualBracketsList" style="margin-top:10px;"></div>
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
          <h5 style="margin:0;">Step 2 &mdash; Assign Games to Brackets</h5>
          <div>
            <span id="matchSummary" class="text-muted small"></span>
          </div>
        </div>
        <div class="card-body">
          <p class="text-muted small">
            Each game needs a bracket assignment. Games auto-assigned from division headers in the text &mdash; override as needed.
            <br>To add a new bracket name, type it into any bracket field and press Enter or select "New bracket…".
          </p>

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
                  <th>Bracket</th>
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
          <h5>Step 3 &mdash; Confirm Import</h5>
        </div>
        <div class="card-body">
          <div id="importSummary" class="mb-3"></div>
          <div class="alert alert-danger" style="font-size:13px;">
            <strong>Warning:</strong> This will permanently delete and replace only the bracket(s) named above, for Season #session.currentSeasonID#. Other brackets already imported for this season are left untouched.
          </div>
          <form method="POST" id="importForm">
            <input type="hidden" name="importData" id="formImportData">
            <button type="submit" class="btn btn-danger btn-round" id="importBtn">
              Import Playoffs
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
  var currentSeasonID = #session.currentSeasonID#;
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="playoffImport.js?v=<cfoutput>#GetFileInfo(ExpandPath('playoffImport.js')).lastModified.getTime()#</cfoutput>"></script>
