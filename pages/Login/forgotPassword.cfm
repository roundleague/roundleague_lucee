<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      	<cfif isDefined("form.sendRecoverLink")>
		    <cfquery name="checkValidEmail" datasource="roundleague">
		      SELECT
		        userName
		      FROM
		        Users
		      WHERE
		        Username = <cfqueryparam cfsqltype="varchar" value="#form.email#">
		      AND 
		        Status = 'Active'
		    </cfquery>
		    <cfdump var="#checkValidEmail#" />
      	</cfif>

        <!--- Content Here --->
        <div class="row">
          <div class="col-lg-4 ml-auto mr-auto">
            <div class="card card-register">
               <h3 class="title mx-auto">Password Reset</h3>
               <form class="register-form" method="POST">
                  <label>Email</label>
                  <input name="email" type="text" class="form-control" placeholder="Email">
                  <button class="btn btn-danger btn-block btn-round" name="sendRecoverLink">Send Recovery Link</button>
               </form>
            </div>
          </div>
        </div>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

