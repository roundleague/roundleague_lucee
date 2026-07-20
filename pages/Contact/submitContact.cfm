<cfheader name="Content-Type" value="application/json">
<cftry>
    <cfparam name="form.contactEmail"      default="">
    <cfparam name="form.contactPhone"      default="">
    <cfparam name="form.contactSubject"    default="">
    <cfparam name="form.contactMessage"    default="">
    <cfparam name="form.consentToContact"  default="0">

    <cfset email   = trim(left(form.contactEmail,   200))>
    <cfset phone   = trim(left(form.contactPhone,   50))>
    <cfset subject = trim(left(form.contactSubject, 200))>
    <cfset message = trim(left(form.contactMessage, 5000))>
    <cfset consent = (form.consentToContact EQ "1") ? 1 : 0>

    <cfif NOT len(email) OR NOT len(phone) OR NOT len(subject) OR NOT len(message)>
        <cfoutput>{"success":false,"message":"All fields are required."}</cfoutput>
        <cfabort>
    </cfif>

    <cfif NOT isValid("email", email)>
        <cfoutput>{"success":false,"message":"Please enter a valid email address."}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery datasource="roundleague">
        INSERT INTO contact_messages (senderEmail, senderPhone, subject, messageBody, consentToContact)
        VALUES (
            <cfqueryparam value="#email#"   cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#phone#"   cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#subject#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#message#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#consent#" cfsqltype="cf_sql_tinyint">
        )
    </cfquery>

    <cfoutput>{"success":true,"message":"Your message has been sent. We’ll be in touch soon!"}</cfoutput>

    <cfcatch type="any">
        <cfoutput>{"success":false,"message":"An error occurred. Please try again."}</cfoutput>
    </cfcatch>
</cftry>
