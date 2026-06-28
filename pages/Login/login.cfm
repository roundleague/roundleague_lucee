<cfinclude template="/header.cfm">

<!--- Page Specific CSS --->
<link href="https://fonts.googleapis.com/css2?family=League+Gothic&display=swap" rel="stylesheet">
<link href="/pages/Login/login-redesign.css" rel="stylesheet">

<cfoutput>

<div class="rl-login-page" id="rlLoginPage">
  <div class="rl-login-inner">

    <h1 class="rl-login-heading">
      <span>Login to the</span>
      <img src="/assets/img/Logos/favicon.png" alt="Round League" class="ball-icon">
      <span>League</span>
    </h1>

    <div class="rl-login-card">
      <cfif isDefined("form.submitLogin")>
        <cfinclude template="checkCredentials.cfm">
      </cfif>

      <form name="loginForm" method="POST" class="rl-form" id="loginForm">
        <label for="userName">User</label>
        <input id="userName" name="userName" type="text" class="form-control" placeholder="Username" autocomplete="username">
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
