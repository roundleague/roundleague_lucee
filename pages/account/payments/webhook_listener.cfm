<cfcontent type="application/json" />
<cftry>
    <!-- Use CF's own input stream -->
    <cfset rawJson = ToString(getHttpRequestData().content)>
    <cfset stripeEvent = deserializeJson(rawJson)>

    <!-- DEBUG log -->
    <!--- <cffile action="append" file="#expandPath('./webhook_log.txt')#" output="#now()# - #rawJson#" addnewline="yes"> --->

    <!-- Handle the event -->
    <cfif stripeEvent.type EQ "checkout.session.completed">
        <cfset sessionObj = stripeEvent.data.object>
        <cfset stripeSessionID = sessionObj.id>
        <cfset amountPaid = sessionObj.amount_total / 100>
        <cfset paymentMethod = "stripe">
        <cfset metadata = sessionObj.metadata>

        <!-- Safe fallback for test events -->
        <cfset playerID = structKeyExists(metadata, "player_id") ? metadata.player_id : 0>
        <cfset teamID = structKeyExists(metadata, "team_id") ? metadata.team_id : 0>
        <cfset season = structKeyExists(metadata, "season") ? metadata.season : 0>

        <!-- Insert into DB -->
        <cfquery datasource="roundleague">
            INSERT INTO team_payments (
                team_id, season, amount_paid, payment_method, paid_by_player_id, stripe_session_id
            ) VALUES (
                <cfqueryparam value="#teamID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#season#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#amountPaid#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#paymentMethod#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#playerID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#stripeSessionID#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
    </cfif>

    <!-- Respond success -->
    <cfheader statuscode="200" statustext="OK">
    <cfoutput>{"received": true}</cfoutput>

<cfcatch>
    <!-- Log the error -->
    <cffile action="append" file="#expandPath('./webhook_log.txt')#" output="ERROR: #cfcatch.message#" addnewline="yes">
    <cfheader statuscode="400" statustext="Bad Request">
    <cfoutput>{"error": "#cfcatch.message#"}</cfoutput>
</cfcatch>
</cftry>
