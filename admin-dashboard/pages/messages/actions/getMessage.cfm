<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="url.messageID" type="integer">

    <cfquery name="markRead" datasource="roundleague">
        UPDATE contact_messages
        SET isRead = 1
        WHERE messageID = <cfqueryparam value="#url.messageID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfquery name="msg" datasource="roundleague">
        SELECT messageID, senderEmail, senderPhone, subject, messageBody, consentToContact,
               DATE_FORMAT(createdAt, '%b %d, %Y %h:%i %p') AS formattedDate,
               jiraKey, jiraURL
        FROM contact_messages
        WHERE messageID = <cfqueryparam value="#url.messageID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif msg.recordCount EQ 0>
        <cfoutput>{"success":false,"message":"Message not found."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset result = {
        "success": true,
        "message": {
            "messageID":        msg.messageID,
            "senderEmail":      msg.senderEmail,
            "senderPhone":      msg.senderPhone,
            "subject":          msg.subject,
            "messageBody":      msg.messageBody,
            "consentToContact": msg.consentToContact,
            "createdAt":        msg.formattedDate,
            "jiraKey":          msg.jiraKey,
            "jiraURL":          msg.jiraURL
        }
    }>
    <cfoutput>#serializeJSON(result)#</cfoutput>

    <cfcatch type="any">
        <cfset createObject("component", "library.bugLogger").logBug(cfcatch)>
        <cfoutput>{"success":false,"message":"An error occurred."}</cfoutput>
    </cfcatch>
</cftry>
