<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="form.action" default="">
    <cfparam name="form.bugID" default="">

    <cfset allowedActions = ["resolve", "unresolve"]>
    <cfif NOT arrayFind(allowedActions, form.action)>
        <cfoutput>{"success":false,"message":"Invalid action."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset cleanID = trim(form.bugID)>
    <cfif NOT (isNumeric(cleanID) AND int(cleanID) EQ cleanID AND cleanID GT 0)>
        <cfoutput>{"success":false,"message":"Invalid bug ID."}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery datasource="roundleague">
        UPDATE bug_reports
        SET resolved = <cfqueryparam value="#(form.action EQ 'resolve' ? 1 : 0)#" cfsqltype="cf_sql_tinyint">
        WHERE bugID = <cfqueryparam value="#int(cleanID)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfoutput>{"success":true}</cfoutput>

    <cfcatch type="any">
        <cfoutput>{"success":false,"message":"An error occurred."}</cfoutput>
    </cfcatch>
</cftry>
