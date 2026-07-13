
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->
<link href="teamsOverview.css?v=1.0" rel="stylesheet">

<cfoutput>

<!--- Active Teams --->
<cfquery name="getTeam" datasource="roundleague">
	SELECT teamID, t.STATUS, teamName, t.registerDate, p.firstName, p.lastName, d.DivisionName, s.SeasonName
	FROM teams t
	LEFT JOIN players p ON p.PlayerID = t.captainPlayerID
	LEFT JOIN divisions d ON d.divisionID = t.DivisionID
	LEFT JOIN seasons s ON s.seasonID = t.seasonID
	WHERE t.status = 'Active'
	ORDER BY teamName
</cfquery>

<!--- Pending Teams (from the public registration form) --->
<cfquery name="getPendingTeams" datasource="roundleague">
	SELECT pending_teamsID, teamName, selectedDivision, status, captainFirstName, captainLastName,
	       allPlayersOver18, phoneNumber, highestLevel, playerCountEstimate, vaccinatedCount,
	       dayPreference, referralSource, referralOther, dateAdded
	FROM pending_teams
	ORDER BY dateAdded DESC
</cfquery>

<!--- Divisions for the current season, for the Approve modal --->
<cfquery name="getDivisions" datasource="roundleague">
	SELECT DivisionID, DivisionName
	FROM Divisions
	WHERE SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.CurrentSeasonID#">
</cfquery>

<cfquery name="getCurrentSeason" datasource="roundleague">
	SELECT SeasonID, SeasonName
	FROM Seasons
	WHERE SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.CurrentSeasonID#">
</cfquery>

<!--- Approve Pending Team Modal --->
<div class="modal fade" id="approveTeamModal" tabindex="-1" role="dialog" aria-labelledby="approveTeamModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="approveTeamModalLabel">Approve Team</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">x</span>
        </button>
      </div>
      <div class="modal-body">
        <p>Approving <strong><span id="approveTeamName"></span></strong></p>
        <div class="form-group">
          <label>Season</label>
          <p>#getCurrentSeason.SeasonName#</p>
          <input type="hidden" id="approveSeasonID" value="#session.CurrentSeasonID#">
        </div>
        <div class="form-group">
          <label>Assign Division</label>
          <select id="approveDivisionSelect" class="form-control">
            <option value="">-- Select Division --</option>
            <cfloop query="getDivisions">
              <option value="#getDivisions.DivisionID#">#getDivisions.DivisionName#</option>
            </cfloop>
          </select>
        </div>
        <div class="form-group">
          <label>Captain may be an existing player</label>
          <div id="captainMatchLoading">Checking for existing player records...</div>
          <div id="captainMatchResults" style="display:none;"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default btn-link" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-outline-danger btn-round" id="confirmApproveBtn">Approve</button>
      </div>
    </div>
  </div>
</div>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Teams Overview</h3>

    <ul class="nav nav-tabs" id="teamsOverviewTabs" role="tablist">
      <li class="nav-item">
        <a class="nav-link active" id="active-tab" data-toggle="tab" href="##activeTeamsPane" role="tab">Active Teams</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" id="pending-tab" data-toggle="tab" href="##pendingTeamsPane" role="tab">
          Pending Teams
          <cfif getPendingTeams.recordCount GT 0>
            <span class="badge badge-danger">#getPendingTeams.recordCount#</span>
          </cfif>
        </a>
      </li>
    </ul>

    <div class="tab-content">

      <!--- Active Teams Tab --->
      <div class="tab-pane fade show active" id="activeTeamsPane" role="tabpanel">
        <form name="teamsOverviewForm" method="POST">
		    <table id="teamsOverviewTable" class="display" style="width:100%">
		            <thead>
		                <tr>
		                    <th>Status</th>
		                    <th>Team</th>
		                    <th>Captain</th>
		                    <th>Register Date</th>
		                    <th>Current Division</th>
		                    <th>Current Season</th>
		                </tr>
		            </thead>
		            <tbody>
		              <cfloop query="getTeam">
		                <tr>
		                  <td data-label="Status">
		            		<select name="status" class="statusSelect" data-value="#getTeam.teamID#">
		            			<option value=""></option>
		            			<option value="Active" <cfif getTeam.status EQ 'Active'>selected</cfif>>Active</option>
		            			<option value="Inactive" <cfif getTeam.status EQ 'Inactive'>selected</cfif>>Inactive</option>
		            		</select>
		                  </td>
		                  <td data-label="Team">#getTeam.teamname#</td>
		                  <td data-label="Captain">#getTeam.firstName# #getTeam.lastName#</td>
		                  <td data-label="Register Date">#DateFormat(getTeam.RegisterDate, "mm/dd/yyyy")#</td>
		                  <td data-label="Current Division">#getTeam.divisionName#</td>
		                  <td data-label="Current Season">#getTeam.seasonName#</td>
		                </tr>
		              </cfloop>
		            </tbody>
		    </table>
		    <a href="addTeam.cfm"><input type="button" class="btn btn-outline-danger btn-round addTeam" value="Add Team" name="addTeam"></a>
		</form>
      </div>

      <!--- Pending Teams Tab --->
      <div class="tab-pane fade" id="pendingTeamsPane" role="tabpanel">
        <table id="pendingTeamsTable" class="display" style="width:100%">
          <thead>
            <tr>
              <th>Team</th>
              <th>League</th>
              <th>Captain</th>
              <th>Over 18?</th>
              <th>Phone</th>
              <th>Experience</th>
              <th>Player Count</th>
              <th>Vaccinated</th>
              <th>Day Preference</th>
              <th>Referral</th>
              <th>Date Submitted</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <cfset experienceLabels = {
              "1": "1 - Recreational",
              "2": "2 - High School Varsity",
              "3": "3 - College",
              "4": "4 - D-1 University",
              "5": "5 - Professional"
            }>
            <cfloop query="getPendingTeams">
              <tr>
                <td data-label="Team">#getPendingTeams.teamName#</td>
                <td data-label="League">#getPendingTeams.selectedDivision#</td>
                <td data-label="Captain">#getPendingTeams.captainFirstName# #getPendingTeams.captainLastName#</td>
                <td data-label="Over 18?">#getPendingTeams.allPlayersOver18#</td>
                <td data-label="Phone">#getPendingTeams.phoneNumber#</td>
                <td data-label="Experience">#structKeyExists(experienceLabels, getPendingTeams.highestLevel) ? experienceLabels[getPendingTeams.highestLevel] : getPendingTeams.highestLevel#</td>
                <td data-label="Player Count">#getPendingTeams.playerCountEstimate#</td>
                <td data-label="Vaccinated">#getPendingTeams.vaccinatedCount#</td>
                <td data-label="Day Preference">#getPendingTeams.dayPreference#</td>
                <td data-label="Referral"><cfif getPendingTeams.referralSource EQ 'Other'>#getPendingTeams.referralOther#<cfelse>#getPendingTeams.referralSource#</cfif></td>
                <td data-label="Date Submitted">#DateFormat(getPendingTeams.dateAdded, "mm/dd/yyyy")#</td>
                <td data-label="Actions">
                  <button type="button" class="btn btn-sm btn-outline-danger approveBtn"
                    data-toggle="modal" data-target="##approveTeamModal"
                    data-pending-id="#getPendingTeams.pending_teamsID#"
                    data-team-name="#getPendingTeams.teamName#"
                    data-captain-first="#getPendingTeams.captainFirstName#"
                    data-captain-last="#getPendingTeams.captainLastName#"
                    data-captain-phone="#getPendingTeams.phoneNumber#">Approve</button>
                  <button type="button" class="btn btn-sm btn-outline-secondary rejectBtn"
                    data-pending-id="#getPendingTeams.pending_teamsID#">Reject</button>
                </td>
              </tr>
            </cfloop>
          </tbody>
        </table>
      </div>

    </div>
  </div>
</div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/teamsOverview/teamsOverview.js?v=#DateDiff('s', CreateDate(1970,1,1), Now())#"></script>
