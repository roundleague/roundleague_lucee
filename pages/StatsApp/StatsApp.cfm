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


<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<link rel="stylesheet" href="StatsApp.css">

</head>

<!--- Queries --->
<cfquery name="getPlayers" datasource="roundleague">
    SELECT p.playerID, lastName, firstName, teamName, s.seasonName, d.divisionName, position
    FROM players p
    JOIN roster r ON r.PlayerID = p.playerID
    JOIN teams t ON t.teamId = r.teamID
    JOIN divisions d ON d.divisionID = r.DivisionID
    JOIN seasons s ON s.seasonID = s.seasonID
    WHERE r.seasonID = s.seasonID
    AND t.teamID = 1
</cfquery>

<cfif IsDefined("form.saveBoxScore")>
    <cfinclude template="StatsApp-Save.cfm">
</cfif>

<body>
    <form name="gameLogForm" method="POST">
        <table id="sort" class="grid pure-table pure-table-horizontal">
            <thead>
                <tr>
                    <th>Player</th>
                    <th>FGM</th>
                    <th>FGA</th>
                    <th>3FGM</th>
                    <th>3FGA</th>
                    <th>FTM</th>
                    <th>FTA</th>
                    <th>PTS</th>
                    <th>REBS</th>
                    <th>ASTS</th>
                </tr>
            </thead>
            <tbody>
                <cfloop query="getPlayers">
                    <cfif getPlayers.currentRow EQ 6>
                        <tr id="benchToggle">
                            <td colspan="10">
                                Bench (Click To Show/Hide)
                            </td>
                        </tr>
                    </cfif>
                    <tr class="dragdrop" id="Player_#getPlayers.playerID#">
                        <td>
                            #getPlayers.firstName# #getPlayers.LastName#
                        </td>
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
                    </tr>
                </cfloop>
            </tbody>
        </table>
        <br>
        <input type="submit" name="saveBoxScore" style="margin-left: 25px;" value="Save">
    </form>
    <!--- Scripts --->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" crossorigin="anonymous"></script>
    <script src="https://kit.fontawesome.com/356f7c17e2.js" crossorigin="anonymous"></script>
    <script src="StatsApp.js"></script>
</body>
</html>
</cfoutput>