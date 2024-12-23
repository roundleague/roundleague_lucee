
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->
<!-- Toastr CSS -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css">

<cfoutput>

<!--- CFQuery --->
<cfquery name="getTeam" datasource="roundleague">
	SELECT *
	FROM pending_teams
	WHERE status = 'Pending'
	ORDER BY STATUS	
</cfquery>

<cfquery name="getActiveTeams" datasource="roundleague">
	SELECT teamID, t.STATUS, teamName, t.registerDate, p.firstName, p.lastName, d.DivisionName, s.SeasonName
	FROM teams t
	LEFT JOIN players p ON p.PlayerID = t.captainPlayerID
	LEFT JOIN divisions d ON d.divisionID = t.DivisionID
	LEFT JOIN seasons s ON s.seasonID = t.seasonID 
	ORDER BY STATUS
</cfquery>

<!--- Approve Team Modal --->
<div class="modal fade" id="approveTeam" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">x</span>
        </button>
      </div>
      <div class="modal-body"> 

        <form id="approveTeamForm" class="settings-form" method="POST">
          <div class="form-group">
            <label>Confirm Team Approval</label>
            <ul>
              <li>Team: <input type="text" readonly id="teamName" name="teamName"></li>
              <li>Division: <input type="text" readonly id="division" name="division"></li>
              <li>Level: <input type="text" readonly id="level" name="level"></li>
              <li>Day Preference: <input type="text" readonly id="dayPreference" name="dayPreference"></li>
              <li>Primary Time: <input type="text" readonly id="primaryTime" name="primaryTime"></li>
              <li>Secondary Time: <input type="text" readonly id="secondaryTime" name="secondaryTime"></li>
            </ul>
          </div>
        </form>

      </div>
      <div class="modal-footer">
        <div class="left-side">
          <button type="button" class="btn btn-default btn-link confirmTeamApproval" data-dismiss="modal">Confirm Team Approval</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Teams Overview</h3>

      <!-- Tab Menu -->
      <ul class="nav nav-tabs" id="teamsTab" role="tablist">
        <li class="nav-item">
          <a class="nav-link active" id="active-teams-tab" data-toggle="tab" href="##active-teams" role="tab" aria-controls="active-teams" aria-selected="true">Active</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" id="pending-teams-tab" data-toggle="tab" href="##pending-teams" role="tab" aria-controls="pending-teams" aria-selected="false">Pending</a>
        </li>
      </ul>

      <!-- Tab Content -->
      <div class="tab-content" id="teamsTabContent">
        <!-- Active Teams Tab -->
        <div class="tab-pane fade show active" id="active-teams" role="tabpanel" aria-labelledby="active-teams-tab">
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
		              <cfloop query="getActiveTeams">
		                <tr>
		                  <td data-label="Status">
		            		<select name="status" class="statusSelect" data-value="#getActiveTeams.teamID#">
		            			<option value=""></option>
		            			<option value="Active" <cfif getActiveTeams.status EQ 'Active'>selected</cfif>>Active</option>
		            			<option value="Pending" <cfif getActiveTeams.status EQ 'Pending'>selected</cfif>>Pending</option>
		            			<option value="Inactive" <cfif getActiveTeams.status EQ 'Inactive'>selected</cfif>>Inactive</option>
		            		</select>
		                  </td>
		                  <td data-label="Team">#getActiveTeams.teamname#</td>
		                  <td data-label="Captain">#getActiveTeams.firstName# #getActiveTeams.lastName#</td>
		                  <td data-label="Register Date">#DateFormat(getActiveTeams.RegisterDate, "mm/dd/yyyy")#</td>
		                  <td data-label="Current Division">#getActiveTeams.divisionName#</td>
		                  <td data-label="Current Season">#getActiveTeams.seasonName#</td>
		                </tr>
		              </cfloop>
		            </tbody>
		    </table>
		    <a href="addTeam.cfm"><input type="button" class="btn btn-outline-danger btn-round addTeam" value="Add Team" name="addTeam"></a>
		</form>
        </div>

        <!-- Pending Teams Tab -->
        <div class="tab-pane fade" id="pending-teams" role="tabpanel" aria-labelledby="pending-teams-tab">
          <!-- Pending Teams Content -->
          <form name="teamsOverviewForm" method="POST">
            <table id="pendingTeamsOverviewTable" class="display" style="width:100%">
              <thead>
                <tr>
                  <th>Team</th>
                  <th>Division</th>
                  <th>Register Date</th>
                  <th>Captain</th>
                  <th>Age</th>
                  <th>Email</th>
                  <th>Phone Number</th>
                  <th>Highest Level</th>
                  <th>Day Preference</th>
                  <th>Primary Time</th>
                  <th>Secondary Time</th>
                  <th>Player Count Estimate</th>
                  <th>Approval Status</th>
                </tr>
              </thead>
              <tbody>
                <cfloop query="getTeam">
                  <tr class="#getTeam.pending_teamsID#_teamID">
                    <td data-label="Team" data-value="#getTeam.teamName#">#getTeam.teamName#</td>
                    <td data-label="Division" data-value="#getTeam.teamName#">#getTeam.selectedDivision#</td>
                    <td data-label="Register Date">#DateFormat(getTeam.dateAdded, "mm/dd/yyyy")#</td>
                    <td data-label="Captain">#getTeam.captainFirstName# #getTeam.captainLastName#</td>
                    <td data-label="Age">#getTeam.age#</td>
                    <td data-label="Email">#getTeam.email#</td>
                    <td data-label="Phone Number">#getTeam.phoneNumber#</td>
                    <td data-label="Highest Level" data-value="#getTeam.highestLevel#">#getTeam.highestLevel#</td>
                    <td data-label="Day Preference" data-value="#getTeam.dayPreference#">#getTeam.dayPreference#</td>
                    <td data-label="Primary Time" data-value="#getTeam.primaryTimePref#">#getTeam.primaryTimePref#</td>
                    <td data-label="Secondary Time" data-value="#getTeam.secondaryTimePref#">#getTeam.secondaryTimePref#</td>
                    <td data-label="Player Count Estimate">#getTeam.playerCountEstimate#</td>
                    <td data-label="Approval Status">
                      <input type="button" class="btn btn-outline-danger btn-round clickOnTeam" value="Approve" name="addTeam" data-toggle="modal" data-target="##approveTeam"
                        data-team-name="#getTeam.teamName#"
                        data-division="#getTeam.selectedDivision#"
                        data-level="#getTeam.highestLevel#"
                        data-day-preference="#getTeam.dayPreference#"
                        data-primary-time="#getTeam.primaryTimePref#"
                        data-secondary-time="#getTeam.secondaryTimePref#"
                        data-pending-teams-id="#getTeam.pending_teamsID#">
                    </td>
                  </tr>
                </cfloop>
              </tbody>
            </table>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/teamsOverview/teamsOverview.js?v=1.1"></script>
<!-- Toastr JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>