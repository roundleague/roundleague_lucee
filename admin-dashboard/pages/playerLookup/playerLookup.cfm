
<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">

<cfoutput>

<!--- CFQuery --->
<cfquery name="getPlayers" datasource="roundleague">
  SELECT lastName, firstName, teamName, d.divisionName, r.jersey, p.instagram, p.phone, p.email, p.playerID
  FROM players p
  JOIN roster r ON r.PlayerID = p.playerID
  JOIN teams t ON t.teamId = r.teamID
  JOIN divisions d ON d.divisionID = r.DivisionID
  WHERE r.seasonID = (SELECT s.seasonID From Seasons s Where s.Status = 'Active')
  ORDER BY teamName
</cfquery>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Player Look Up</h3>

        <!--- Content Here --->
    <table id="playerLookupTable" class="display" style="width:100%">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>PlayerID</th>
                    <th>Team</th>
                    <th>Instagram</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Division</th>
                </tr>
            </thead>
            <tbody>
              <cfloop query="getPlayers">
                <tr>
                  <td data-label="Name">#getPlayers.firstName# #getPlayers.lastName# ###jersey#</td>
                  <td data-label="PlayerID">#getPlayers.PlayerID#</td>
                  <td data-label="Team">#getPlayers.teamname#</td>
                  <td data-label="Instagram">#getPlayers.instagram#</td>
                  <td data-label="Phone">#getPlayers.Phone#</td>
                  <td data-label="Email">#getPlayers.Email#</td>
                  <td data-label="Division">#getPlayers.DivisionName#</td>
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
<script src="/admin-dashboard/pages/playerLookup/playerLookup.js"></script>
