
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->

<!--- CF Queries --->
<cfquery name="getDivisions" datasource="roundleague">
	SELECT DivisionID, DivisionName
	FROM Divisions
	Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.CurrentSeasonID#">
</cfquery>

<cfparam name="form.divisionID" default="#getDivisions.divisionID#">
<cfparam name="toastMsg" default="">

<!--- Form Submit Logic --->
<cfif isDefined("form.teamName")>
	<cfquery name="addTeam" datasource="roundleague">
		INSERT INTO Teams (Status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID)
		VALUES 
		(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Active">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.teamName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.captainPlayerID#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), "mm/dd/yyyy")#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionSelect#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.CurrentSeasonID#">
		)
	</cfquery>
	<cfset toastMsg = 'New Team Saved!'>
</cfif>

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">

		<div class="wrapper">
		    <div class="profile-content section">
		      <div class="container">
		        <div class="row">
		          <div class="col-md-6 ml-auto mr-auto">
		            <form class="settings-form" method="POST">
		              <h4 class="toastMsg">#toastMsg#</h4>
		              <div class="form-group">
		                <label>Team Name</label>
		                <input type="text" required class="form-control border-input" placeholder="Team Name" name="teamName">
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Captain Player ID</label>
		                    <input type="text" required class="form-control border-input" placeholder="Captain Player ID" name="captainPlayerID">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label class="teamSelect">Select Division</label><br>
							<select class="divisionSelect" name="divisionSelect" style="padding: 7px;">
								<cfloop query="getDivisions">
									<option value="#getDivisions.DivisionID#"<cfif getDivisions.DivisionID EQ form.DivisionID> selected</cfif>>#getDivisions.DivisionName#</option>
								</cfloop>
							</select>
		                  </div>
		                </div>
		              </div>
		              <div class="text-center">
		                <button type="submit" class="btn btn-wd btn-info btn-round saveBtn">Save</button>
		              </div>
		            </form>
		          </div>
		        </div>
		      </div>
		    </div>
		  </div>
		      </div>
		    </div>
		</div>

    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
