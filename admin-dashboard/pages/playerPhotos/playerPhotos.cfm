
<cfinclude template="/admin-dashboard/admin_header.cfm">

<cfoutput>
<!--- Page Specific CSS/JS Here --->
<link href="playerPhotos.css?v=1.0" rel="stylesheet">

<cfif isDefined("form.savePhotosButton")>
    <cfinclude template="playerPhotoUpload.cfm">
</cfif>

<!--- CFQuery --->
<cfquery name="getPlayers" datasource="roundleague">
  SELECT lastName, firstName, teamName, d.divisionName, r.jersey, p.instagram, p.phone, p.email, p.playerID, p.birthDate
  FROM players p
  JOIN roster r ON r.PlayerID = p.playerID
  JOIN teams t ON t.teamId = r.teamID
  JOIN divisions d ON d.divisionID = r.DivisionID
  WHERE r.seasonID = (SELECT s.seasonID From Seasons s Where s.Status = 'Active')
  AND t.Status = 'Active'
  ORDER BY teamName
</cfquery>

<!--- Path to player photos --->
<cfset path = expandPath("/assets/img/PlayerProfiles")>

<!-- End Navbar -->
<div class="content">
<div class="row">
  <div class="col-md-12">
    <h3 class="description">Player Photo Upload</h3>
      <form method="POST" enctype="multipart/form-data">
        <!--- Content Here --->
        <table id="playerLookupTable" class="display" style="width:100%">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>PlayerID</th>
                        <th>Team</th>
                        <th>Upload</th>
                    </tr>
                </thead>
                <tbody>
                  <cfloop query="getPlayers">
                    <cfset playerPath = path & "/#getPlayers.PlayerID#.jpg">
                    <tr>
                      <td data-label="Name">#getPlayers.firstName# #getPlayers.lastName# ###jersey#</td>
                      <td data-label="PlayerID">#getPlayers.PlayerID#</td>
                      <td data-label="Team">#getPlayers.teamname#</td>
                      <td data-label="Upload">
                          <cfif FileExists(playerPath)>
                            Photo already exists
                          <cfelse>
                            <input type="file" id="myFile" name="photo_player_#getPlayers.PlayerID#">
                            <input type="hidden" name="playerIDList" value="#getPlayers.playerID#">
                          </cfif>
                      </td>
                    </tr>
                  </cfloop>
                </tbody>
        </table>
        <input type="submit" class="btn btn-outline-danger btn-round savePhotosButton" value="Save" name="savePhotosButton">
      </form>
  </div>
</div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/admin-dashboard/pages/playerPhotos/playerPhotos.js"></script>
