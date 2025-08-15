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

    <!--- Rate Limiting: Use IP + route as bucketKey --->
    <cfset var limiter = createObject("component", "api.RateLimiter")>
    <cfset var ip = cgi.remote_addr>
    <cfset var route = "pointsPerGame/" & arguments.playerID>
    <cfset var bucketKey = ip & "|" & route>
    <cfset var limitResult = limiter.check(bucketKey, 60, 60)>

    <!--- Set rate limit headers --->
    <cfheader name="X-RateLimit-Limit" value="#limitResult.limit#">
    <cfheader name="X-RateLimit-Remaining" value="#limitResult.remaining#">
    <cfheader name="X-RateLimit-Reset" value="#limitResult.resetAt#">
    <cfheader name="Cache-Control" value="max-age=600, public">

    <!--- If not allowed, return 429 Too Many Requests --->
    <cfif NOT limitResult.allowed>
      <cfheader statuscode="429" statustext="Too Many Requests">
      <cfset var errorStruct = {
        error = "Rate limit exceeded",
        limit = limitResult.limit,
        remaining = limitResult.remaining,
        resetAt = limitResult.resetAt
      }>
      <cfcontent type="application/json" reset="true" variable="#serializeJSON(errorStruct)#">
      <cfexit method="exit">
    </cfif>

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
