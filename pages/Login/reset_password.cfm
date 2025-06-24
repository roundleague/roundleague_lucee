<cfinclude template="/header.cfm">
<cfoutput>
<cfset passwordResetSuccess = false>
<cfset passwordResetError = false>
<cfset code = trim(url.code)>

<cfif structKeyExists(form, "submitNewPassword")>
  <cfset code = trim(form.code)>
  <cfset newPassword = trim(form.newPassword)>
  <cfset confirmPassword = trim(form.confirmPassword)>
  <cfif newPassword EQ confirmPassword AND len(newPassword) GTE 6>
    <cfquery name="GetSignup">
      SELECT userID FROM pending_signups WHERE confirmationCode = <cfqueryparam cfsqltype="varchar" value="#code#">
    </cfquery>
    <cfif GetSignup.recordCount EQ 1>
      <cfset hashedPassword = hash(newPassword, "SHA")>
      <cfquery>
        UPDATE Users SET password = <cfqueryparam cfsqltype="varchar" value="#hashedPassword#"> WHERE playerID = <cfqueryparam cfsqltype="integer" value="#GetSignup.userID#">
      </cfquery>
      <cfquery>
        DELETE FROM pending_signups WHERE confirmationCode = <cfqueryparam cfsqltype="varchar" value="#code#">
      </cfquery>
      <cfset passwordResetSuccess = true>
    <cfelse>
      <cfset passwordResetError = true>
    </cfif>
  <cfelse>
    <cfset passwordResetError = true>
  </cfif>
</cfif>

<div class="main" style="background-color: white;">
  <div class="section text-center">
    <div class="container">
      <div class="row">
        <div class="col-lg-4 ml-auto mr-auto">
          <div class="card card-register">
            <h3 class="title mx-auto">Reset Password</h3>
            <cfif passwordResetSuccess>
              <div class="alert alert-success">Your password has been reset. You may now <a href="captains_login.cfm">log in</a>.</div>
            <cfelse>
              <cfif passwordResetError>
                <div class="alert alert-danger">There was a problem resetting your password. Please try again or request a new reset link.</div>
              </cfif>
              <form class="register-form" method="POST">
                <input type="hidden" name="code" value="#encodeForHTMLAttribute(code)#">
                <label>New Password</label>
                <input name="newPassword" type="password" class="form-control" placeholder="New Password" required>
                <label>Confirm Password</label>
                <input name="confirmPassword" type="password" class="form-control" placeholder="Confirm Password" required>
                <button class="btn btn-danger btn-block btn-round" name="submitNewPassword">Set New Password</button>
              </form>
            </cfif>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
