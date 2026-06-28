<cfinclude template="/header.cfm">

<!--- Page Specific CSS --->
<link href="https://fonts.googleapis.com/css2?family=League+Gothic&display=swap" rel="stylesheet">
<link href="/pages/Login/login-redesign.css" rel="stylesheet">

<cfoutput>

<cfset invalidLogin = false>

<cfif isDefined("form.submitLogin")>
  <cfset local.loginLimit = createObject("component","api.RateLimiter").check("login_#cgi.remote_addr#", 15, 900)>
  <cfif NOT local.loginLimit.allowed>
    <cfset invalidLogin = true>
  <cfelse>
    <cfquery name="Authenticate">
      SELECT
        password, playerID, role
      FROM
        Users
      WHERE
        Username = <cfqueryparam cfsqltype="varchar" value="#form.username#">
      AND
        Status = 'Active'
    </cfquery>
    <cfif Authenticate.password EQ hash(form.password, "SHA")>
      <cfif Authenticate.role EQ "Player">
        <cfset session.playerLoggedIn = true>
        <cfset session.playerID = Authenticate.playerID>
        <cflocation url="../account/account_home.cfm?playerID=#Authenticate.playerID#">
      <cfelseif Authenticate.role EQ "Captain">
        <cfset session.playerLoggedIn = true>
        <cfset session.playerID = Authenticate.playerID>
        <cfset session.captainLoggedIn = true>
        <cfset session.captainID = Authenticate.playerID>
        <cflocation url="../account/account_home.cfm?playerID=#Authenticate.playerID#">
      </cfif>
    <cfelse>
      <cfset invalidLogin = true>
    </cfif>
  </cfif>
</cfif>

<cfif isDefined("form.forgotPassword")>
  <cfset local.forgotLimit = createObject("component","api.RateLimiter").check("forgot_#cgi.remote_addr#", 5, 3600)>
  <cfif local.forgotLimit.allowed>
    <cfquery name="GetUser">
      SELECT playerID, Username FROM Users WHERE Username = <cfqueryparam cfsqltype="varchar" value="#form.userName#"> AND Status = 'Active'
    </cfquery>
    <cfif GetUser.recordCount EQ 1>
      <cfset confirmationCode = createUUID()>
      <cfquery>
        DELETE FROM pending_signups WHERE userID = <cfqueryparam cfsqltype="integer" value="#GetUser.playerID#">
      </cfquery>
      <cfquery>
        INSERT INTO pending_signups (userID, confirmationCode) VALUES (
          <cfqueryparam cfsqltype="integer" value="#GetUser.playerID#">,
          <cfqueryparam cfsqltype="varchar" value="#confirmationCode#">
        )
      </cfquery>
      <cfset protocol = (structKeyExists(cgi, "https") and cgi.https eq "on") ? "https" : "http">
      <cfset serverName = cgi.server_name>
      <cfset port = "">
      <cfif serverName EQ "127.0.0.1" OR serverName EQ "localhost">
        <cfset port = ":8888">
      </cfif>
      <cfset resetLink = protocol & "://" & serverName & port & "/pages/Login/reset_password.cfm?code=" & confirmationCode>
      <cfset userEmail = GetUser.Username>
      <cfinclude template="/pages/Login/reset_password_email.cfm">
      <cfmail to="#userEmail#" from="richard.ung@theroundleague.com" subject="Password Reset Request" type="html">
        #htmlEmail#
      </cfmail>
      <cfset passwordResetSent = true>
    <cfelse>
      <cfset passwordResetSent = false>
      <cfset passwordResetError = true>
    </cfif>
  </cfif>
</cfif>

<div class="rl-login-page" id="rlLoginPage">
  <div class="rl-login-inner">

    <h1 class="rl-login-heading">
      <span>Login to the</span>
      <img src="/assets/img/Logos/favicon.png" alt="Round League" class="ball-icon">
      <span>League</span>
    </h1>

    <div class="rl-login-card">

      <cfif isDefined("passwordResetSent") and passwordResetSent>
        <div class="rl-alert rl-alert--success">A password reset link has been sent to your email address.</div>
      <cfelseif isDefined("passwordResetError") and passwordResetError>
        <div class="rl-alert rl-alert--error">Email address not found or inactive.</div>
      </cfif>

      <form class="rl-form" method="POST" id="loginForm">
        <cfif invalidLogin>
          <div class="rl-alert rl-alert--error">Credentials not found. If you haven't signed up yet, please register.</div>
        </cfif>
        <label for="userName">Email</label>
        <input id="userName" name="userName" type="text" class="form-control" placeholder="you@example.com" autocomplete="email">
        <label for="password">Password</label>
        <input id="password" name="password" type="password" class="form-control" placeholder="Password" autocomplete="current-password">
        <button class="rl-btn-primary" name="submitLogin">Log In</button>
        <button class="rl-btn-secondary" name="forgotPassword">Forgot Password?</button>
      </form>

    </div>
  </div>
</div>

<script>
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    if (e.submitter && e.submitter.name === 'submitLogin') {
      e.preventDefault();
      document.getElementById('rlLoginPage').classList.add('animating');
      var form = this;
      var hidden = document.createElement('input');
      hidden.type = 'hidden';
      hidden.name = 'submitLogin';
      hidden.value = 'true';
      form.appendChild(hidden);
      setTimeout(function() { form.submit(); }, 700);
    }
  });
</script>

</cfoutput>
<cfinclude template="/footer.cfm">
