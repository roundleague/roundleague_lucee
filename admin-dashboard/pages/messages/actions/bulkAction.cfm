<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="form.action" default="">
    <cfparam name="form.ids" default="">

    <cfset allowedActions = ["markRead", "markUnread", "delete", "deleteAllSpam"]>
    <cfif NOT arrayFind(allowedActions, form.action)>
        <cfoutput>{"success":false,"message":"Invalid action."}</cfoutput>
        <cfabort>
    </cfif>

    <cfif form.action EQ "deleteAllSpam">
        <cfquery datasource="roundleague">
            DELETE FROM contact_messages WHERE isSpam = 1
        </cfquery>
        <cfoutput>{"success":true}</cfoutput>
        <cfabort>
    </cfif>

    <cfif NOT len(trim(form.ids))>
        <cfoutput>{"success":false,"message":"No IDs provided."}</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate and sanitize IDs - only allow integers --->
    <cfset idList = []>
    <cfloop list="#form.ids#" index="rawID">
        <cfset cleanID = trim(rawID)>
        <cfif isNumeric(cleanID) AND int(cleanID) EQ cleanID AND cleanID GT 0>
            <cfset arrayAppend(idList, int(cleanID))>
        </cfif>
    </cfloop>

    <cfif arrayLen(idList) EQ 0>
        <cfoutput>{"success":false,"message":"No valid IDs provided."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset idCSV = arrayToList(idList)>

    <cfif form.action EQ "markRead">
        <cfquery datasource="roundleague">
            UPDATE contact_messages
            SET isRead = 1
            WHERE messageID IN (<cfqueryparam value="#idCSV#" cfsqltype="cf_sql_integer" list="true">)
        </cfquery>
    <cfelseif form.action EQ "markUnread">
        <cfquery datasource="roundleague">
            UPDATE contact_messages
            SET isRead = 0
            WHERE messageID IN (<cfqueryparam value="#idCSV#" cfsqltype="cf_sql_integer" list="true">)
        </cfquery>
    <cfelseif form.action EQ "delete">
        <cfquery datasource="roundleague">
            DELETE FROM contact_messages
            WHERE messageID IN (<cfqueryparam value="#idCSV#" cfsqltype="cf_sql_integer" list="true">)
        </cfquery>
    </cfif>

    <cfoutput>{"success":true}</cfoutput>

    <cfcatch type="any">
        <cfset createObject("component", "library.bugLogger").logBug(cfcatch)>
        <cfoutput>{"success":false,"message":"An error occurred."}</cfoutput>
    </cfcatch>
</cftry>
