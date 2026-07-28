<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="url.bugID" type="integer">

    <cfquery name="bug" datasource="roundleague">
        SELECT bugID, errorType, LEFT(errorMessage, 100) AS errorMessage, pageURL,
               DATE_FORMAT(createdAt, '%b %d, %Y %h:%i %p') AS formattedDate,
               resolved
        FROM bug_reports
        WHERE bugID = <cfqueryparam value="#url.bugID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif bug.recordCount EQ 0>
        <cfoutput>{"success":false,"message":"Bug not found."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset result = {
        "success": true,
        "bug": {
            "bugID":        bug.bugID,
            "errorType":    bug.errorType,
            "errorMessage": bug.errorMessage,
            "pageURL":      bug.pageURL,
            "createdAt":    bug.formattedDate,
            "resolved":     bug.resolved
        }
    }>
    <cfoutput>#serializeJSON(result)#</cfoutput>

    <cfcatch type="any">
        <cfoutput>{"success":false,"message":"An error occurred."}</cfoutput>
    </cfcatch>
</cftry>
