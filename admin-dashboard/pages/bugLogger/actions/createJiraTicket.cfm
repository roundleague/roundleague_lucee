<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="form.bugID"       default="">
    <cfparam name="form.summary"     default="">
    <cfparam name="form.description" default="">

    <cfif NOT isNumeric(form.bugID) OR NOT len(trim(form.summary))>
        <cfoutput>{"success":false,"message":"Invalid parameters."}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery name="checkBug" datasource="roundleague">
        SELECT bugID, jiraKey FROM bug_reports
        WHERE bugID = <cfqueryparam value="#int(form.bugID)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif checkBug.recordCount EQ 0>
        <cfoutput>{"success":false,"message":"Bug not found."}</cfoutput>
        <cfabort>
    </cfif>

    <cfif len(trim(checkBug.jiraKey))>
        <cfoutput>{"success":false,"message":"A Jira ticket already exists for this bug: #checkBug.jiraKey#"}</cfoutput>
        <cfabort>
    </cfif>

    <cfset jiraResult = createObject("component", "library.jira").createTicket(form.summary, form.description)>

    <cfif jiraResult.success>
        <cfquery datasource="roundleague">
            UPDATE bug_reports
            SET jiraKey = <cfqueryparam value="#jiraResult.ticketKey#" cfsqltype="cf_sql_varchar">,
                jiraURL = <cfqueryparam value="#jiraResult.ticketURL#" cfsqltype="cf_sql_varchar">
            WHERE bugID = <cfqueryparam value="#int(form.bugID)#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cfif>

    <cfoutput>#serializeJSON(jiraResult)#</cfoutput>

    <cfcatch type="any">
        <cfset createObject("component", "library.bugLogger").logBug(cfcatch)>
        <cfset result = { "success": false, "message": "Server error: " & cfcatch.message }>
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcatch>
</cftry>
