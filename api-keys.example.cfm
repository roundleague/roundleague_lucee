<!---
  api-keys.example.cfm
  ---------------------
  Copy this file to api-keys.cfm and fill in the values below.
  api-keys.cfm is gitignored — never commit the real keys.
  Contact the lead developer to obtain the actual key values.
--->

<!--- Stripe secret key (from https://dashboard.stripe.com/apikeys) --->
<cfset application.stripeSecretKey = "sk_test_YOUR_STRIPE_SECRET_KEY_HERE">

<!--- Admin API key used to authenticate requests to the Round League API --->
<cfset application.adminApiKey = "YOUR_ADMIN_API_KEY_HERE">

<!---
    Jira Cloud (used by the admin messages page to file tickets from a contact submission).
    Generate an API token at https://id.atlassian.com/manage-profile/security/api-tokens
    jiraEmail is the Atlassian account the token belongs to.
--->
<cfset application.jiraBaseURL  = "https://roundleague.atlassian.net">
<cfset application.jiraEmail    = "YOUR_ATLASSIAN_EMAIL_HERE">
<cfset application.jiraApiToken = "YOUR_JIRA_API_TOKEN_HERE">
<cfset application.jiraProject  = "RL">
