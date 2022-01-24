<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../Login/createLogin.css" rel="stylesheet">

<cfoutput>

<cfparam name="form.email" default="">

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      <cfif isDefined("form.submitLogin")>
        <cfquery name="getCaptainsFromEmail" datasource="roundleague">
          SELECT firstName, lastName, Email, playerID, teamName
          FROM players p
          JOIN teams t ON t.CaptainPlayerID = p.playerID
          WHERE t.SeasonID = (Select SeasonID From Seasons Where Status = 'Active')
          AND email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">
        </cfquery>
      </cfif>

      <cfif isDefined("form.continueLogin")>
        <cflocation url="createLogin-2.cfm?playerID=#form.player#">
      </cfif>

        <!--- Content Here --->
        <div class="row">
          <div class="col-lg-4 ml-auto mr-auto">
            <div class="card card-register">
               <h3 class="title mx-auto">Create an Account</h3>
               <form class="register-form" method="POST">
                  <label>Email</label>
                  <input name="email" type="text" class="form-control" placeholder="Email" value="#form.email#">
                  <button class="btn btn-danger btn-block btn-round" name="submitLogin">Search</button>

                  <cfif isDefined("form.submitLogin")>
                    <div class="emailResults">
                      <cfloop query="getCaptainsFromEmail">
                          <input class="form-check-input" type="radio" name="player" value="#playerID#" checked> #getCaptainsFromEmail.firstName# #getCaptainsFromEmail.lastName# - #teamName#
                      </cfloop>
                      <cfif getCaptainsFromEmail.recordCount EQ 0>
                        No current captain email found for this season.
                      <cfelse>
                        <button class="btn btn-danger btn-block btn-round" name="continueLogin">Continue</button>
                      </cfif>
                    </div>
                  </cfif>
               </form>
            </div>
          </div>
        </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">