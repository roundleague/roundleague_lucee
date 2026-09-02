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

    <!--- Jira's Atlassian Document Format rejects raw \n inside a text node. Split the description into one paragraph per line. --->
    <cfset descNormalized = replace(form.description, chr(13) & chr(10), chr(10), "all")>
    <cfset descNormalized = replace(descNormalized,   chr(13),            chr(10), "all")>
    <cfset descLines      = listToArray(descNormalized, chr(10), false)>
    <cfset descParagraphs = []>
    <cfloop array="#descLines#" index="descLine">
        <cfset descLineClean = trim(descLine)>
        <cfif len(descLineClean)>
            <cfset arrayAppend(descParagraphs, {
                "type": "paragraph",
                "content": [ { "type": "text", "text": descLineClean } ]
            })>
        </cfif>
    </cfloop>
    <cfif arrayLen(descParagraphs) EQ 0>
        <cfset arrayAppend(descParagraphs, {
            "type": "paragraph",
            "content": [ { "type": "text", "text": " " } ]
        })>
    </cfif>

    <cfset ticketBody = {
        "fields": {
            "project": { "key": jiraProject },
            "summary": trim(form.summary),
            "description": {
                "type": "doc",
                "version": 1,
                "content": descParagraphs
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

    <cfset rawBody = toString(jiraResponse.fileContent)>
    <cfset responseData = isJSON(rawBody) ? deserializeJSON(rawBody) : "">

    <cfif left(jiraResponse.statusCode, 3) EQ "201">
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
        <cfset errParts = ["Jira API error (#jiraResponse.statusCode#)"]>
        <cfif isStruct(responseData)>
            <cfif structKeyExists(responseData, "errorMessages") AND arrayLen(responseData.errorMessages)>
                <cfset arrayAppend(errParts, arrayToList(responseData.errorMessages, "; "))>
            </cfif>
            <cfif structKeyExists(responseData, "errors") AND isStruct(responseData.errors)>
                <cfloop collection="#responseData.errors#" item="fieldName">
                    <cfset arrayAppend(errParts, fieldName & ": " & responseData.errors[fieldName])>
                </cfloop>
            </cfif>
        <cfelseif len(rawBody)>
            <cfset arrayAppend(errParts, left(rawBody, 300))>
        </cfif>
        <cfset shortMessage = arrayToList(errParts, " | ")>

        <!--- Atlassian API tokens expire 1 year after creation. Current token expires 2027-09-01.
              401, or the misleading "project doesn't exist" 400 that Jira returns for scoped/expired tokens,
              usually means the token needs to be regenerated as a classic (unscoped) token.
              Log the hint to the jira_integration log rather than surfacing it in the banner. --->
        <cfset wwwAuthHeader = structKeyExists(jiraResponse.responseHeader, "Www-Authenticate") ? jiraResponse.responseHeader["Www-Authenticate"] : "">
        <cfset looksLikeAuthFailure = (left(jiraResponse.statusCode, 3) EQ "401")
                                       OR (wwwAuthHeader CONTAINS "OAuth")
                                       OR (shortMessage CONTAINS "target project doesn't exist")>
        <cfif looksLikeAuthFailure>
            <cflog file="jira_integration" type="error"
                   text="Jira auth failure — token may be expired (created 2026-09-01, expires 2027-09-01) or is a scoped token. Regenerate a CLASSIC (unscoped) token at https://id.atlassian.com/manage-profile/security/api-tokens and update api-keys.cfm. statusCode=#jiraResponse.statusCode# wwwAuth=#wwwAuthHeader# response=#shortMessage#" />
        <cfelse>
            <cflog file="jira_integration" type="warning"
                   text="Jira API error statusCode=#jiraResponse.statusCode# response=#shortMessage#" />
        </cfif>

        <cfset result = { "success": false, "message": shortMessage }>
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfif>

    <cfcatch type="any">
        <cfset createObject("component", "library.bugLogger").logBug(cfcatch)>
        <cfset result = { "success": false, "message": "Server error: " & cfcatch.message }>
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcatch>
</cftry>
