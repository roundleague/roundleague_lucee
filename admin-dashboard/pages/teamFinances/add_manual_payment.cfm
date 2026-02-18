<!--- add_manual_payment.cfm - Handles manual payment entry --->
<cfparam name="form.teamID" default="0">
<cfparam name="form.amount" default="0">
<cfparam name="form.paymentType" default="team">
<cfparam name="form.paymentMethod" default="cash">
<cfparam name="form.playerID" default="0">
<cfparam name="form.notes" default="">

<cfset success = false>
<cfset errorMessage = "">

<cftry>
    <cfif form.amount LE 0>
        <cfthrow message="Amount must be greater than 0">
    </cfif>
    
    <cfif form.teamID EQ 0>
        <cfthrow message="Invalid team ID">
    </cfif>
    
    <cfif form.paymentType EQ "team">
        <!--- Insert into team_payments table --->
        <cfquery datasource="roundleague">
            INSERT INTO team_payments (
                team_id, 
                season, 
                amount_paid, 
                payment_method, 
                paid_by_player_id, 
                stripe_session_id
            ) VALUES (
                <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.amount#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.paymentMethod#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.playerID GT 0 ? form.playerID : javaCast('null', '')#" cfsqltype="cf_sql_integer" null="#form.playerID EQ 0#">,
                <cfqueryparam value="MANUAL: #form.notes#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
    <cfelse>
        <!--- Insert into player_payment_contributions table --->
        <cfif form.playerID EQ 0>
            <cfthrow message="Player is required for player contributions">
        </cfif>
        
        <cfquery datasource="roundleague">
            INSERT INTO player_payment_contributions (
                player_id, 
                team_id, 
                season, 
                amount, 
                stripe_session_id
            ) VALUES (
                <cfqueryparam value="#form.playerID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.teamID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.amount#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="MANUAL: #form.notes#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
    </cfif>
    
    <cfset success = true>
    
<cfcatch>
    <cfset errorMessage = cfcatch.message>
</cfcatch>
</cftry>

<!--- Redirect back to team details with success/error message --->
<cfif success>
    <cflocation url="teamFinances.cfm?teamID=#form.teamID#&paymentAdded=1" addtoken="no">
<cfelse>
    <cflocation url="teamFinances.cfm?teamID=#form.teamID#&error=#urlEncodedFormat(errorMessage)#" addtoken="no">
</cfif>
