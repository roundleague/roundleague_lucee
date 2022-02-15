<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../Login/createLogin-2.css?v=1.1" rel="stylesheet">

<cfoutput>

<cfquery name="getAndCheckCaptain" datasource="roundleague">
  SELECT p.firstName, p.lastName, p.playerID, p.email
  FROM players p
  JOIN teams t on t.captainPlayerID = p.playerID
  WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.playerID#">
</cfquery>

<cfif getAndCheckCaptain.recordCount EQ 0>
  Access Denied.
  <cfabort />
</cfif>

<cfparam name="form.email" default="">

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      <cfif isDefined("form.submitLogin")>
        <!--- Insert Pending for User --->
        <cfquery name="insertUserPending" datasource="roundleague" result="result">
          INSERT INTO users (userName, password, dateModified, playerID, status)
          VALUES
          (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#getAndCheckCaptain.email#">,
            <cfqueryparam cfsqltype="char" value="#hash(form.createPassword,'SHA')#">,
            <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.playerID#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending">
          );
        </cfquery>

        <cfset newUserId = result.generated_key>

        <cfquery name="insertPendingSignUp" datasource="roundleague">
          INSERT INTO pending_signups (userID) 
          VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newUserId#">
            );
        </cfquery>

        <cfquery name="verifyLink" datasource="roundleague">
            SELECT confirmationCode
            FROM pending_signups
            WHERE userID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newUserId#">
        </cfquery>

        <!--- Send out verification Email --->
        <cfmail
          from="mailadmin@theroundleague.com"
          to="#getAndCheckCaptain.email#"
          subject="Registration - #getAndCheckCaptain.firstName# #getAndCheckCaptain.lastName#"
          type="HTML">
        
        <h3>Thank you for registering! Please click <a href="https://#CGI.HTTP_HOST#/pages/Login/completeVerify.cfm?userID=#newUserId#&hashCode=#verifyLink.confirmationCode#">here</a> to complete your account.</h3>

        </cfmail>

        <div class="successMsg">An email with a verification link to #getAndCheckCaptain.email# has been sent (please allow 3-5 minutes and check spam folders).</div>
        <cfabort />
      </cfif>

        <!--- Content Here --->
        <div class="row">
          <div class="col-lg-4 ml-auto mr-auto">
            <div class="card card-register">
               <h3 class="title mx-auto">Hi, #getAndCheckCaptain.firstName#</h3>
               <form class="register-form" method="POST">
                  <label>Create A Password</label>
                  <input name="createPassword" type="password" class="form-control createPassword">
                  <label>Confirm Password</label>
                  <input name="confirmPassword" type="password" class="form-control confirmPassword">
                  <button class="btn btn-danger btn-block btn-round registerBtn" name="submitLogin">Register</button>
                  <span class="invalidMsg"></span>
               </form>
            </div>
          </div>
        </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="/pages/Login/createLogin-2.js"></script>