<cfparam name="url.q" default="">

<cfif len(trim(url.q)) gte 2>
  <cfquery name="searchPlayers" datasource="roundleague">
    SELECT p.playerID,
           CONCAT(p.firstName, ' ', p.lastName) AS playerName,
           p.email,
           p.firstName,
           p.lastName
    FROM players p
    WHERE (
      p.firstName LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(url.q)#%">
      OR p.lastName LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(url.q)#%">
      OR CONCAT(p.firstName, ' ', p.lastName) LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(url.q)#%">
    )
    AND (p.mergedIntoPlayerID IS NULL)
    ORDER BY p.firstName, p.lastName
    LIMIT 20
  </cfquery>

  <cfset results = []>
  <cfloop query="searchPlayers">
    <cfset arrayAppend(results, {
      "playerID": playerID,
      "playerName": playerName,
      "email": email
    })>
  </cfloop>

  <cfcontent type="application/json">
  <cfoutput>#serializeJSON({"players": results})#</cfoutput>
<cfelse>
  <cfcontent type="application/json">
  <cfoutput>#serializeJSON({"players": []})#</cfoutput>
</cfif>
