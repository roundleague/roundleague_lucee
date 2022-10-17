<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../../Login/captains_login.css" rel="stylesheet">

<cfoutput>

<cfset invalidLogin = false>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      <cfif isDefined("form.submitLogin")>
        <cfquery name="Authenticate">
          SELECT
            password, username
          FROM
            scoreboard_users
          WHERE
            Username = <cfqueryparam cfsqltype="varchar" value="#form.username#">
          AND 
            Status = 'Active'
        </cfquery>
        <cfif Authenticate.password EQ form.password>
          Logging into scoreboard baby
        <cfelse>
          <cfset invalidLogin = true>
        </cfif>
        <!--- Keep this for hash pass logic later --->
        <!--- <cfif Authenticate.password EQ hash(form.password, "SHA")>
          <cfset session.captainLoggedIn = true>
          <cfset session.captainID = Authenticate.playerID>
          <cflocation url="../../captain/captain_home.cfm?playerID=#Authenticate.playerID#">
        <cfelse>
          <cfset invalidLogin = true>
        </cfif> --->
      </cfif>

        <!--- Content Here --->
        <div class="row">
          <div class="col-lg-4 ml-auto mr-auto">
            <div class="card card-register">
               <h3 class="title mx-auto">Welcome</h3>
               <form class="register-form" method="POST">
                  <cfif invalidLogin>
                      Incorrect password <br>
                  </cfif>
                  <label>Email</label>
                  <input name="userName" type="text" class="form-control" placeholder="User Name">
                  <label>Password</label>
                  <input name="password" type="password" class="form-control" placeholder="Password">
                  <button class="btn btn-danger btn-block btn-round" name="submitLogin">Log In</button>
               </form>
            </div>
          </div>
        </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">