<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/Player_Profiles/player-profile.css" rel="stylesheet" />

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

<!--- Career Totals --->
<cfinvoke component="player-profile"
	method="getCareerStats"
	returnvariable="careerStats">
    <cfinvokeargument name="playerID" value="#url.playerID#">
</cfinvoke>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<div class="row">
		  <div class="column">
		    <div class="card">
		      <img src="/assets/img/PlayerProfiles/#url.playerID#.JPG" alt="Player Photo" style="width:100%">
		      <div class="container">
		        <h2>#getPlayerData.firstName# #getPlayerData.LastName#</h2>
		        #getPlayerData.position#<br>
		        Seasons: #getPlayerStats.recordCount#
		      </div>
		    </div>
		  </div>

	        <table>
	          <caption>Career Stats</caption>
	          <thead>
	            <tr class="headers">
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
		            	<td data-label="Season">#getPlayerStats.SeasonName#</td>
		            	<td data-label="Points">#val(getPlayerStats.Points)#</td>
		            	<td data-label="Rebounds">#val(getPlayerStats.Rebounds)#</td>
		            	<td data-label="Assists">#val(getPlayerStats.Assists)#</td>
		            	<td data-label="Steals">#val(getPlayerStats.Steals)#</td>
		            	<td data-label="Blocks">#val(getPlayerStats.Blocks)#</td>
		            	<td data-label="Turnovers">#val(getPlayerStats.Turnovers)#</td>
		            </tr>
	        	</cfloop>
	            <tr class="headers">
	            	<td data-label="Career">Career</td>
	            	<td data-label="Points">#val(careerStats.Points)#</td>
	            	<td data-label="Rebounds">#val(careerStats.Rebounds)#</td>
	            	<td data-label="Assists">#val(careerStats.Assists)#</td>
	            	<td data-label="Steals">#val(careerStats.Steals)#</td>
	            	<td data-label="Blocks">#val(careerStats.Blocks)#</td>
	            	<td data-label="Turnovers">#val(careerStats.Turnovers)#</td>
	            </tr>
	          </tbody>
	        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

