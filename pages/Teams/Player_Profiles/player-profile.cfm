<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/Player_Profiles/player-profile.css" rel="stylesheet" />
<link href="/pages/Teams/teams.css" rel="stylesheet" />

<cfquery name="getPlayerData" datasource="roundleague">
	SELECT lastName, firstName, position, height, weight, hometown, school
	FROM Players
	WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerStats" datasource="roundleague">
	SELECT *
	FROM playerstats p
	JOIN seasons s ON p.SeasonID = s.seasonID
	WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<div class="row">
		  <div class="column">
		    <div class="card">
		      <img src="/assets/img/PlayerProfiles/21.JPG" alt="Jane" style="width:100%">
		      <div class="container">
		        <h2>#getPlayerData.firstName# #getPlayerData.LastName#</h2>
		        #getPlayerData.position#<br>
		      </div>
		    </div>
		  </div>

	        <table>
	          <caption>Career Stats</caption>
	          <thead>
	            <tr>
	            	<td>Season</td>
	            	<td>Points</td>
	            	<td>Rebounds</td>
	            	<td>Assists</td>
	            	<td>Steals</td>
	            	<td>Blocks</td>
	            	<td>Turnovers</td>
	            </tr>
	          </thead>
	          <tbody>
	          	<cfloop query="getPlayerStats">
		            <tr>
		            	<td><span class="mobileHeaders">Season:</span> #getPlayerStats.SeasonName#</td>
		            	<td><span class="mobileHeaders">Points:</span> #getPlayerStats.Points#</td>
		            	<td><span class="mobileHeaders">Rebounds:</span> #getPlayerStats.Rebounds#</td>
		            	<td><span class="mobileHeaders">Assists:</span> #getPlayerStats.Assists#</td>
		            	<td><span class="mobileHeaders">Steals:</span> #getPlayerStats.Steals#</td>
		            	<td><span class="mobileHeaders">Blocks:</span> #getPlayerStats.Blocks#</td>
		            	<td><span class="mobileHeaders">Turnovers:</span> #getPlayerStats.Turnovers#</td>
		            </tr>
	        	</cfloop>
	          </tbody>
	        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

