<cfset requestData = getHttpRequestData()>
<cfset requestBody = requestData.content>

<cfif len(trim(requestBody)) GT 0>
    <cfset data = deserializeJSON(requestBody)>
    <cfset divisionName = data.divisionName>
    <cfset currentSeasonID = session.currentSeasonID>

    <!--- Insert new division into the database --->
    <cfquery name="insertNewDivision" datasource="roundleague">
        INSERT INTO divisions (seasonID, divisionName, isWomens, leagueID)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#currentSeasonID#">,
            <cfqueryparam value="#divisionName#" cfsqltype="cf_sql_varchar">,
            0,
            (SELECT leagueID FROM leagues WHERE leagueName = 'Round League' LIMIT 1)
        )
    </cfquery>
    
    <!--- Get the ID of the newly inserted division --->
    <cfquery name="getNewdivisionID" datasource="roundleague">
        SELECT @@IDENTITY AS newdivisionID
    </cfquery>
    
    <cfheader name="Content-Type" value="application/json">
    <cfoutput>
        {"status":"success","divisionID":#getNewdivisionID.newdivisionID#}
    </cfoutput>
<cfelse>
    <cfheader name="Content-Type" value="application/json">
    <cfoutput>
        {"status":"error","message":"Invalid JSON or empty body"}
    </cfoutput>
</cfif>
