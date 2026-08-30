    <div class="section landing-section">
      <div class="container">
        <div class="row">
          <div class="col-md-8 ml-auto mr-auto">
            <h2 class="text-center">Keep in touch?</h2>
            <div id="contactAlert" class="alert" style="display:none;"></div>
            <form class="contact-form" id="homeContactForm">
              <!--- Honeypot fields: real users never see or fill these; bot autofill scripts do. See pages/Contact/spamCheck.cfm --->
              <input type="text" name="website" id="hcWebsite" value="" tabindex="-1" autocomplete="off"
                     style="position:absolute; left:-9999px; top:-9999px; height:0; width:0; opacity:0;">
              <input type="text" name="url" id="hcUrl" value="" tabindex="-1" autocomplete="off"
                     style="position:absolute; left:-9999px; top:-9999px; height:0; width:0; opacity:0;">
              <input type="hidden" name="fLoad" id="hcLoad" value="">
              <div class="row">
                <div class="col-md-6">
                  <label>Name</label>
                  <div class="input-group">
                    <div class="input-group-prepend">
                      <span class="input-group-text">
                        <i class="nc-icon nc-single-02"></i>
                      </span>
                    </div>
                    <input type="text" class="form-control" placeholder="Name" name="contactName" id="hcName">
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
                    <input type="text" class="form-control" placeholder="Email" name="contactEmail" id="hcEmail">
                  </div>
                </div>
              </div>
              <label>Message</label>
              <textarea class="form-control" rows="4" placeholder="Tell us your thoughts and feelings..." name="contactMessage" id="hcMessage"></textarea>
              <div class="row mt-3">
                <div class="col-md-12">
                  <div class="form-check">
                    <label class="form-check-label">
                      <input type="checkbox" class="form-check-input" id="hcConsent" value="1">
                      You may contact me back via email regarding my message.
                      <span class="form-check-sign">
                        <span class="check"></span>
                      </span>
                    </label>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-4 ml-auto mr-auto">
                  <button class="btn btn-danger btn-lg btn-fill" type="button" id="hcSubmitBtn" onclick="submitHomeContact()">Send Message</button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <script>
    (function() {
      var el = document.getElementById('hcLoad');
      if (el) el.value = Math.floor(Date.now() / 1000);
    })();

    function submitHomeContact() {
      var name    = document.getElementById('hcName').value.trim();
      var email   = document.getElementById('hcEmail').value.trim();
      var message = document.getElementById('hcMessage').value.trim();
      var alert   = document.getElementById('contactAlert');

      if (!name || !email || !message) {
        alert.className = 'alert alert-danger';
        alert.textContent = 'Please fill in all fields.';
        alert.style.display = 'block';
        return;
      }

      var btn = document.getElementById('hcSubmitBtn');
      btn.disabled = true;
      btn.textContent = 'Sending...';

      var consent = document.getElementById('hcConsent').checked ? '1' : '0';
      var website = document.getElementById('hcWebsite').value;
      var urlHp   = document.getElementById('hcUrl').value;
      var fLoad   = document.getElementById('hcLoad').value;
      var params = 'contactName=' + encodeURIComponent(name) +
                   '&contactEmail=' + encodeURIComponent(email) +
                   '&contactMessage=' + encodeURIComponent(message) +
                   '&consentToContact=' + consent +
                   '&website=' + encodeURIComponent(website) +
                   '&url=' + encodeURIComponent(urlHp) +
                   '&fLoad=' + encodeURIComponent(fLoad);

      fetch('/pages/Contact/submitContact.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
      })
      .then(function(r) { return r.json(); })
      .then(function(data) {
        btn.disabled = false;
        btn.textContent = 'Send Message';
        if (data.success) {
          alert.className = 'alert alert-success';
          document.getElementById('homeContactForm').reset();
        } else {
          alert.className = 'alert alert-danger';
        }
        alert.textContent = data.message;
        alert.style.display = 'block';
      })
      .catch(function() {
        btn.disabled = false;
        btn.textContent = 'Send Message';
        alert.className = 'alert alert-danger';
        alert.textContent = 'An error occurred. Please try again.';
        alert.style.display = 'block';
      });
    }
    </script>