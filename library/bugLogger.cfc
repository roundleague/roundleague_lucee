<!--- Bug Logger Component
      Writes exceptions into bug_reports (deduped by fingerprint) and bug_occurrences (raw log).
      Called from Application.cfc onError() for uncaught exceptions, and from <cfcatch> blocks
      in action files that swallow errors to return a JSON response. Silent on DB failure so
      logging a bug never masks the original problem. --->
<cfcomponent displayname="BugLogger" hint="Central helper for recording exceptions into the bug logger tables">

  <cffunction name="logBug" returntype="string" output="false"
              hint="Record an exception. Accepts either an onError exception struct or a cfcatch struct (same shape). Returns the fingerprint hash so callers can use it for rate-limiting (e.g. dedup emails).">
    <cfargument name="exception" type="any"    required="true">
    <cfargument name="pageURL"   type="string" required="false" default="#CGI.SCRIPT_NAME & (len(CGI.QUERY_STRING) ? '?' & CGI.QUERY_STRING : '')#">

    <cfset var fingerprint = "">

    <cftry>
      <cfset var errType = structKeyExists(arguments.exception, "type")    ? left(arguments.exception.type, 200) : "Unknown">
      <cfset var errMsg  = structKeyExists(arguments.exception, "message") ? arguments.exception.message         : "">
      <cfset var errFile = arguments.pageURL>
      <cfset var errLine = 0>

      <cfif structKeyExists(arguments.exception, "tagContext")
            AND isArray(arguments.exception.tagContext)
            AND arrayLen(arguments.exception.tagContext)>
        <cfset var topContext = arguments.exception.tagContext[1]>
        <cfif structKeyExists(topContext, "template")>
          <cfset errFile = left(topContext.template, 500)>
        </cfif>
        <cfif structKeyExists(topContext, "line")>
          <cfset errLine = topContext.line>
        </cfif>
      </cfif>

      <cfset fingerprint       = hash(errType & "|" & errFile & "|" & errLine, "MD5")>
      <cfset var userName      = (isDefined("session.userName") AND len(trim(session.userName))) ? session.userName : "">
      <cfset var deployVersion = isDefined("application.deployVersion") ? application.deployVersion : "unknown">
      <cfset var upsertResult  = "">

      <cfset queryExecute(
        "INSERT INTO bug_reports
            (fingerprintHash, errorType, errorFile, errorLine, errorMessage, pageURL, occurrenceCount, firstSeenAt, lastSeenAt, resolved)
         VALUES
            (:fingerprintHash, :errorType, :errorFile, :errorLine, :errorMessage, :pageURL, 1, NOW(), NOW(), 0)
         ON DUPLICATE KEY UPDATE
            bugID = LAST_INSERT_ID(bugID),
            occurrenceCount = occurrenceCount + 1,
            lastSeenAt = NOW(),
            resolved = 0",
        {
          fingerprintHash: { value: fingerprint,       cfsqltype: "cf_sql_varchar" },
          errorType:       { value: errType,           cfsqltype: "cf_sql_varchar" },
          errorFile:       { value: errFile,           cfsqltype: "cf_sql_varchar" },
          errorLine:       { value: errLine,           cfsqltype: "cf_sql_integer" },
          errorMessage:    { value: errMsg,            cfsqltype: "cf_sql_longvarchar" },
          pageURL:         { value: arguments.pageURL, cfsqltype: "cf_sql_varchar" }
        },
        { datasource: "roundleague", result: "upsertResult" }
      )>

      <cfset var bugID = upsertResult.generatedKey>

      <cfset queryExecute(
        "INSERT INTO bug_occurrences (bugID, occurredAt, userName, deployVersion, pageURL)
         VALUES (:bugID, NOW(), :userName, :deployVersion, :pageURL)",
        {
          bugID:         { value: bugID,             cfsqltype: "cf_sql_integer" },
          userName:      { value: userName,          cfsqltype: "cf_sql_varchar", null: (len(userName) EQ 0) },
          deployVersion: { value: deployVersion,     cfsqltype: "cf_sql_varchar" },
          pageURL:       { value: arguments.pageURL, cfsqltype: "cf_sql_varchar" }
        },
        { datasource: "roundleague" }
      )>

      <cfcatch type="any"></cfcatch>
    </cftry>

    <cfreturn fingerprint>
  </cffunction>

</cfcomponent>
