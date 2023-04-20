
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->

<cfoutput>

<!--- CFQuery --->
<cfquery name="getTeam" datasource="roundleague">
	SELECT teamID, t.STATUS, teamName, t.registerDate, p.firstName, p.lastName, d.DivisionName, s.SeasonName
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
		            			<option value="Pending" <cfif getTeam.status EQ 'Pending'>selected</cfif>>Pending</option>
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
</div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/teamsOverview/teamsOverview.js"></script>
