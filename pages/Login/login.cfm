<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      <cfif isDefined("form.submitLogin")>
        <cfinclude template="checkCredentials.cfm">
      </cfif>

        <!--- Content Here --->
        <div class="row">
          <div class="col-lg-4 ml-auto mr-auto">
            <div class="card card-register">
              <h3 class="title mx-auto">Welcome</h3>
              <form name="loginForm" method="POST" class="register-form">
                <label>User</label>
                <input name="userName" type="text" class="form-control" placeholder="Username">
                <label>Password</label>
                <input name="password" type="password" class="form-control" placeholder="Password">
                <button class="btn btn-danger btn-block btn-round" name="submitLogin">Submit</button>
              </form>
              <!--- <div class="forgot">
                <a href="##" class="btn btn-link btn-danger">Forgot password?</a>
              </div> --->
            </div>
          </div>
        </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">