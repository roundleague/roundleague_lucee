<cfset requestData = getHttpRequestData()>
<cfset requestBody = requestData.content>

<cfif len(trim(requestBody)) GT 0>
    <cfset data = deserializeJSON(requestBody)>
    <cfset teamName = data.teamName>
    <cfset currentSeasonID = session.currentSeasonID>
    
    <!--- Insert new team into the database --->
    <cfquery name="insertNewTeam" datasource="roundleague">
        INSERT INTO teams (status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID)
        VALUES (
            'Active', 
            <cfqueryparam value="#teamName#" cfsqltype="cf_sql_varchar">, 
            0, 
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
            0, 
            <cfqueryparam value="#currentSeasonID#" cfsqltype="cf_sql_integer">
        )
    </cfquery>
    
    <!--- Get the ID of the newly inserted team --->
    <cfquery name="getNewTeamID" datasource="roundleague">
        SELECT @@IDENTITY AS newTeamID
    </cfquery>
    
    <cfheader name="Content-Type" value="application/json">
    <cfoutput>
        {"status":"success","teamID":#getNewTeamID.newTeamID#}
    </cfoutput>
<cfelse>
    <cfheader name="Content-Type" value="application/json">
    <cfoutput>
        {"status":"error","message":"Invalid JSON or empty body"}
    </cfoutput>
</cfif>
