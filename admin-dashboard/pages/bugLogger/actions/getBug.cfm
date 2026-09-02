<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="url.bugID" type="integer">

    <cfquery name="bug" datasource="roundleague">
        SELECT bugID, errorType, errorFile, errorLine, errorMessage, pageURL,
               occurrenceCount,
               DATE_FORMAT(firstSeenAt, '%b %d, %Y %h:%i %p') AS formattedFirstSeen,
               DATE_FORMAT(lastSeenAt,  '%b %d, %Y %h:%i %p') AS formattedLastSeen,
               resolved
        FROM bug_reports
        WHERE bugID = <cfqueryparam value="#url.bugID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif bug.recordCount EQ 0>
        <cfoutput>{"success":false,"message":"Bug not found."}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery name="stats" datasource="roundleague">
        SELECT COUNT(DISTINCT userName) AS uniqueUsers
        FROM bug_occurrences
        WHERE bugID = <cfqueryparam value="#url.bugID#" cfsqltype="cf_sql_integer">
          AND userName IS NOT NULL AND userName <> ''
    </cfquery>

    <cfquery name="recentOccurrences" datasource="roundleague">
        SELECT userName, deployVersion, pageURL,
               DATE_FORMAT(occurredAt, '%b %d, %Y %h:%i %p') AS formattedOccurredAt
        FROM bug_occurrences
        WHERE bugID = <cfqueryparam value="#url.bugID#" cfsqltype="cf_sql_integer">
        ORDER BY occurredAt DESC
        LIMIT 10
    </cfquery>

    <cfset recentArr = []>
    <cfloop query="recentOccurrences">
        <cfset arrayAppend(recentArr, {
            "userName": len(trim(userName)) ? userName : "Unknown",
            "deployVersion": len(trim(deployVersion)) ? deployVersion : "unknown",
            "pageURL": pageURL,
            "occurredAt": formattedOccurredAt
        })>
    </cfloop>

    <cfset result = {
        "success": true,
        "bug": {
            "bugID":             bug.bugID,
            "errorType":         bug.errorType,
            "errorFile":         bug.errorFile,
            "errorLine":         bug.errorLine,
            "errorMessage":      bug.errorMessage,
            "pageURL":           bug.pageURL,
            "occurrenceCount":   bug.occurrenceCount,
            "uniqueUsers":       stats.uniqueUsers,
            "firstSeenAt":       bug.formattedFirstSeen,
            "lastSeenAt":        bug.formattedLastSeen,
            "resolved":          bug.resolved,
            "recentOccurrences": recentArr
        }
    }>
    <cfoutput>#serializeJSON(result)#</cfoutput>

    <cfcatch type="any">
        <cfoutput>{"success":false,"message":"An error occurred."}</cfoutput>
    </cfcatch>
</cftry>
