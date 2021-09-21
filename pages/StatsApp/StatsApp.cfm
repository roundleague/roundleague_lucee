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
    SELECT lastName, firstName, teamName, s.seasonName, d.divisionName, position
    FROM players p
    JOIN roster r ON r.PlayerID = p.playerID
    JOIN teams t ON t.teamId = r.teamID
    JOIN divisions d ON d.divisionID = r.DivisionID
    JOIN seasons s ON s.seasonID = s.seasonID
    WHERE r.seasonID = s.seasonID
    AND t.teamID = 1
</cfquery>

<body>
    <table class="pure-table pure-table-horizontal">
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
                <tr>
                    <td>
                        #getPlayers.firstName# #getPlayers.LastName#
                    </td>
                    <td>
                        <span class="fieldValue">0</span><br>
                        <button class="button-success pure-button">+1</button>
                        <button class="button-error pure-button">-1</button>
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                    <td>
                        0
                    </td>
                </tr>
            </cfloop>
        </tbody>
    </table>
    <!--- Scripts --->
    <script src="https://kit.fontawesome.com/356f7c17e2.js" crossorigin="anonymous"></script>
</body>
</html>
</cfoutput>