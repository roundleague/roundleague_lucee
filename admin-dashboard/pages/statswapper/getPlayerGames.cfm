<cfparam name="url.playerID" default="">
<cfif url.playerID neq "">
  <cfquery name="gameQuery" datasource="roundleague">
	SELECT WEEK, pgl.PlayerGameLogID, homeTeam.teamName as HomeTeam, awayTeam.teamName as AwayTeam, pgl.Points, pgl.rebounds, pgl.Assists, s.date
	FROM playergamelog pgl
	JOIN schedule s ON s.scheduleID = pgl.scheduleID
	JOIN teams homeTeam ON hometeam.teamID = s.HomeTeamID
	JOIN teams awayTeam ON awayteam.teamID = s.AwayTeamID
	WHERE pgl.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.playerID#">
	AND pgl.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  </cfquery>

  <cfset gameData = []>
  <cfloop query="gameQuery">
    <cfset game = {
      "playerGameLogID": PlayerGameLogID,
      "homeTeam": HomeTeam,
      "awayTeam": AwayTeam,
      "points": Points,
      "rebounds": Rebounds,
      "assists": Assists,
      "week": Week,
      "date": Date
    }>
    <cfset arrayAppend(gameData, game)>
  </cfloop>

  <cfset response = {"games": gameData}>
  <cfcontent type="application/json">
  <cfoutput>#serializeJSON(response)#</cfoutput>
<cfelse>
  <cfset response = {"error": "Invalid player ID"}>
  <cfcontent type="application/json">
  <cfoutput>#serializeJSON(response)#</cfoutput>
</cfif>
