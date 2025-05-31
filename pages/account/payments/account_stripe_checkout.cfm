<!-- /pages/account/account_stripe_checkout.cfm -->

<cfoutput>
<cfinclude template="account_security_check.cfm">

<cfset stripeSecretKey = "sk_test_51RSvbjPQ2d9e9sciQOuHZHjmMp62XhIU6XDMC1pKp9M3iec0JmsGjqNV9MI0dntzGskameW1F4F58l4VZtydvfS500swlJm27C" >
<cfset stripePriceID = "price_1RUck2PQ2d9e9sciYmKuycNv" >

<!-- Optional: You can get team/player info here from session or URL -->
<cfset teamID = url.teamID>
<cfset playerID = session.playerID>

<!-- Create Stripe Checkout Session -->
<cfhttp url="https://api.stripe.com/v1/checkout/sessions" method="post" result="stripeResponse">
  <cfhttpparam type="header" name="Authorization" value="Bearer #stripeSecretKey#">
  <cfhttpparam type="formField" name="success_url" value="https://theroundleague.com/pages/account/payment_success.cfm?session_id={CHECKOUT_SESSION_ID}">
  <cfhttpparam type="formField" name="cancel_url" value="https://theroundleague.com/pages/account/payment_cancel.cfm">
  <cfhttpparam type="formField" name="mode" value="payment">
  <cfhttpparam type="formField" name="line_items[0][price]" value="#stripePriceID#">
  <cfhttpparam type="formField" name="line_items[0][quantity]" value="1">
  <cfhttpparam type="formField" name="metadata[player_id]" value="#playerID#">
  <cfhttpparam type="formField" name="metadata[team_id]" value="#teamID#">
</cfhttp>

<cfset stripeData = deserializeJSON(stripeResponse.fileContent)>
<cfif structKeyExists(stripeData, "url")>
  <cflocation url="#stripeData.url#" addtoken="no">
<cfelse>
  <p>Failed to create Stripe Checkout session.</p>
  <cfdump var="#stripeData#">
</cfif>
</cfoutput>
