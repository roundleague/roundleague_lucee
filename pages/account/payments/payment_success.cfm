<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />

<cfparam name="url.playerID" default="0">
<cfparam name="url.session_id" default="">

<!--- Fallback: Retrieve session from Stripe and record payment if not already saved --->
<cfset paymentRecorded = false>
<cfset paymentError = "">
<cfset amountPaid = 0>
<cfset paymentType = "player">

<cfif len(url.session_id) AND url.session_id NEQ "">
    <cftry>
        <!--- Retrieve the checkout session from Stripe to get payment details --->
        <cfhttp url="https://api.stripe.com/v1/checkout/sessions/#url.session_id#" method="get" result="stripeResponse">
            <cfhttpparam type="header" name="Authorization" value="Bearer #application.stripeSecretKey#">
        </cfhttp>

        <cfset sessionData = deserializeJSON(stripeResponse.fileContent)>

        <cfif structKeyExists(sessionData, "payment_status") AND sessionData.payment_status EQ "paid">
            <cfset amountPaid = sessionData.amount_total / 100>
            <cfset metadata = sessionData.metadata>
            <cfset metaPlayerID = structKeyExists(metadata, "player_id") ? metadata.player_id : url.playerID>
            <cfset metaTeamID = structKeyExists(metadata, "team_id") ? metadata.team_id : 0>
            <cfset metaSeason = structKeyExists(metadata, "season") ? metadata.season : 0>
            <cfset paymentType = structKeyExists(metadata, "payment_type") ? metadata.payment_type : "player">

            <!--- Check if this payment was already recorded (by webhook) --->
            <cfif paymentType EQ "captain">
                <cfquery name="checkExisting" datasource="roundleague">
                    SELECT id FROM team_payments 
                    WHERE stripe_session_id = <cfqueryparam value="#url.session_id#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfif checkExisting.recordCount EQ 0>
                    <cfquery datasource="roundleague">
                        INSERT INTO team_payments (
                            team_id, season, amount_paid, payment_method, paid_by_player_id, stripe_session_id
                        ) VALUES (
                            <cfqueryparam value="#metaTeamID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#metaSeason#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#amountPaid#" cfsqltype="cf_sql_decimal">,
                            'stripe',
                            <cfqueryparam value="#metaPlayerID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#url.session_id#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>
                </cfif>
                <cfset paymentRecorded = true>
            <cfelse>
                <cfquery name="checkExisting" datasource="roundleague">
                    SELECT id FROM player_payment_contributions 
                    WHERE stripe_session_id = <cfqueryparam value="#url.session_id#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfif checkExisting.recordCount EQ 0>
                    <cfquery datasource="roundleague">
                        INSERT INTO player_payment_contributions (
                            player_id, team_id, season, amount, stripe_session_id
                        ) VALUES (
                            <cfqueryparam value="#metaPlayerID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#metaTeamID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#metaSeason#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#amountPaid#" cfsqltype="cf_sql_decimal">,
                            <cfqueryparam value="#url.session_id#" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>
                </cfif>
                <cfset paymentRecorded = true>
            </cfif>
        </cfif>

    <cfcatch>
        <cfset paymentError = cfcatch.message>
    </cfcatch>
    </cftry>
</cfif>

<cfoutput>
<cfinclude template="../account_header.cfm">

<div class="profile-content section">
    <div class="container">
        <div class="row">
            <div class="col-md-10 ml-auto mr-auto">
                <div class="card">
                    <div class="card-header text-center">
                        <i class="fa fa-check-circle text-success" style="font-size: 4rem;"></i>
                        <h4 class="card-title mt-3">Payment Successful!</h4>
                    </div>
                    <div class="card-body text-center">
                        <cfif paymentRecorded>
                            <p>Thank you for your payment of <strong>$#numberFormat(amountPaid, '0.00')#</strong>. Your contribution has been recorded.</p>
                        <cfelse>
                            <p>Thank you for your payment. Your contribution has been recorded.</p>
                        </cfif>
                        <cfif len(paymentError)>
                            <p class="text-warning" style="font-size: 0.8rem;">Note: There was an issue verifying the payment details. Please contact an admin if your payment doesn't appear.</p>
                        </cfif>
                        <p class="text-muted" style="font-size: 0.85rem;">Session ID: #url.session_id#</p>
                        <hr>
                        <a href="/pages/account/payments/payment_status.cfm?playerID=#url.playerID#" class="btn btn-primary btn-round">
                            <i class="fa fa-credit-card-alt"></i> View Payment Status
                        </a>
                        <a href="/pages/account/account_home.cfm?playerID=#url.playerID#" class="btn btn-outline-default btn-round">
                            <i class="fa fa-home"></i> Account Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</cfoutput>

<cfinclude template="/footer.cfm">