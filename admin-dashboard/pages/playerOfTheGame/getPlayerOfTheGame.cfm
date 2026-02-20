
<cfparam name="url.scheduleID" default="0">
<cfparam name="url.winnerTeamID" default="0">

<cfcontent type="application/json">

<cfif url.scheduleID EQ 0 OR url.winnerTeamID EQ 0>
  <cfoutput>{"error": "Missing scheduleID or winnerTeamID"}</cfoutput>
  <cfabort>
</cfif>

<!--- Get all player stats from the winning team in this game --->
<cfquery name="getWinningTeamStats" datasource="roundleague">
  SELECT pgl.PlayerID, p.FirstName, p.LastName, 
         pgl.Points, pgl.Rebounds, pgl.Assists,
         pgl.Steals, pgl.Blocks, pgl.Turnovers,
         pgl.FGM, pgl.FGA, pgl.3FGM, pgl.3FGA, pgl.FTM, pgl.FTA,
         pgl.TeamID, t.teamName,
         r.Jersey
  FROM PlayerGameLog pgl
  JOIN Players p ON p.PlayerID = pgl.PlayerID
  JOIN Teams t ON t.teamID = pgl.TeamID
  LEFT JOIN Roster r ON r.PlayerID = p.PlayerID AND r.SeasonID = pgl.SeasonID
  WHERE pgl.ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    AND pgl.TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.winnerTeamID#">
  ORDER BY (pgl.Points + pgl.Rebounds + pgl.Assists) DESC
  LIMIT 1
</cfquery>

<!--- Get game info --->
<cfquery name="getGameInfo" datasource="roundleague">
  SELECT s.HomeTeamID, s.AwayTeamID, s.HomeScore, s.AwayScore,
         ht.teamName AS HomeTeamName,
         at.teamName AS AwayTeamName
  FROM Schedule s
  JOIN Teams ht ON s.HomeTeamID = ht.teamID
  JOIN Teams at ON s.AwayTeamID = at.teamID
  WHERE s.ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
</cfquery>

<cfif getWinningTeamStats.recordCount GT 0>
  <cfset playerData = {}>
  <cfset playerData["playerID"] = getWinningTeamStats.PlayerID>
  <cfset playerData["firstName"] = getWinningTeamStats.FirstName>
  <cfset playerData["lastName"] = getWinningTeamStats.LastName>
  <cfset playerData["points"] = getWinningTeamStats.Points>
  <cfset playerData["rebounds"] = getWinningTeamStats.Rebounds>
  <cfset playerData["assists"] = getWinningTeamStats.Assists>
  <cfset playerData["steals"] = getWinningTeamStats.Steals>
  <cfset playerData["blocks"] = getWinningTeamStats.Blocks>
  <cfset playerData["turnovers"] = getWinningTeamStats.Turnovers>
  <cfset playerData["teamID"] = getWinningTeamStats.TeamID>
  <cfset playerData["teamName"] = getWinningTeamStats.teamName>
  <cfset playerData["jersey"] = getWinningTeamStats.Jersey>
  <cfset playerData["photoURL"] = "/assets/img/PlayerProfiles/" & getWinningTeamStats.PlayerID & ".JPG">

  <!--- Check if the photo exists, otherwise use default --->
  <cfset photoPath = expandPath("/assets/img/PlayerProfiles/" & getWinningTeamStats.PlayerID & ".JPG")>
  <cfif NOT FileExists(photoPath)>
    <!--- Also check lowercase extension --->
    <cfset photoPath = expandPath("/assets/img/PlayerProfiles/" & getWinningTeamStats.PlayerID & ".jpg")>
    <cfif FileExists(photoPath)>
      <cfset playerData["photoURL"] = "/assets/img/PlayerProfiles/" & getWinningTeamStats.PlayerID & ".jpg">
    <cfelse>
      <cfset playerData["photoURL"] = "/assets/img/PlayerProfiles/default.JPG">
    </cfif>
  </cfif>

  <cfset playerData["homeTeamName"] = getGameInfo.HomeTeamName>
  <cfset playerData["awayTeamName"] = getGameInfo.AwayTeamName>
  <cfset playerData["homeScore"] = getGameInfo.HomeScore>
  <cfset playerData["awayScore"] = getGameInfo.AwayScore>
  <cfset playerData["homeTeamID"] = getGameInfo.HomeTeamID>
  <cfset playerData["awayTeamID"] = getGameInfo.AwayTeamID>
  <cfset playerData["gameScore"] = getWinningTeamStats.Points + getWinningTeamStats.Rebounds + getWinningTeamStats.Assists>

  <cfoutput>#serializeJSON(playerData)#</cfoutput>
<cfelse>
  <cfoutput>{"error": "No player stats found for this game"}</cfoutput>
</cfif>
