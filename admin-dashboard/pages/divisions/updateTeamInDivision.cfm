<cfset requestData = getHttpRequestData()>
<cfset requestBody = requestData.content>

<cfif len(trim(requestBody)) GT 0>
    <cftry>
        <cfset data = deserializeJSON(requestBody)>
        <cfset teamID = data.teamID>
        <cfset divisionID = data.divisionID>

        <cfquery name="updateTeamInDivision" datasource="roundleague">
            UPDATE teams
            SET divisionID = <cfqueryparam value="#divisionID#" cfsqltype="cf_sql_integer">
            WHERE teamID = <cfqueryparam value="#teamID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfheader name="Content-Type" value="application/json">
        <cfoutput>{"status":"success"}</cfoutput>

        <cfcatch>
            <cfheader name="Content-Type" value="application/json">
            <cfoutput>{"status":"error","message":"#cfcatch.message#"}</cfoutput>
        </cfcatch>
    </cftry>
<cfelse>
    <cfheader name="Content-Type" value="application/json">
    <cfoutput>{"status":"error","message":"Invalid JSON or empty body"}</cfoutput>
</cfif>
