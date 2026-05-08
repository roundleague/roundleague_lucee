<cfparam name="form.paymentID" default="0">
<cfparam name="form.paymentType" default="">
<cfparam name="form.amount" default="0">
<cfparam name="form.paymentMethod" default="">
<cfparam name="form.notes" default="">
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

    <cfif NOT isNumeric(form.amount) OR form.amount LE 0>
        <cfthrow message="Amount must be greater than 0">
    </cfif>

    <cfif form.paymentType EQ "team">
        <cfquery datasource="roundleague">
            UPDATE team_payments SET
                amount_paid = <cfqueryparam value="#form.amount#" cfsqltype="cf_sql_decimal">,
                payment_method = <cfqueryparam value="#form.paymentMethod#" cfsqltype="cf_sql_varchar">,
                stripe_session_id = <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#form.paymentID#" cfsqltype="cf_sql_integer">
            AND team_id = <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset success = true>
        <cfset message = "Team payment updated">
    <cfelseif form.paymentType EQ "player">
        <cfquery datasource="roundleague">
            UPDATE player_payment_contributions SET
                amount = <cfqueryparam value="#form.amount#" cfsqltype="cf_sql_decimal">,
                stripe_session_id = <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#form.paymentID#" cfsqltype="cf_sql_integer">
            AND team_id = <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset success = true>
        <cfset message = "Player contribution updated">
    <cfelse>
        <cfthrow message="Invalid payment type">
    </cfif>

<cfcatch>
    <cfset message = cfcatch.message>
</cfcatch>
</cftry>

<cfcontent type="application/json">
<cfoutput>{"success": #success#, "message": "#jsStringFormat(message)#"}</cfoutput>
