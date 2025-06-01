<!-- /pages/account/account_stripe_checkout.cfm -->

<cfoutput>
<cfinclude template="../account_security_check.cfm">

<cfset stripeSecretKey = application.stripeSecretKey>

<!-- Set different price IDs for captain and player payments -->
<cfset fullTeamFeePriceID = "price_1RUck2PQ2d9e9sciYmKuycNv">
<cfset playerContributionPriceID = "price_2RUck2PQ2d9e9sciYmKuycNv"> <!-- Replace this with your actual player contribution price ID -->

<!-- Get info from URL -->
<cfset teamID = url.teamID>
<cfset playerID = url.playerID>
<cfset paymentType = isDefined("url.paymentType") ? url.paymentType : "player"> <!-- Default to player if not specified -->

<!-- Set amount and price ID based on payment type -->
<cfif paymentType EQ "captain">
    <cfset stripePriceID = fullTeamFeePriceID>
    <cfset paymentAmount = isDefined("url.amount") ? url.amount : 1000>
<cfelse>
    <cfset stripePriceID = playerContributionPriceID>
    <cfset paymentAmount = isDefined("url.amount") ? url.amount : 100>
</cfif>

<cfset protocol = cgi.server_name CONTAINS "127.0.0.1" ? "http" : "https">

<!-- Create Stripe Checkout Session -->
<cfhttp url="https://api.stripe.com/v1/checkout/sessions" method="post" result="stripeResponse">
  <cfhttpparam type="header" name="Authorization" value="Bearer #stripeSecretKey#">
  <cfhttpparam type="formField" name="success_url" value="#protocol#://#cgi.http_host#/pages/account/payments/payment_success.cfm?session_id={CHECKOUT_SESSION_ID}&playerID=#playerID#">
  <cfhttpparam type="formField" name="cancel_url" value="#protocol#://#cgi.http_host#/pages/account/account_home.cfm?playerID=#playerID#">  <cfhttpparam type="formField" name="mode" value="payment">
  <cfhttpparam type="formField" name="line_items[0][quantity]" value="1">
  <cfhttpparam type="formField" name="line_items[0][price_data][currency]" value="usd">
  <cfhttpparam type="formField" name="line_items[0][price_data][product_data][name]" value="Round League #paymentType# Payment">
  <cfhttpparam type="formField" name="line_items[0][price_data][unit_amount]" value="#paymentAmount * 100#">
  <cfhttpparam type="formField" name="metadata[player_id]" value="#playerID#">
  <cfhttpparam type="formField" name="metadata[team_id]" value="#teamID#">
  <cfhttpparam type="formField" name="metadata[season]" value="#session.currentSeasonID#">
  <cfhttpparam type="formField" name="metadata[payment_type]" value="#paymentType#">
</cfhttp>

<cfset stripeData = deserializeJSON(stripeResponse.fileContent)>
<cfif structKeyExists(stripeData, "url")>
  <cflocation url="#stripeData.url#" addtoken="no">
<cfelse>
  <p>Failed to create Stripe Checkout session.</p>
  <cfdump var="#stripeData#">
</cfif>
</cfoutput>
