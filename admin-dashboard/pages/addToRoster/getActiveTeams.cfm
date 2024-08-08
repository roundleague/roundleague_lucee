<cfparam name="url.playerID" default="">
<cfif url.playerID neq "">
  <cfquery name="getTeams" datasource="roundleague">
    SELECT teamID, teamName
    FROM teams
    Where Status = 'Active'
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    UNION
    SELECT 0 as teamID, 'Free Agents' as teamName
    ORDER BY teamName
  </cfquery>

  <cfset gameData = []>
  <cfloop query="getTeams">
    <cfset team = {
      "teamID": teamID,
      "teamName": teamName,
    }>
    <cfset arrayAppend(gameData, team)>
  </cfloop>

  <cfset response = {"games": gameData}>
  <cfcontent type="application/json">
  <cfoutput>#serializeJSON(response)#</cfoutput>
<cfelse>
  <cfset response = {"error": "Invalid player ID"}>
  <cfcontent type="application/json">
  <cfoutput>#serializeJSON(response)#</cfoutput>
</cfif>
