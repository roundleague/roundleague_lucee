<cfoutput>
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>The Round League Stats App</title>
  <meta name="description" content="A simple HTML5 Template for new projects.">
  <meta name="author" content="SitePoint">

  <meta property="og:title" content="A Basic HTML5 Template">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://www.sitepoint.com/a-basic-html5-template/">
  <meta property="og:description" content="A simple HTML5 Template for new projects.">
  <meta property="og:image" content="image.png">

  <link rel="icon" href="/favicon.ico">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">

<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<link rel="stylesheet" href="StatsApp.css">

</head>

<cfsavecontent variable="dnpIcon">
    <svg class="dnpIcon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-x" viewBox="0 0 16 16">
      <path d="M6 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H1s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C9.516 10.68 8.289 10 6 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
      <path fill-rule="evenodd" d="M12.146 5.146a.5.5 0 0 1 .708 0L14 6.293l1.146-1.147a.5.5 0 0 1 .708.708L14.707 7l1.147 1.146a.5.5 0 0 1-.708.708L14 7.707l-1.146 1.147a.5.5 0 0 1-.708-.708L13.293 7l-1.147-1.146a.5.5 0 0 1 0-.708z"/>
    </svg>
</cfsavecontent>

<!--- Queries --->
<cfquery name="getPlayers" datasource="roundleague">
    SELECT p.playerID, lastName, firstName, teamName, s.seasonName, s.seasonID, d.divisionName, position, r.Jersey
    FROM players p
    JOIN roster r ON r.PlayerID = p.playerID
    JOIN teams t ON t.teamId = r.teamID
    JOIN divisions d ON d.divisionID = r.DivisionID
    JOIN seasons s ON s.seasonID = s.seasonID
    WHERE r.seasonID = s.seasonID
    AND s.seasonID = (SELECT SeasonID From Seasons Where Status = 'Active')
    AND t.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
    GROUP BY lastName, firstName
</cfquery>

<cfquery name="getTeamsPlaying" datasource="roundleague">
    SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.seasonID, s.divisionID
    FROM schedule s
    LEFT JOIN teams as a ON s.hometeamID = a.teamID
    LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE s.scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
</cfquery>

<cfif IsDefined("form.saveBoxScore")>
    <cfinclude template="StatsApp-Save.cfm">
</cfif>

<body>

    <div style="position:relative;min-width:960px">
        <button type="button" class="pure-button undoBtn">Undo</button>
    </div>

    <form name="gameLogForm" method="POST">

        <!-- Final Scores Modal -->
          <div id="saveScoresModal" class="w3-modal">
            <div class="w3-modal-content w3-animate-top w3-card-4">
              <header class="w3-container w3-teal"> 
                <span onclick="document.getElementById('saveScoresModal').style.display='none'" 
                class="w3-button w3-display-topright">&times;</span>
                <h2>Enter the final scores</h2>
              </header>
              <div class="w3-container" style="padding: 30px;">
                #getTeamsPlaying.home# (Home): <input type="number" name="homeScore" value="0"><br>
                #getTeamsPlaying.away# (Away): <input type="number" name="awayScore" value="0">
                <input type="submit" name="saveBoxScore" style="margin-left: 25px;" value="Save">
              </div>
              <footer class="w3-container w3-teal">
                <!---   Modal Footer  --->
                Please remember to mark any players that did not play!
              </footer>
            </div>
          </div>
        </div>

        <!-- Confirm DNP Modal -->
          <div id="dnpModal" class="w3-modal">
            <div class="w3-modal-content w3-animate-top w3-card-4">
              <header class="w3-container w3-teal"> 
                <span onclick="document.getElementById('dnpModal').style.display='none'" 
                class="w3-button w3-display-topright">&times;</span>
                <h2><span class="dnpPlayer"></span> - Did Not Play</h2>
              </header>
              <div class="w3-container" style="padding: 30px;">
                <!--- Input fields --->
                Are you sure you wish to mark this player as "Did Not Play"? Their stats for this game will not be counted.<br><br>
                <button type="button" class="dnpConfirm">Yes</button>
              </div>
              <footer class="w3-container w3-teal">
                <!---   Modal Footer  --->
              </footer>
            </div>
          </div>
        </div>

        <table id="sort" class="grid pure-table pure-table-horizontal statsAppTable">
            <thead>
                <tr>
                    <th>#getPlayers.teamName#</th>
                    <th class="noDisplay">Jersey</th>
                    <th>FGM(1)</th>
                    <th>FGA(2)</th>
                    <th>3FGM(3)</th>
                    <th>3FGA(4)</th>
                    <th>REBS(5)</th>
                    <th>ASTS(6)</th>
                    <th>STLS(7)</th>
                    <th>BLKS(8)</th>
                    <th>TO(9)</th>
                    <th>FOULS</th>
                    <th>FTM</th>
                    <th>FTA</th>
                    <th>PTS</th>
                </tr>
            </thead>
            <tbody>
                <cfloop query="getPlayers">
                    <cfif getPlayers.currentRow EQ 6>
                        <tr id="benchToggle">
                            <td colspan="5">
                                Bench (Click To Show/Hide)
                            </td>
                            <td colspan="3">
                                <label class="switch switch-left-right">
                                    <input class="switch-input" type="checkbox" checked />
                                    <span class="switch-label" data-on="1st Half" data-off="2nd Half"></span> 
                                    <span class="switch-handle"></span> 
                                </label>
                            </td>
                            <td colspan="2">
                                1st Half Fouls: <span class="firstHalfFouls">0</span>
                            </td>
                            <td colspan="2">
                                2nd Half Fouls: <span class="secondHalfFouls">0</span>
                            </td>
                            <td colspan="2">
                                Total: <span class="teamTotalPts">0</span>
                            </td>
                        </tr>
                    </cfif>
                    <tr class="dragdrop" id="Player_#getPlayers.playerID#">
                        <td class="playerBox ExportLabelTD">
                            #dnpIcon#
                            <span class="playerName">#getPlayers.firstName# #getPlayers.LastName#</span> <input class="jerseyNumber" type="number" name="Jersey_#playerID#" value="#getPlayers.Jersey#">
                        </td>
                        <td class="noDisplay ExportLabelTD"></td>
                        <td>
                            <input type="number" name="FGM_#playerID#" id="FGM" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button FGM">+1</button>
                            <button type="button" class="button-error pure-button FGM">-1</button>
                        </td>
                        <td>
                            <input type="number" name="FGA_#playerID#" id="FGA" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button FGA">+1</button>
                            <button type="button" class="button-error pure-button FGA">-1</button>
                        </td>
                        <td>
                            <input type="number" name="3FGM_#playerID#" id="3FGM" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button 3FGM">+1</button>
                            <button type="button" class="button-error pure-button 3FGM">-1</button>
                        </td>
                        <td>
                            <input type="number" name="3FGA_#playerID#" id="3FGA" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button 3FGA">+1</button>
                            <button type="button" class="button-error pure-button 3FGA">-1</button>
                        </td>
                        <td>
                            <input type="number" name="REBS_#playerID#" id="REBS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button REBS">+1</button>
                            <button type="button" class="button-error pure-button REBS">-1</button>
                        </td>
                        <td>
                            <input type="number" name="ASTS_#playerID#" id="ASTS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button ASTS">+1</button>
                            <button type="button" class="button-error pure-button ASTS">-1</button>
                        </td>
                        <td>
                            <input type="number" name="STLS_#playerID#" id="STLS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button STLS">+1</button>
                            <button type="button" class="button-error pure-button STLS">-1</button>
                        </td>
                        <td>
                            <input type="number" name="BLKS_#playerID#" id="BLKS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button BLKS">+1</button>
                            <button type="button" class="button-error pure-button BLKS">-1</button>
                        </td>
                        <td>
                            <input type="number" name="TO_#playerID#" id="TO" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button TO">+1</button>
                            <button type="button" class="button-error pure-button TO">-1</button>
                        </td>
                        <td>
                            <input type="number" name="FOULS_#playerID#" id="FOULS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button FOULS">+1</button>
                            <button type="button" class="button-error pure-button FOULS">-1</button>
                        </td>
                        <td>
                            <input type="number" name="FTM_#playerID#" id="FTM" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button FTM">+1</button>
                            <button type="button" class="button-error pure-button FTM">-1</button>
                        </td>
                        <td>
                            <input type="number" name="FTA_#playerID#" id="FTA" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button FTA">+1</button>
                            <button type="button" class="button-error pure-button FTA">-1</button>
                        </td>
                        <td>
                            <input type="number" name="PTS_#playerID#" id="PTS" class="fieldValue" value="0"><br>
                            <button type="button" class="button-success pure-button PTS">+1</button>
                            <button type="button" class="button-error pure-button PTS">-1</button>
                        </td>
                        <!--- Use this to see which players were active, needed for DNP function --->
                        <input type="hidden" name="playerIDList" value="#playerID#">
                    </tr>
                </cfloop>
            </tbody>
        </table>
        <br>
        <input class="saveBtn" type="button" name="openModal" style="margin-left: 25px; margin-bottom: 25px;" value="Save">
        <input type="button" id="btnExport" style="margin-left: 25px; margin-bottom: 25px;" value="Export" />
        <span class="legend">#dnpIcon# - At the end of the game, click to toggle player as Did Not Play. Use W (Up) and S (Down) to navigate through the active 5 players.</span>
    </form>
    <!--- Scripts --->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" crossorigin="anonymous"></script>
    <script src="https://kit.fontawesome.com/356f7c17e2.js" crossorigin="anonymous"></script>
    <script src="StatsApp.js"></script>
    <script src="StatsApp-Export.js"></script>
    <script src="ConfirmExit.js"></script>
</body>
</html>
</cfoutput>