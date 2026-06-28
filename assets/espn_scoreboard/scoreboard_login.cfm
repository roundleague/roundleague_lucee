<cfinclude template="/header.cfm">

<!--- Page Specific CSS --->
<link href="https://fonts.googleapis.com/css2?family=League+Gothic&display=swap" rel="stylesheet">
<link href="/pages/Login/login-redesign.css" rel="stylesheet">

<cfoutput>

<cfset invalidLogin = false>

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

<div class="rl-login-page rl-login-page--dark" id="rlLoginPage">
  <div class="rl-login-inner">

    <h1 class="rl-login-heading">
      <span>Login to the</span>
      <img src="/assets/img/Logos/favicon.png" alt="Round League" class="ball-icon">
      <span>League</span>
    </h1>

    <div class="rl-login-card">
      <form class="rl-form" method="POST" id="loginForm">
        <cfif invalidLogin>
          <div class="rl-alert rl-alert--error">Incorrect password.</div>
        </cfif>
        <label for="userName">Email</label>
        <input id="userName" name="userName" type="text" class="form-control" placeholder="User Name" autocomplete="username">
        <label for="password">Password</label>
        <input id="password" name="password" type="password" class="form-control" placeholder="Password" autocomplete="current-password">
        <button class="rl-btn-primary" name="submitLogin">Log In</button>
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
