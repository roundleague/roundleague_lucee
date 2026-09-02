<!---
    Shared spam/bot classifier for contact form submissions.

    Sets request.spamResult = {
        blocked      : boolean - true if this should NOT go in the real inbox
        silentDrop   : boolean - true if we should pretend it succeeded and file it in the spam bucket
        userMessage  : string  - message to show a real user (only set when NOT silentDrop)
        reason       : string  - short category token (honeypot|too_fast|sqli|too_many_urls|rate_limit|"")
        anomalous   : boolean  - true for hostile-looking payloads (SQLi, excessive URLs)
    }

    Expects form fields:
      form.website  - honeypot (must be empty)
      form.fLoad    - epoch seconds when the form was rendered
--->
<cfparam name="form.website" default="">
<cfparam name="form.url"     default="">
<cfparam name="form.fLoad"   default="0">

<cfset request.spamResult = {
    blocked     : false,
    silentDrop  : false,
    userMessage : "",
    reason      : "",
    anomalous   : false
}>

<cfset spamBodyRaw    = isDefined("form.contactMessage") ? form.contactMessage : "">
<cfset spamSubjectRaw = isDefined("form.contactSubject") ? form.contactSubject : "">
<cfset spamEmailRaw   = isDefined("form.contactEmail")   ? form.contactEmail   : "">
<cfset spamHaystack   = lCase(spamBodyRaw & " " & spamSubjectRaw & " " & spamEmailRaw)>

<!--- Honeypot: the "website" and "url" fields are offscreen decoys added to each contact form. Real users never see or fill them; bot autofill scripts do. --->
<cfif len(trim(form.website)) OR len(trim(form.url))>
    <cfset request.spamResult.blocked    = true>
    <cfset request.spamResult.silentDrop = true>
    <cfset request.spamResult.reason     = "honeypot">
</cfif>

<cfif NOT request.spamResult.blocked>
    <cfset loadTs = isNumeric(form.fLoad) ? int(form.fLoad) : 0>
    <cfset nowSec = int(getTickCount() / 1000)>
    <cfset ageSec = nowSec - loadTs>
    <cfif loadTs LTE 0 OR ageSec LT 3 OR ageSec GT 86400>
        <cfset request.spamResult.blocked    = true>
        <cfset request.spamResult.silentDrop = true>
        <cfset request.spamResult.reason     = "too_fast">
    </cfif>
</cfif>

<cfif NOT request.spamResult.blocked>
    <cfset sqliPattern = "(?i)(\bunion\s+(all\s+)?select\b|\bselect\s+.+\s+from\b|\bdrop\s+table\b|\binsert\s+into\b|\bupdate\s+\w+\s+set\b|\bdelete\s+from\b|\bor\s+1\s*=\s*1\b|\band\s+1\s*=\s*1\b|\bwaitfor\s+delay\b|\bxp_cmdshell\b|\bexec\s*\(|/\*.*\*/|\bsleep\s*\(|\bbenchmark\s*\(|\bload_file\s*\(|\binto\s+outfile\b|\bchar\s*\(\s*\d+\s*,)">
    <cfif reFindNoCase(sqliPattern, spamHaystack)>
        <cfset request.spamResult.blocked    = true>
        <cfset request.spamResult.silentDrop = true>
        <cfset request.spamResult.reason     = "sqli">
        <cfset request.spamResult.anomalous  = true>
    </cfif>
</cfif>

<cfif NOT request.spamResult.blocked>
    <cfset urlHits = reMatchNoCase("https?://", spamHaystack)>
    <cfif arrayLen(urlHits) GTE 3>
        <cfset request.spamResult.blocked    = true>
        <cfset request.spamResult.silentDrop = true>
        <cfset request.spamResult.reason     = "too_many_urls">
        <cfset request.spamResult.anomalous  = true>
    <cfelseif reFindNoCase("\[url=|\[/url\]", spamHaystack)>
        <cfset request.spamResult.blocked    = true>
        <cfset request.spamResult.silentDrop = true>
        <cfset request.spamResult.reason     = "too_many_urls">
        <cfset request.spamResult.anomalous  = true>
    </cfif>
</cfif>

<cfif NOT request.spamResult.blocked>
    <cfset clientIP  = len(trim(CGI.HTTP_X_FORWARDED_FOR)) ? listFirst(CGI.HTTP_X_FORWARDED_FOR) : CGI.REMOTE_ADDR>
    <cfset clientIP  = trim(clientIP)>
    <cfif NOT len(clientIP)><cfset clientIP = "unknown"></cfif>
    <cfset rateGate  = createObject("component", "api.RateLimiter").check("contact_" & clientIP, 3, 600)>
    <cfif NOT rateGate.allowed>
        <cfset request.spamResult.blocked     = true>
        <cfset request.spamResult.silentDrop  = false>
        <cfset request.spamResult.reason      = "rate_limit">
        <cfset request.spamResult.userMessage = "You've sent several messages recently. Please wait a few minutes and try again.">
    </cfif>
</cfif>

<!--- Log every blocked submission to security_events. Silent on DB failure — spam
      logging must never break the contact form flow. --->
<cfif request.spamResult.blocked>
    <cftry>
        <cfset logIP = isDefined("clientIP") ? clientIP
                       : (len(trim(CGI.HTTP_X_FORWARDED_FOR)) ? listFirst(CGI.HTTP_X_FORWARDED_FOR) : CGI.REMOTE_ADDR)>
        <cfquery datasource="roundleague">
            INSERT INTO security_events (eventType, clientIP, subject, reason, anomalous)
            VALUES (
                <cfqueryparam value="#request.spamResult.reason#"       cfsqltype="cf_sql_varchar" maxlength="50">,
                <cfqueryparam value="#left(trim(logIP), 45)#"           cfsqltype="cf_sql_varchar" maxlength="45">,
                <cfqueryparam value="#left(spamSubjectRaw, 255)#"       cfsqltype="cf_sql_varchar" maxlength="255">,
                <cfqueryparam value="#left(request.spamResult.userMessage, 255)#" cfsqltype="cf_sql_varchar" maxlength="255">,
                <cfqueryparam value="#request.spamResult.anomalous ? 1 : 0#" cfsqltype="cf_sql_tinyint">
            )
        </cfquery>
        <cfcatch type="any"></cfcatch>
    </cftry>
</cfif>
