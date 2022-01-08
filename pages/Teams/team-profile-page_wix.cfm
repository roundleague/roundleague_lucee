<cfinclude template="/header_wix.cfm">

<!--- Page Specific CSS/JS Here --->

<cfquery name="getTeamData" datasource="roundleague">
	SELECT 
    p.playerID, 
    lastName, 
    firstName, 
    teamName, 
    position, 
    height, 
    weight, 
    hometown, 
    school, 
    s.seasonName, 
    d.divisionName,
    t.captainPlayerID,
    r.jersey
	FROM players p
	JOIN roster r ON r.PlayerID = p.playerID
	JOIN teams t ON t.teamId = r.teamID
	JOIN divisions d ON d.divisionID = r.DivisionID
	JOIN seasons s ON s.seasonID = t.seasonID
	WHERE r.seasonID = s.seasonID
	AND t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  <!--- AND p.PermissionToShare != 'No' --->
  GROUP BY lastName, firstName
</cfquery>

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center" style="padding-top: 20px">
      <div class="container">

        <!--- Content Here --->
        <h1>#getTeamData.teamName#</h1>

        <table>
          <caption>#getTeamData.seasonName# Roster</caption>
          <thead>
            <tr>
            	<td>Name</td>
              <td>Jersey</td>
            	<td>Position</td>
            	<td>Height</td>
            	<td>Weight</td>
            	<td>Hometown</td>
            	<td>School</td>
            </tr>
          </thead>
          <tbody>
          	<cfloop query="getTeamData">
	            <tr>
	            	<td>
                  <!--- <a href="Player_Profiles/player-profile-2.cfm?playerID=#playerID#">
                    #firstName# #lastName# <cfif getTeamData.captainPlayerID EQ getTeamData.playerID>(C)</cfif>
                  </a> --->
                  #firstName# #lastName# <cfif getTeamData.captainPlayerID EQ getTeamData.playerID>(C)</cfif>
                </td>
                <td>#Jersey#</td>
	            	<td>#Position#</td>
	            	<td>#Height#</td>
	            	<td>#Weight#</td>
	            	<td>#Hometown#</td>
	            	<td>#School#</td>
	            </tr>
        	</cfloop>
          </tbody>
        </table>
        
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer_wix.cfm">

