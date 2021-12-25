<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
      <div class="row">
        <div class="col-lg-4 ml-auto mr-auto">
          <div class="card card-register">
            <h3 class="title mx-auto">Welcome</h3>
            <form class="register-form">
              <label>User</label>
              <input type="text" class="form-control" placeholder="Email">
              <label>Password</label>
              <input type="password" class="form-control" placeholder="Password">
              <button class="btn btn-danger btn-block btn-round">Submit</button>
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