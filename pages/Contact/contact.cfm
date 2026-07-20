<cfinclude template="/header.cfm">

<cfoutput>

<cfset formSubmitted = false>
<cfset formError = "">

<cfif isDefined("form.sendContact")>
    <cfset contactEmail   = trim(left(form.contactEmail,   200))>
    <cfset contactPhone   = trim(left(form.contactPhone,   50))>
    <cfset contactSubject = trim(left(form.contactSubject, 200))>
    <cfset contactMessage = trim(left(form.contactMessage, 5000))>
    <cfset contactConsent = (isDefined("form.consentToContact") AND form.consentToContact EQ "1") ? 1 : 0>

    <cfif NOT len(contactEmail) OR NOT len(contactPhone) OR NOT len(contactSubject) OR NOT len(contactMessage)>
        <cfset formError = "All fields are required.">
    <cfelseif NOT isValid("email", contactEmail)>
        <cfset formError = "Please enter a valid email address.">
    <cfelse>
        <cftry>
            <cfquery datasource="roundleague">
                INSERT INTO contact_messages (senderEmail, senderPhone, subject, messageBody, consentToContact)
                VALUES (
                    <cfqueryparam value="#contactEmail#"   cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#contactPhone#"   cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#contactSubject#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#contactMessage#" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="#contactConsent#" cfsqltype="cf_sql_tinyint">
                )
            </cfquery>
            <cfif NOT (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1")>
                <cfmail
                    from="mailadmin@theroundleague.com"
                    to="theroundleague@gmail.com"
                    subject="New Contact Form Message: #contactSubject#"
                    type="text">
New contact form submission received.

Subject: #contactSubject#
Email:   #contactEmail#
Phone:   #contactPhone#
May contact back: #(contactConsent ? "Yes" : "No")#

Message:
#contactMessage#
                </cfmail>
            </cfif>
            <cfset formSubmitted = true>
            <cfcatch type="any">
                <cfset formError = "Something went wrong. Please try again.">
            </cfcatch>
        </cftry>
    </cfif>
</cfif>

<div class="main" style="background-color: white;">
    <div class="section">
        <div class="container">

            <div class="row">
                <div class="col-md-8 ml-auto mr-auto">

                    <h2 class="text-center" style="margin-bottom: 8px;">Contact Us</h2>
                    <p class="text-center text-muted" style="margin-bottom: 32px;">Questions, feedback, or anything on your mind — we'd love to hear from you.</p>

                    <cfif formSubmitted>
                        <div class="alert alert-success text-center" style="padding: 24px; border-radius: 8px;">
                            <i class="nc-icon nc-check-2" style="font-size:2rem; display:block; margin-bottom:8px;"></i>
                            <strong>Message sent!</strong> We'll be in touch soon.
                        </div>
                    <cfelse>
                        <cfif len(formError)>
                            <div class="alert alert-danger">#htmlEditFormat(formError)#</div>
                        </cfif>

                        <form class="contact-form" method="POST">

                            <div class="form-group">
                                <label>Subject <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="nc-icon nc-paper"></i></span>
                                    </div>
                                    <input type="text" class="form-control" name="contactSubject"
                                           placeholder="What is this about?"
                                           value="#isDefined('form.contactSubject') ? htmlEditFormat(form.contactSubject) : ''#"
                                           required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Email <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="nc-icon nc-email-85"></i></span>
                                            </div>
                                            <input type="email" class="form-control" name="contactEmail"
                                                   placeholder="your@email.com"
                                                   value="#isDefined('form.contactEmail') ? htmlEditFormat(form.contactEmail) : ''#"
                                                   required>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Phone <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="nc-icon nc-mobile"></i></span>
                                            </div>
                                            <input type="tel" class="form-control" name="contactPhone"
                                                   placeholder="(503) 555-0100"
                                                   value="#isDefined('form.contactPhone') ? htmlEditFormat(form.contactPhone) : ''#"
                                                   required>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Message <span class="text-danger">*</span></label>
                                <textarea class="form-control" name="contactMessage" rows="5"
                                          placeholder="Tell us your thoughts"
                                          required>#isDefined('form.contactMessage') ? htmlEditFormat(form.contactMessage) : ''#</textarea>
                            </div>

                            <div class="form-group">
                                <div class="form-check">
                                    <label class="form-check-label">
                                        <input type="checkbox" class="form-check-input" name="consentToContact" value="1">
                                        You may contact me back via email or phone regarding my message.
                                        <span class="form-check-sign"><span class="check"></span></span>
                                    </label>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4 ml-auto mr-auto text-center">
                                    <button class="btn btn-danger btn-lg btn-fill" type="submit" name="sendContact">
                                        Send Message
                                    </button>
                                </div>
                            </div>

                        </form>
                    </cfif>

                </div>
            </div>


        </div>
    </div>
</div>

</cfoutput>

<cfinclude template="/footer.cfm">
