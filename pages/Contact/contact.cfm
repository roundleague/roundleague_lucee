<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <!--- POST ACTION HERE --->
        <cfif isDefined("form.sendContact")>
          <cfmail
            from="#form.contactEmail#"
            to="theroundleague@gmail.com"
            subject="Contact Us Form - #form.contactName#">
            Email: #form.contactEmail#
          #form.contactMessage#

          </cfmail>
          <h3>Your contact form has been submitted.</h3>
        </cfif>

    <div class="section landing-section">
      <div class="container">
        <div class="row">
          <div class="col-md-8 ml-auto mr-auto">
            <h2 class="text-center">Questions or Comments? Contact Us!</h2>
            <form class="contact-form" method="POST">
              <div class="row">
                <div class="col-md-6">
                  <label>Name</label>
                  <div class="input-group">
                    <div class="input-group-prepend">
                      <span class="input-group-text">
                        <i class="nc-icon nc-single-02"></i>
                      </span>
                    </div>
                    <input type="text" class="form-control" placeholder="Name" name="contactName">
                  </div>
                </div>
                <div class="col-md-6">
                  <label>Email</label>
                  <div class="input-group">
                    <div class="input-group-prepend">
                      <span class="input-group-text">
                        <i class="nc-icon nc-email-85"></i>
                      </span>
                    </div>
                    <input type="text" class="form-control" placeholder="Email" name="contactEmail">
                  </div>
                </div>
              </div>
              <label>Message</label>
              <textarea name="contactMessage" class="form-control" rows="4" placeholder="Tell us your thoughts and feelings..."></textarea>
              <div class="row">
                <div class="col-md-4 ml-auto mr-auto">
                  <button class="btn btn-danger btn-lg btn-fill" type="submit" name="sendContact">Send Message</button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

<iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2797.0069706054032!2d-122.80769238456891!3d45.48980437910131!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x54950ea1bb17325b%3A0x396d5eba61a1bef2!2s4150%20SW%20Watson%20Ave%2C%20Beaverton%2C%20OR%2097005!5e0!3m2!1sen!2sus!4v1642477282440!5m2!1sen!2sus" width="600" height="450" style="border:0;" allowfullscreen="" loading="lazy"></iframe>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

