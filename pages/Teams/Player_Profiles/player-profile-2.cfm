<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/Player_Profiles/player-profile-2.css" rel="stylesheet" />

<cfquery name="getPlayerData" datasource="roundleague">
	SELECT lastName, firstName, position, height, weight, hometown, school, t.teamName
	FROM Players p
	JOIN Roster r on r.playerID = p.playerID
	JOIN Teams t on r.teamID = t.teamID
	WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerStats" datasource="roundleague">
    SELECT Points, Rebounds, Assists, Truncate(FGM / FGA * 100, 1) AS FGP, TRUNCATE(`3FGM` / `3FGA` * 100, 1) AS `3FGP`, Steals, Blocks, Turnovers
    FROM playerstats p
    JOIN seasons s ON p.SeasonID = s.seasonID
    AND p.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerAwards" datasource="roundleague">
	SELECT AwardName
	FROM Awards
	WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerGameLog" datasource="roundleague">
    SELECT pgl.PlayerID, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, pgl.Fouls, pgl.scheduleID, a.teamName AS HomeTeam, b.teamName AS AwayTeam, s.week
    FROM PlayerGameLOG pgl
    JOIN schedule s ON s.ScheduleID = pgl.scheduleID
        LEFT JOIN teams as a ON s.hometeamID = a.teamID
        LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    AND pgl.seasonID = 4
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
		<section class="section about-section" id="about">
            <div class="container">
                <div class="row align-items-center flex-row-reverse">
                    <div class="col-lg-6">
                        <div class="about-avatar">
					      <cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
					      <cfset altPath = "/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG"> <!--- Alt Path so we don't have to reorder pictures for now lol --->
					      <cfif FileExists(imgPath)>
					      	<img src="/assets/img/PlayerProfiles/#url.playerID#.JPG" alt="Player Photo" style="width:100%">
					      <cfelseif FileExists(altPath)>
					      	<img src="/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG" alt="Player Photo" style="width:100%">
					      <cfelse>
							<img src="/assets/img/PlayerProfiles/default.JPG" alt="Player Photo" style="width:100%">
					      </cfif>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="about-text go-to">
                            <h3 class="dark-color">#getPlayerData.firstName# #getPlayerData.LastName#</h3>
                            <h6 class="theme-color lead">#getPlayerData.position#</h6>
                            <div class="row about-list">
                                <div class="col-md-6">
                                    <div class="media">
                                        <label>Height</label>
                                        <p>#getPlayerData.height#</p>
                                    </div>
                                    <div class="media">
                                        <label>Weight</label>
                                        <p>#getPlayerData.weight#</p>
                                    </div>
                                    <div class="media">
                                        <label>Hometown</label>
                                        <p>#getPlayerData.hometown#</p>
                                    </div>
                                    <div class="media">
                                        <label>School</label>
                                        <p>#getPlayerData.school#</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="counter" style="margin-top: 25px;">
                    <div class="row">
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="500" data-speed="500">#NumberFormat(getPlayerStats.Points, "0.0")#</h6>
                                <p class="m-0px font-w-600">Points</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="150" data-speed="150">#NumberFormat(getPlayerStats.Rebounds, "9.9")#</h6></h6>
                                <p class="m-0px font-w-600">Rebounds</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="850" data-speed="850">#NumberFormat(getPlayerStats.Assists, "0.0")#</h6></h6>
                                <p class="m-0px font-w-600">Assists</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#NumberFormat(getPlayerStats.Steals, "0.0")#</h6></h6>
                                <p class="m-0px font-w-600">Steals</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#NumberFormat(getPlayerStats.Blocks, "0.0")#</h6></h6>
                                <p class="m-0px font-w-600">Blocks</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#NumberFormat(getPlayerStats.Turnovers, "0.0")#</h6></h6>
                                <p class="m-0px font-w-600">Turnovers</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#NumberFormat(getPlayerStats.FGP, "0.0")#</h6>
                                <p class="m-0px font-w-600">FG%</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#NumberFormat(getPlayerStats.3FGP, "0.0")#</h6>
                                <p class="m-0px font-w-600">3FG%</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!--- Player Game Log --->
          <table>
              <caption>Player Game Log</caption>
              <thead>
                <tr class="headers">
                    <th>Week</th>
                    <th>Opponent</th>
                    <th>FG</th>
                    <th>3PT</th>
                    <th>FT</th>
                    <th>REB</th>
                    <th>AST</th>
                    <th>STL</th>
                    <th>BLK</th>
                    <th>TO</th>
                    <th>FLS</th>
                    <th>PTS</th>
                </tr>
              </thead>
              <tbody>
                <cfset teamObject = createObject("component", "library.teams") />
                <cfloop query="getPlayerGameLog">

                <cfset opponent = teamObject.getOpponent(getPlayerGameLog.homeTeam, getPlayerGameLog.awayTeam, getPlayerData.teamName)>

                    <tr>
                        <td data-label="Week">#getPlayerGameLog.week#</td>
                        <td data-label="Opponent">#opponent#</td>
                        <td data-label="FG">#getPlayerGameLog.FGM# - #getPlayerGameLog.FGA#</td>
                        <td data-label="3FG">#getPlayerGameLog.3FGM# - #getPlayerGameLog.3FGA#</td>
                        <td data-label="FT">#getPlayerGameLog.FTM# - #getPlayerGameLog.FTA#</td>
                        <td data-label="REBS">#getPlayerGameLog.Rebounds#</td>
                        <td data-label="ASTS">#getPlayerGameLog.Assists#</td>
                        <td data-label="STLS">#getPlayerGameLog.Steals#</td>
                        <td data-label="BLKS">#getPlayerGameLog.Blocks#</td>
                        <td data-label="TO">#getPlayerGameLog.Turnovers#</td>
                        <td data-label="FLS">#val(getPlayerGameLog.Fouls)#</td>
                        <td data-label="PTS">#getPlayerGameLog.Points#</td>
                    </tr>
                </cfloop>
              </tbody>
            </table>        

        <!--- Hide Career Stats for now --->
<!--- 	        <table>
	          <caption>Career Stats</caption>
	          <thead>
	            <tr class="headers">
	            	<th>Season</th>
	            	<th>Points</th>
	            	<th>Rebounds</th>
	            	<th>Assists</th>
	            	<th>Steals</th>
	            	<th>Blocks</th>
	            	<th>Turnovers</th>
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
	        </table>       --->  

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

