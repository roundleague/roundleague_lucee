<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://demos.creative-tim.com/paper-kit-2-pro/assets/css/paper-kit.min.css?v=2.3.1" rel="stylesheet">
<link href="../Register/register.css?v=1.1" rel="stylesheet">

<cfoutput>

<cfset basketballExp = 'Recreational,High School Varsity,College,D-1 University,Professional'>
<cfset daysOptions = 'Saturday, Sunday'>
<cfset numberOfPlayerOptions = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15">
<cfset timeOptions = "9:00 AM - 12:00 PM, 10:00 AM - 1:00 PM, 11:00 AM - 2:00 PM, 12:00 PM - 3:00 PM, 1:00 PM - 4:00 PM, 2:00 PM - 5:00 PM, 3:00 PM - 6:00 PM, 4:00 PM - 7:00 PM, 5:00 PM - 8:00 PM">


<cfif isDefined("form.teamName")>
	<cfinclude template="registerTeamSave.cfm">
	<!--- <div id="snackbar" class="show">#toastMessage#</div> --->
	<cfexit>
</cfif>


<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<div class="wrapper">
		    <div class="profile-content section">
		      <div class="container">
		        <div class="row">
		          <div class="col-md-6 ml-auto mr-auto">
		            <form class="settings-form" method="POST">
					<!--- <div class="registerNote">Note: We are currently not taking free agent sign ups. Please only register if you have verified with your team captain!</div class="registerNote"> --->
	                  <div class="form-group">
	                    <label class="divisionSelectText">Select Division</label><br>
						<select class="divisionSelect" name="divisionSelect" style="padding: 7px;">
						  <option value=""></option>
						  <option value="Men's Division">Men's Division</option>
						  <option value="Women's Division">Women's Division</option>
						</select>
	                  </div>
		              <div class="form-group">
		                <label>Email</label>
		                <input type="email" required class="form-control border-input" placeholder="Email" name="email">
		              </div>
					<div class="form-group">
		                <label>Team Name</label>
		                <input type="teamName" required class="form-control border-input" placeholder="Team Name" name="teamName">
		              </div>		              
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>First Name</label>
		                    <input type="text" required class="form-control border-input" placeholder="First Name" name="firstName">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Last Name</label>
		                    <input type="text" required class="form-control border-input" placeholder="Last Name" name="lastName">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Age</label>
		                    <input type="number" class="form-control border-input" placeholder="Age" name="age">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Phone Number</label>
		                    <input type="tel" required id="phoneField" class="form-control border-input" name="phone" placeholder="123-456-6789" required>
		                  </div>
		                </div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Your Team's Average Basketball Experience</label>
			              		<cfloop list="#basketballExp#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" name="highestLevel" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
		              		</div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
								<div class="form-group">
			                    <label>Number Of Players (Estimate)</label><br>
								<select name="numberOfPlayers" style="padding: 7px;">
								  <cfloop list="#numberOfPlayerOptions#" index="i" item="x">
								  	<option value="#x#">#x#</option>
								  </cfloop>
								</select>
			                  </div>
		              		</div>
		              </div>

					<div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Day Preference</label>
			              		<cfloop list="#daysOptions#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" name="dayPreference" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
		              		</div>
		              </div>	   	   

		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			                  <div class="form-group">
			                    <label>Primary Time Preference</label><br>
								<select name="primaryTimePref" style="padding: 7px;">
								  <option value="Anytime">Anytime (More likely to be approved)</option>
								  <cfloop list="#timeOptions#" index="i" item="x">
								  	<option value="#x#">#x#</option>
								  </cfloop>
								</select>
			                  </div>
			               </div>
		              </div>

		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			                  <div class="form-group">
			                    <label>Secondary Time Preference</label><br>
								<select name="secondaryTimePref" style="padding: 7px;">
								  <option value="Anytime">Anytime (More likely to be approved)</option>	
								  <cfloop list="#timeOptions#" index="i" item="x">
								  	<option value="#x#">#x#</option>
								  </cfloop>
								</select>
			                  </div>
			               </div>
		              </div>

		              <div class="text-center errorDiv">
		                <span class="errorMessage"></span>
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
</cfoutput>

<cfinclude template="/footer.cfm">
<script src="../RegisterTeam/registerTeam.js?v=1.0"></script>