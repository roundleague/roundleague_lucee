<cfcomponent rest="true" restpath="playerapi">

  <!--- GET /rest/<serviceName>/playerapi/pointsPerGame/1001 --->
  <cffunction name="getPointsPerGame"
              access="remote"
              returntype="any"
              httpmethod="GET"
              restpath="pointsPerGame/{playerID}"
              produces="application/json">

    <!--- Bind {playerID} from the path --->
    <cfargument name="playerID" type="numeric" required="true" restArgSource="path">

    <!--- Query to get total points and games played for the player --->
    <cfquery name="qStats" datasource="roundleague">
      SELECT SUM(points) AS totalPoints, COUNT(*) AS gamesPlayed
      FROM playerstats
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.playerID#">
    </cfquery>

    <!--- Compute PPG safely --->
    <cfset var totalPoints = val(qStats.totalPoints)>
    <cfset var gamesPlayed = val(qStats.gamesPlayed)>
    <cfset var ppg = (gamesPlayed GT 0) ? (totalPoints / gamesPlayed) : 0>

    <cfset var result = {
      playerID      = arguments.playerID,
      totalPoints   = totalPoints,
      gamesPlayed   = gamesPlayed,
      pointsPerGame = ppg
    }>

    <!--- Return a struct; CF REST will serialize to JSON --->
    <cfreturn result>
  </cffunction>

</cfcomponent>
