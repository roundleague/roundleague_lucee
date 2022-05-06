<cfoutput>

<!--- Check session logged in, prevent users from directly accessing through a link --->
<!--- Too risky to do on statsapp right now, let's try with Player Info Page first --->
<!--- <cfif !isDefined("session.loggedIn")>
  Access Denied.
  <cfabort />
</cfif> --->

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
<link rel="stylesheet" href="StatsApp-Select.css">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Standings/purekitpro.css" rel="stylesheet" />

</head>

<cfparam name="form.teamID" default="0">
<cfparam name="form.scheduleID" default="0">

<cfquery name="getTeams" datasource="roundleague">
  SELECT teamID, teamName
  FROM teams
  Where Status = 'Active'
  AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  ORDER BY teamName
</cfquery>

<!--- Queries --->
<cfquery name="getTeamMatchups" datasource="roundleague">
  SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, homeScore, 0 AS IsPlayoffs
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE (a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#"> OR b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">)
  AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#"> 
  UNION
  SELECT playoffs_scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, homeScore, 1 AS IsPlayoffs
  FROM playoffs_schedule s
  JOIN playoffs_bracket pb ON pb.Playoffs_bracketID = s.Playoffs_BracketID
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE (a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#"> OR b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">)
    AND pb.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#"> 
</cfquery>

<!--- If coming after saving a game --->
<cfif isDefined("url.saved")>
  <!-- The actual snackbar -->
  <div id="snackbar">Saved! Check the standings and scores to verify.</div>
</cfif>

<body>
    <form id="mainForm" name="selectForm" method="POST">
      <div class="gameSelect">
        <label for="seasonID">Select Team: </label>
        <select name="teamID" id="Team" class="teamSelect">
            <option value=""></option>
            <cfloop query="getTeams">
                <option value="#getTeams.teamID#" <cfif form.teamID EQ getTeams.TeamID>selected</cfif>>#getTeams.teamName#</option>
            </cfloop>
        </select>
        <br>
        <cfif isDefined("form.teamID")>
          <label for="seasonID">Select Week: </label>
          <select name="scheduleID" id="Schedule" class="scheduleSelect">
              <cfloop query="getTeamMatchups">
                  <cfif form.teamID EQ getTeamMatchups.hometeamID>
                    <cfset opponentTeam = getTeamMatchups.away>
                  <cfelse>
                    <cfset opponentTeam = getTeamMatchups.home>
                  </cfif>
                  <option data-playoffs="#getTeamMatchups.isPlayoffs#" value="#getTeamMatchups.scheduleID#"<cfif form.scheduleID EQ getTeamMatchups.scheduleID>selected</cfif>>Week #getTeamMatchups.Week# VS #opponentTeam# <cfif homeScore NEQ ''>(Already Played)</cfif></option>
              </cfloop>
          </select>
        </cfif>
        <br>
        <br>
        <input type="hidden" class="isPlayoffsValue" name="isPlayoffsValue" value="">
        <input type="submit" value="Submit">
      </div>

      <div class="scrimmageSelect">
        <br>
        <br>
        OR
        <br>
        Player Count: <input type="number" value="0" name="playerCount"><br>
        <br>
        <input type="submit" value="Scrimmage Game" name="scrimmage">
      </div>
    </form>

    <cfif form.scheduleID>
      <cflocation url="StatsApp.cfm?teamID=#form.teamID#&scheduleID=#form.scheduleID#&isPlayoffs=#form.isPlayoffsValue#">
    </cfif>

    <cfif isDefined("form.scrimmage")>
      <cflocation url="StatsApp-Scrimmage.cfm?teamID=#form.teamID#&players=#form.playerCount#">
    </cfif>

    <!--- Scripts --->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" crossorigin="anonymous"></script>
    <script src="https://kit.fontawesome.com/356f7c17e2.js" crossorigin="anonymous"></script>
    <script src="StatsApp.js"></script>
    <script src="StatsApp-Select.js"></script>
</body>
</html>
</cfoutput>