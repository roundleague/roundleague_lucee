<cfinclude template="/header.cfm">

<!--- Guard against direct/bare hits (bots, stale bookmarks) with no playerID in the URL --->
<cfif NOT isDefined("url.playerID") OR NOT isNumeric(url.playerID)>
    <cflocation url="/pages/Teams/teams-2.cfm" addtoken="false">
</cfif>

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/Player_Profiles/player-profile-2.css?v=3.1" rel="stylesheet" />

<cfquery name="getPlayerData" datasource="roundleague">
    SELECT p.lastName, p.firstName, p.position, p.height, p.weight, p.hometown, p.school, t.teamName
    FROM Players p
    LEFT JOIN Roster r on r.playerID = p.playerID AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    LEFT JOIN Teams t on r.teamID = t.teamID
    WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    ORDER BY teamName desc
    LIMIT 1
</cfquery>

<cfquery name="getPlayerStats" datasource="roundleague">
    SELECT Points, Rebounds, Assists, Truncate(FGM / FGA * 100, 1) AS FGP, TRUNCATE(`3FGM` / `3FGA` * 100, 1) AS `3FGP`, Steals, Blocks, Turnovers
    FROM playerstats p
    JOIN seasons s ON p.SeasonID = s.seasonID
    AND p.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerAwards" datasource="roundleague">
    SELECT AwardName, awards.seasonID, seasons.SeasonName
    FROM Awards
    JOIN Seasons ON awards.SeasonID = Seasons.SeasonID
    WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">

    UNION ALL

    <!--- Player was on the roster of a team that won the championship that season --->
    SELECT 'Champion' AS AwardName, c.seasonID, s.SeasonName
    FROM Roster r
    JOIN champions c ON c.teamID = r.teamID AND c.seasonID = r.seasonID
    JOIN Seasons s ON s.seasonID = c.seasonID
    WHERE r.playerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">

    ORDER BY seasonID DESC
</cfquery>

<cfquery name="getSeasons" datasource="roundleague">
    SELECT DISTINCT s.seasonID, s.seasonName
    FROM seasons s
    JOIN playergamelog pgl ON pgl.seasonID = s.seasonID
    WHERE pgl.playerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    ORDER by seasonID desc
</cfquery>

<!--- Create a list of all seasonIDs from the getSeasons query --->
<cfset seasonIDList = ValueList(getSeasons.seasonID)>

<!--- Check if session.currentSeasonID is in the list --->
<cfif ListFind(seasonIDList, session.currentSeasonID)>
    <cfparam name="form.seasonSelect" default="#session.currentSeasonID#">
<cfelse>
    <cfparam name="form.seasonSelect" default="#getSeasons.seasonID#">
</cfif>

<cfquery name="getPlayerGameLog" datasource="roundleague">
    SELECT pgl.PlayerID, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, pgl.Fouls, pgl.scheduleID, a.teamName AS HomeTeam, b.teamName AS AwayTeam, s.week
    FROM PlayerGameLOG pgl
    JOIN schedule s ON s.ScheduleID = pgl.scheduleID
        LEFT JOIN teams as a ON s.hometeamID = a.teamID
        LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    AND pgl.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonSelect#">
</cfquery>

<!--- Career Totals --->
<cfinvoke component="player-profile"
	method="getCareerStats"
	returnvariable="careerStats">
    <cfinvokeargument name="playerID" value="#url.playerID#">
</cfinvoke>




<cfoutput>
<div class="main" style="background: linear-gradient(180deg, ##ffffff 0%, ##f8f7f5 50%, ##f5f4f2 100%); margin-top: 70px;">
    <div class="section">
      <div class="container">

        <!--- Player Header Card --->
        <div class="player-header-card">
            <div class="player-header-content">
                <div class="player-photo-wrapper">
                    <cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
                    <cfif FileExists(imgPath)>
                        <img src="/assets/img/PlayerProfiles/#url.playerID#.JPG" alt="Player Photo" class="player-photo">
                    <cfelse>
                        <img src="/assets/img/PlayerProfiles/default.JPG" alt="Player Photo" class="player-photo">
                    </cfif>
                    <cfif len(trim(getPlayerData.teamName))>
                        <span class="team-badge">#getPlayerData.teamName#</span>
                    </cfif>
                </div>
                <div class="player-info-section">
                    <h1 class="player-name">#UCase(Left(getPlayerData.firstName, 1))##LCase(Mid(getPlayerData.firstName, 2))# #UCase(Left(getPlayerData.LastName, 1))##LCase(Mid(getPlayerData.LastName, 2))#</h1>
                    <p class="player-position">#getPlayerData.position#</p>
                    <div class="player-details-grid">
                        <div class="detail-box">
                            <span class="detail-label">Height</span>
                            <span class="detail-value">#getPlayerData.height#</span>
                        </div>
                        <div class="detail-box">
                            <span class="detail-label">Weight</span>
                            <span class="detail-value">#getPlayerData.weight#</span>
                        </div>
                        <div class="detail-box">
                            <span class="detail-label">Hometown</span>
                            <span class="detail-value">#getPlayerData.hometown#</span>
                        </div>
                        <div class="detail-box">
                            <span class="detail-label">School</span>
                            <span class="detail-value">#getPlayerData.school#</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Compute Career Averages --->
        <cfif careerStats.recordCount GT 0>
            <cfset careerSeasons = careerStats.recordCount>
            <cfset avgPoints = 0><cfset avgRebounds = 0><cfset avgAssists = 0>
            <cfset avgSteals = 0><cfset avgBlocks = 0><cfset avgTurnovers = 0>
            <cfset totalFGM = 0><cfset totalFGA = 0><cfset total3FGM = 0><cfset total3FGA = 0>
            <cfloop query="careerStats">
                <cfset avgPoints += val(careerStats.Points)>
                <cfset avgRebounds += val(careerStats.Rebounds)>
                <cfset avgAssists += val(careerStats.Assists)>
                <cfset avgSteals += val(careerStats.Steals)>
                <cfset avgBlocks += val(careerStats.Blocks)>
                <cfset avgTurnovers += val(careerStats.Turnovers)>
                <cfset totalFGM += val(careerStats.FGM)>
                <cfset totalFGA += val(careerStats.FGA)>
                <cfset total3FGM += val(careerStats["3FGM"])>
                <cfset total3FGA += val(careerStats["3FGA"])>
            </cfloop>
            <cfset avgPoints = avgPoints / careerSeasons>
            <cfset avgRebounds = avgRebounds / careerSeasons>
            <cfset avgAssists = avgAssists / careerSeasons>
            <cfset avgSteals = avgSteals / careerSeasons>
            <cfset avgBlocks = avgBlocks / careerSeasons>
            <cfset avgTurnovers = avgTurnovers / careerSeasons>
            <cfset careerFGP = totalFGA GT 0 ? NumberFormat(totalFGM / totalFGA * 100, "0.0") : "0.0">
            <cfset career3FGP = total3FGA GT 0 ? NumberFormat(total3FGM / total3FGA * 100, "0.0") : "0.0">
        </cfif>

        <!--- Season / Career Stats Toggle --->
        <div class="stats-section">
            <div class="stats-toggle-header">
                <h2 class="stats-title" id="statsTitle">Season Statistics</h2>
                <div class="stats-toggle">
                    <button class="stats-toggle-btn active" id="btnSeason" onclick="showSeasonStats()">Season</button>
                    <button class="stats-toggle-btn" id="btnCareer" onclick="showCareerStats()">Career</button>
                </div>
            </div>

            <!--- Season Stats --->
            <div id="seasonStats" class="stats-grid">
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Points, "0.0")#</span>
                    <span class="stat-label">Points</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Rebounds, "0.0")#</span>
                    <span class="stat-label">Rebounds</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Assists, "0.0")#</span>
                    <span class="stat-label">Assists</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Steals, "0.0")#</span>
                    <span class="stat-label">Steals</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Blocks, "0.0")#</span>
                    <span class="stat-label">Blocks</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.Turnovers, "0.0")#</span>
                    <span class="stat-label">Turnovers</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.FGP, "0.0")#</span>
                    <span class="stat-label">FG%</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(getPlayerStats.3FGP, "0.0")#</span>
                    <span class="stat-label">3PT%</span>
                </div>
            </div>

            <!--- Career Averages --->
            <cfif careerStats.recordCount GT 0>
            <div id="careerStats" class="stats-grid" style="display: none;">
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgPoints, "0.0")#</span>
                    <span class="stat-label">Points</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgRebounds, "0.0")#</span>
                    <span class="stat-label">Rebounds</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgAssists, "0.0")#</span>
                    <span class="stat-label">Assists</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgSteals, "0.0")#</span>
                    <span class="stat-label">Steals</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgBlocks, "0.0")#</span>
                    <span class="stat-label">Blocks</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#NumberFormat(avgTurnovers, "0.0")#</span>
                    <span class="stat-label">Turnovers</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#careerFGP#</span>
                    <span class="stat-label">FG%</span>
                </div>
                <div class="stat-box">
                    <span class="stat-value">#career3FGP#</span>
                    <span class="stat-label">3PT%</span>
                </div>
            </div>
            </cfif>
        </div>

        <!--- Player Game Log --->
        <form id="gameLogForm" method="post">
          <table class="bolder" <cfif isDefined("form.seasonSelectHasChanged")>id="playerGameLogTable"</cfif>>
              <caption>
                <select class="seasonSelect" name="seasonSelect" style="padding: 7px;" onchange="this.form.submit();">
                  <cfloop query="getSeasons">
                    <option value="#getSeasons.seasonID#" <cfif getSeasons.seasonID EQ form.seasonSelect>selected</cfif>>#getSeasons.seasonName#</option>
                  </cfloop>
                </select>
              </caption>
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
                        <td data-label="Opponent">
                          <cfif len(trim(opponent))>
                            <a href="/pages/boxscore/boxscore.cfm?scheduleID=#getPlayerGameLog.scheduleID#">#opponent#</a>
                          <cfelse>
                            -
                          </cfif>
                        </td>
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
          <input type="hidden" name="seasonSelectHasChanged" />
        </form>        

	        <table class="bolder">
	          <caption>Career Stats</caption>
	          <thead>
	            <tr class="headers">
	            	<th>Season</th>
                    <th>Team</th>
	            	<th>Points</th>
	            	<th>Rebounds</th>
	            	<th>Assists</th>
	            	<th>Steals</th>
	            	<th>Blocks</th>
	            	<th>Turnovers</th>
	            </tr>
	          </thead>
	          <tbody>
                <cfloop query="careerStats">
                    <tr <cfif careerStats.currentRow GT 5>class="hidden-season"</cfif>>
                        <td data-label="Season">#careerStats.seasonName#</td>
                        <td data-label="Team">#careerStats.teamName#</td>
                        <td data-label="Points">#val(careerStats.Points)#</td>
                        <td data-label="Rebounds">#val(careerStats.Rebounds)#</td>
                        <td data-label="Assists">#val(careerStats.Assists)#</td>
                        <td data-label="Steals">#val(careerStats.Steals)#</td>
                        <td data-label="Blocks">#val(careerStats.Blocks)#</td>
                        <td data-label="Turnovers">#val(careerStats.Turnovers)#</td>
                    </tr>
                </cfloop>
	          </tbody>
	        </table>
	        
	        <cfif careerStats.recordCount GT 5>
	            <div style="text-align: center; margin: 10px 0;">
	                <button id="showMoreSeasonsBtn" onclick="toggleSeasons()" style="background-color: ##007bff; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">Show More Seasons</button>
	            </div>
	        </cfif>   

		 <cfif getPlayerAwards.recordCount NEQ 0>
            <table class="bolder">
              <caption>Awards</caption>
              <thead>
                <tr class="headers">
                    <th>Season</th>
                    <th>Awards</th>
                </tr>
              </thead>
              <tbody>
                <cfloop query="getPlayerAwards">
                    <tr>
                        <td data-label="Season">#getPlayerAwards.SeasonName#</td>
                        <td data-label="Awards">#getPlayerAwards.AwardName#</td>
                    </tr>
                </cfloop>
              </tbody>
            </table>     
         </cfif>   
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../../Teams/Player_Profiles/player-profile-2.js?v=2.3"></script>