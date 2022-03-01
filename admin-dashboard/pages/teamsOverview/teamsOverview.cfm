
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->

<cfoutput>

<!--- CFQuery --->
<cfquery name="getTeam" datasource="roundleague">
	SELECT teamID, t.STATUS, teamName, t.registerDate, t.divisionID, t.seasonID, p.firstName, p.lastName, d.DivisionName, s.SeasonName
	FROM teams t
	LEFT JOIN players p ON p.PlayerID = t.captainPlayerID
	LEFT JOIN divisions d ON d.divisionID = t.DivisionID
	LEFT JOIN seasons s ON s.seasonID = t.seasonID 
	ORDER BY STATUS
</cfquery>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Teams Overview</h3>

        <!--- Content Here --->
    <table id="teamsOverviewTable" class="display" style="width:100%">
            <thead>
                <tr>
                    <th>Status</th>
                    <th>TeamID</th>
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
                  <td data-label="Status">#getTeam.status#</td>
                  <td data-label="Name">#getTeam.teamID#</td>
                  <td data-label="Team">#getTeam.teamname#</td>
                  <td data-label="Captain">#getTeam.firstName# #getTeam.lastName#</td>
                  <td data-label="Register Date">#DateFormat(getTeam.RegisterDate, "mm/dd/yyyy")#</td>
                  <td data-label="Current Division">#getTeam.divisionName#</td>
                  <td data-label="Current Season">#getTeam.seasonName#</td>
                </tr>
              </cfloop>
            </tbody>
    </table>
  </div>
</div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/teamsOverview/teamsOverview.js"></script>
