<cfheader name="Content-Type" value="application/json">
<cftry>
    <!---
        JIRA CONFIGURATION
        Set these variables to match your Jira Cloud instance.
        Add them to your api-keys.cfm or set them as environment variables.
    --->
    <cfset jiraBaseURL  = isDefined("application.jiraBaseURL")  ? application.jiraBaseURL  : "https://your-domain.atlassian.net">
    <cfset jiraEmail    = isDefined("application.jiraEmail")    ? application.jiraEmail    : "">
    <cfset jiraApiToken = isDefined("application.jiraApiToken") ? application.jiraApiToken : "">
    <cfset jiraProject  = isDefined("application.jiraProject")  ? application.jiraProject  : "RL">

    <cfif NOT len(trim(jiraEmail)) OR NOT len(trim(jiraApiToken)) OR jiraBaseURL CONTAINS "your-domain">
        <cfoutput>{"success":false,"message":"Jira is not configured. Add jiraBaseURL, jiraEmail, jiraApiToken, and jiraProject to api-keys.cfm."}</cfoutput>
        <cfabort>
    </cfif>

    <cfparam name="form.messageID"    default="">
    <cfparam name="form.summary"      default="">
    <cfparam name="form.description"  default="">

    <cfif NOT isNumeric(form.messageID) OR NOT len(trim(form.summary))>
        <cfoutput>{"success":false,"message":"Invalid parameters."}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery name="checkMsg" datasource="roundleague">
        SELECT messageID, jiraKey FROM contact_messages
        WHERE messageID = <cfqueryparam value="#int(form.messageID)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif checkMsg.recordCount EQ 0>
        <cfoutput>{"success":false,"message":"Message not found."}</cfoutput>
        <cfabort>
    </cfif>

    <cfif len(trim(checkMsg.jiraKey))>
        <cfoutput>{"success":false,"message":"A Jira ticket already exists for this message: #checkMsg.jiraKey#"}</cfoutput>
        <cfabort>
    </cfif>

    <cfset authHeader = "Basic " & toBase64(jiraEmail & ":" & jiraApiToken)>

    <cfset ticketBody = {
        "fields": {
            "project": { "key": jiraProject },
            "summary": trim(form.summary),
            "description": {
                "type": "doc",
                "version": 1,
                "content": [
                    {
                        "type": "paragraph",
                        "content": [
                            {
                                "type": "text",
                                "text": trim(form.description)
                            }
                        ]
                    }
                ]
            },
            "issuetype": { "name": "Task" }
        }
    }>

    <cfhttp method="POST"
            url="#jiraBaseURL#/rest/api/3/issue"
            result="jiraResponse"
            timeout="15">
        <cfhttpparam type="header" name="Authorization" value="#authHeader#">
        <cfhttpparam type="header" name="Content-Type" value="application/json">
        <cfhttpparam type="header" name="Accept" value="application/json">
        <cfhttpparam type="body" value="#serializeJSON(ticketBody)#">
    </cfhttp>

    <cfset responseData = deserializeJSON(jiraResponse.fileContent)>

    <cfif jiraResponse.statusCode EQ "201 Created">
        <cfset ticketKey = responseData.key>
        <cfset ticketURL = jiraBaseURL & "/browse/" & ticketKey>

        <cfquery datasource="roundleague">
            UPDATE contact_messages
            SET jiraKey = <cfqueryparam value="#ticketKey#" cfsqltype="cf_sql_varchar">,
                jiraURL = <cfqueryparam value="#ticketURL#" cfsqltype="cf_sql_varchar">
            WHERE messageID = <cfqueryparam value="#int(form.messageID)#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result = { "success": true, "ticketKey": ticketKey, "ticketURL": ticketURL }>
        <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfelse>
        <cfset errMsg = "Jira API error (#jiraResponse.statusCode#)">
        <cfif isStruct(responseData) AND structKeyExists(responseData, "errorMessages") AND arrayLen(responseData.errorMessages)>
            <cfset errMsg = errMsg & ": " & responseData.errorMessages[1]>
        </cfif>
        <cfset result = { "success": false, "message": errMsg }>
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfif>

    <cfcatch type="any">
        <cfoutput>{"success":false,"message":"An error occurred while creating the Jira ticket."}</cfoutput>
    </cfcatch>
</cftry>
