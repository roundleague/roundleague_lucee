<!--- Jira Component
      Wraps the Jira Cloud REST API (v3) so any admin feature can file a ticket without
      re-implementing config checks, ADF description building, auth-failure detection, or logging.
      Callers own their entity's DB write (e.g. saving jiraKey back onto contact_messages / bug_reports). --->
<cfcomponent displayname="Jira" hint="Creates Jira Cloud tickets from admin features (contact messages, bug reports, etc.)">

  <cffunction name="createTicket" returntype="struct" output="false"
              hint="Files a Jira issue. Returns { success, ticketKey, ticketURL, message }. Never throws — caller checks .success.">
    <cfargument name="summary"     type="string" required="true">
    <cfargument name="description" type="string" required="false" default="">

    <cfset var jiraBaseURL  = isDefined("application.jiraBaseURL")  ? application.jiraBaseURL  : "https://your-domain.atlassian.net">
    <cfset var jiraEmail    = isDefined("application.jiraEmail")    ? application.jiraEmail    : "">
    <cfset var jiraApiToken = isDefined("application.jiraApiToken") ? application.jiraApiToken : "">
    <cfset var jiraProject  = isDefined("application.jiraProject")  ? application.jiraProject  : "RL">

    <cfif NOT len(trim(jiraEmail)) OR NOT len(trim(jiraApiToken)) OR jiraBaseURL CONTAINS "your-domain">
      <cfreturn { "success": false, "ticketKey": "", "ticketURL": "",
                  "message": "Jira is not configured. Add jiraBaseURL, jiraEmail, jiraApiToken, and jiraProject to api-keys.cfm." }>
    </cfif>

    <cfif NOT len(trim(arguments.summary))>
      <cfreturn { "success": false, "ticketKey": "", "ticketURL": "", "message": "Summary is required." }>
    </cfif>

    <cfset var authHeader = "Basic " & toBase64(jiraEmail & ":" & jiraApiToken)>

    <!--- Jira's Atlassian Document Format rejects raw \n inside a text node. Split into one paragraph per line. --->
    <cfset var descNormalized = replace(arguments.description, chr(13) & chr(10), chr(10), "all")>
    <cfset descNormalized     = replace(descNormalized,        chr(13),            chr(10), "all")>
    <cfset var descLines      = listToArray(descNormalized, chr(10), false)>
    <cfset var descParagraphs = []>
    <cfset var descLine       = "">
    <cfset var descLineClean  = "">
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

    <cfset var ticketBody = {
      "fields": {
        "project":     { "key": jiraProject },
        "summary":     trim(arguments.summary),
        "description": { "type": "doc", "version": 1, "content": descParagraphs },
        "issuetype":   { "name": "Task" }
      }
    }>

    <cfset var jiraResponse = "">
    <cfhttp method="POST"
            url="#jiraBaseURL#/rest/api/3/issue"
            result="jiraResponse"
            timeout="15">
      <cfhttpparam type="header" name="Authorization" value="#authHeader#">
      <cfhttpparam type="header" name="Content-Type"  value="application/json">
      <cfhttpparam type="header" name="Accept"        value="application/json">
      <cfhttpparam type="body"                        value="#serializeJSON(ticketBody)#">
    </cfhttp>

    <cfset var rawBody      = toString(jiraResponse.fileContent)>
    <cfset var responseData = isJSON(rawBody) ? deserializeJSON(rawBody) : "">

    <cfif left(jiraResponse.statusCode, 3) EQ "201">
      <cfset var ticketKey = responseData.key>
      <cfreturn {
        "success":   true,
        "ticketKey": ticketKey,
        "ticketURL": jiraBaseURL & "/browse/" & ticketKey,
        "message":   ""
      }>
    </cfif>

    <cfset var errParts  = ["Jira API error (#jiraResponse.statusCode#)"]>
    <cfset var fieldName = "">
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
    <cfset var shortMessage = arrayToList(errParts, " | ")>

    <!--- Atlassian API tokens expire 1 year after creation. 401, or the misleading "project doesn't exist"
          400 that Jira returns for scoped/expired tokens, usually means the token needs to be regenerated
          as a classic (unscoped) token. Log the hint rather than surfacing it in the UI banner. --->
    <cfset var wwwAuthHeader       = structKeyExists(jiraResponse.responseHeader, "Www-Authenticate") ? jiraResponse.responseHeader["Www-Authenticate"] : "">
    <cfset var looksLikeAuthFailure = (left(jiraResponse.statusCode, 3) EQ "401")
                                       OR (wwwAuthHeader CONTAINS "OAuth")
                                       OR (shortMessage CONTAINS "target project doesn't exist")>
    <cfif looksLikeAuthFailure>
      <cflog file="jira_integration" type="error"
             text="Jira auth failure — token may be expired or is a scoped token. Regenerate a CLASSIC (unscoped) token at https://id.atlassian.com/manage-profile/security/api-tokens and update api-keys.cfm. statusCode=#jiraResponse.statusCode# wwwAuth=#wwwAuthHeader# response=#shortMessage#" />
    <cfelse>
      <cflog file="jira_integration" type="warning"
             text="Jira API error statusCode=#jiraResponse.statusCode# response=#shortMessage#" />
    </cfif>

    <cfreturn { "success": false, "ticketKey": "", "ticketURL": "", "message": shortMessage }>
  </cffunction>

</cfcomponent>
