<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
    <div class="section landing-section">
      <div class="container">
        <div class="row">
          <div class="col-md-8 ml-auto mr-auto">
            <h2 class="text-center">Questions or Comments? Contact Us!</h2>
            <form class="contact-form">
              <div class="row">
                <div class="col-md-6">
                  <label>Name</label>
                  <div class="input-group">
                    <div class="input-group-prepend">
                      <span class="input-group-text">
                        <i class="nc-icon nc-single-02"></i>
                      </span>
                    </div>
                    <input type="text" class="form-control" placeholder="Name">
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
                    <input type="text" class="form-control" placeholder="Email">
                  </div>
                </div>
              </div>
              <label>Message</label>
              <textarea class="form-control" rows="4" placeholder="Tell us your thoughts and feelings..."></textarea>
              <div class="row">
                <div class="col-md-4 ml-auto mr-auto">
                  <button class="btn btn-danger btn-lg btn-fill">Send Message</button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <iframe src="https://www.google.com/maps/embed?pb=!1m26!1m12!1m3!1d44751.522118642875!2d-122.8792858025272!3d45.4905461997855!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!4m11!3e6!4m3!3m2!1d45.497188099999995!2d-122.8820662!4m5!1s0x54950ea1c06d16a1%3A0x57f15005a1dbdeb7!2s4145%20SW%20Watson%20Ave%2C%20Beaverton%2C%20OR%2097005!3m2!1d45.4898096!2d-122.80661309999999!5e0!3m2!1sen!2sus!4v1641092683173!5m2!1sen!2sus" width="600" height="450" style="border:0;" allowfullscreen="" loading="lazy"></iframe>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

