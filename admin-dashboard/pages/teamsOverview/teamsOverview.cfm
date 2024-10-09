
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->

<cfoutput>

<!--- CFQuery --->
<cfquery name="getTeam" datasource="roundleague">
	SELECT *
	FROM pending_teams
	WHERE status = 'Pending'
	ORDER BY STATUS	
</cfquery>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Pending Teams Overview</h3>

        <!--- Content Here --->
        <form name="teamsOverviewForm" method="POST">
		    <table id="teamsOverviewTable" class="display" style="width:100%">
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
					        <tr>
					            <td data-label="Team">#getTeam.teamName#</td>
					            <td data-label="Division">#getTeam.selectedDivision#</td>
					            <td data-label="Register Date">#DateFormat(getTeam.dateAdded, "mm/dd/yyyy")#</td>
					            <td data-label="Captain">#getTeam.captainFirstName# #getTeam.captainLastName#</td>
					            <td data-label="Age">#getTeam.age#</td>
					            <td data-label="Email">#getTeam.email#</td>
					            <td data-label="Phone Number">#getTeam.phoneNumber#</td>
					            <td data-label="Highest Level">#getTeam.highestLevel#</td>
					            <td data-label="Day Preference">#getTeam.dayPreference#</td>
					            <td data-label="Primary Time">#getTeam.primaryTimePref#</td>
					            <td data-label="Secondary Time">#getTeam.secondaryTimePref#</td>
					            <td data-label="Player Count Estimate">#getTeam.playerCountEstimate#</td>
					            <td data-label="Approval Status">
					                <a href="addTeam.cfm"><input type="button" class="btn btn-outline-danger btn-round addTeam" value="Approve Team" name="addTeam"></a>
					            </td>
					        </tr>
					    </cfloop>
		            </tbody>
		    </table>
		</form>
  </div>
</div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/teamsOverview/teamsOverview.js"></script>
