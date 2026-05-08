<cfparam name="form.paymentID" default="0">
<cfparam name="form.paymentType" default="">
<cfparam name="form.teamID" default="0">

<cfset success = false>
<cfset message = "">

<cftry>
    <cfif NOT isNumeric(form.paymentID) OR form.paymentID EQ 0>
        <cfthrow message="Invalid payment ID">
    </cfif>

    <cfif NOT isNumeric(form.teamID) OR form.teamID EQ 0>
        <cfthrow message="Invalid team ID">
    </cfif>

    <cfif form.paymentType EQ "team">
        <cfquery datasource="roundleague">
            DELETE FROM team_payments
            WHERE id = <cfqueryparam value="#form.paymentID#" cfsqltype="cf_sql_integer">
            AND team_id = <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset success = true>
        <cfset message = "Team payment deleted">
    <cfelseif form.paymentType EQ "player">
        <cfquery datasource="roundleague">
            DELETE FROM player_payment_contributions
            WHERE id = <cfqueryparam value="#form.paymentID#" cfsqltype="cf_sql_integer">
            AND team_id = <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset success = true>
        <cfset message = "Player contribution deleted">
    <cfelse>
        <cfthrow message="Invalid payment type">
    </cfif>

<cfcatch>
    <cfset message = cfcatch.message>
</cfcatch>
</cftry>

<cfcontent type="application/json">
<cfoutput>{"success": #success#, "message": "#jsStringFormat(message)#"}</cfoutput>
