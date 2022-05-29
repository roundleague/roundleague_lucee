<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://demos.creative-tim.com/paper-kit-2-pro/assets/css/paper-kit.min.css?v=2.3.1" rel="stylesheet">
<link href="../Register/register.css" rel="stylesheet">

<cfoutput>

<cfquery name="getTeams" datasource="roundleague">
	SELECT teamID, teamName
	FROM Teams
	Where Status = 'Active'
	AND seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
	ORDER BY teamName
</cfquery>

<cfset basketballExp = 'Recreational,High School Varsity,College,D-1 University,Professional'>
<cfset vaccinationStatus = 'Yes,No,Prefer Not To Say'>
<cfset bballPosition = 'Point Guard,Shooting Guard,Small Forward,Power Forward,Center'>
<cfset heightOptions = "4'11,5'1,5'2,5'3,5'4',5'5,5'6,5'7,5'8,5'9,5'10,5'11,6'0,6'1,6'2,6'3,6'4,6'5,6'6,6'7,6'8,6'9,6'10,6'11,7'0,7'1,7'2,7'3,7'4,7'5">

<cfif isDefined("form.athleticWaiver") and isDefined("form.photoWaiver")>
	<cfinclude template="register-save.cfm">
	<!--- <div id="snackbar" class="show">#toastMessage#</div> --->
	<cfexit>
</cfif>


<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

      	<!--- Waiver Modal --->
            <div class="modal fade" id="waiverModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">x</span>
                    </button>
                    <h5 class="modal-title text-center" id="exampleModalLabel">ATHLETIC WAIVER AND RELEASE OF LIABILITY</h5>
                  </div>
                  <div class="modal-body"> 

                  	<p><b>READ BEFORE SIGNING</b></p>

<p>In consideration of being allowed to participate in any way in The Round League, related events and activities, the undersigned acknowledges, appreciates, and agrees that:
The risks of injury and illness (ex: communicable diseases such as MRSA, influenza, and COVID-19) from the activities involved in this program are significant, including the potential for permanent paralysis and death, and while particular rules, equipment, and personal discipline may reduce these risks, the risks of serious injury and illness do exist; and,
I KNOWINGLY AND FREELY ASSUME ALL SUCH RISKS, both known and unknown, EVEN IF ARISING FROM THE NEGLIGENCE OF THE RELEASEES or others, and assume full responsibility for my participation; and,
I willingly agree to comply with the stated and customary terms and conditions for participation. If, however, I observe any unusual significant hazard during my presence or participation, I will remove myself from participation and bring such to the attention of the nearest official immediately; and,
I, for myself and on behalf of my heirs, assigns, personal representatives and next of kin, HEREBY RELEASE AND HOLD HARMLESS The Round League  their officers, officials, agents, and/or employees, other participants, sponsoring agencies, sponsors, advertisers, and if applicable, owners and lessors of premises used to conduct the event ("RELEASEES"), WITH RESPECT TO ANY AND ALL INJURY, ILLNESS, DISABILITY, DEATH, or loss or damage to person or property, WHETHER ARISING FROM THE NEGLIGENCE OF THE RELEASEES OR OTHERWISE, to the fullest extent permitted by law.</p>

<p>I HAVE READ THIS RELEASE OF LIABILITY AND ASSUMPTION OF RISK AGREEMENT, FULLY UNDERSTAND ITS TERMS, UNDERSTAND THAT I HAVE GIVEN UP SUBSTANTIAL RIGHTS BY SIGNING IT, AND SIGN IT FREELY AND VOLUNTARILY WITHOUT ANY INDUCEMENT. AND HEREBY PRINT MY NAME AS MY SIGNATURE BELOW IN AGREEMENT TO THIS WAIVER.</p>
                  </div>
                  <div class="modal-footer">
                    <div class="left-side">
                      <button type="button" class="btn btn-default btn-link" data-dismiss="modal">I Agree</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

      	<!--- Waiver Modal --->
            <div class="modal fade" id="photoModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">x</span>
                    </button>
                    <h5 class="modal-title text-center" id="exampleModalLabel">PHOTO/VIDEO CONSENT FORM</h5>
                  </div>
                  <div class="modal-body"> 

                  	<p><b>READ BEFORE SIGNING</b></p>

<p>I, _____________________________ grant permission to The Round League for the use and take of the photograph(s) or electronic media images and videos as in any presentation of any and all kind whatsoever. I understand that I may revoke this authorization at any time by notifying _____________________________ in writing. The revocation will not affect any actions taken before the receipt of this written notification. Images will be stored in a secure location and only authorized staff will have access to them. They will be kept as long as they are relevant and after that time destroyed or archived.</p>
                  </div>
                  <div class="modal-footer">
                    <div class="left-side">
                      <button type="button" class="btn btn-default btn-link" data-dismiss="modal">I Agree</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

        <!--- Content Here --->
		<div class="wrapper">
		    <div class="profile-content section">
		      <div class="container">
		        <div class="row">
		          <div class="col-md-6 ml-auto mr-auto">
		            <form class="settings-form" method="POST">
					<!--- <div class="registerNote">Note: We are currently not taking free agent sign ups. Please only register if you have verified with your team captain!</div class="registerNote"> --->
	                  <div class="form-group">
	                    <label class="teamSelect">Select Season</label><br>
						<select class="seasonSelect" name="seasonSelect" style="padding: 7px;">
						  <option value=""></option>
						  <option value="5">Spring 2022</option>
						</select>
	                  </div>
	                  <div class="form-group">
	                    <label>Gender</label><br>
						<select class="gender" name="gender" style="padding: 7px;">
						  <option value=""></option>
						  <option value="Male">Male</option>
						  <option value="Female">Female</option>
						</select>
	                  </div>
		              <div class="form-group">
		                <label>Email</label>
		                <input type="email" required class="form-control border-input" placeholder="Email" name="email">
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
		                    <label>Birth Date</label>
		                    <input type="date" required class="form-control border-input" placeholder="Birth Date" name="birthDate">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Phone Number</label>
		                    <input type="tel" required id="phoneField" class="form-control border-input" name="phone" placeholder="123-45-678" required>
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
		                  <div class="form-group">
		                    <label>Zip Code</label>
		                    <input type="text" required class="form-control border-input" placeholder="Zip Code" name="zipCode" maxlength="5">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
		                  <div class="form-group">
		                    <label>Instagram Handle (No @ Needed)</label>
		                    <input type="text" class="form-control border-input" placeholder="IG Handle" name="instagram">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
		                  <div class="form-group">
		                    <label>Confirmed Jersey Number (Only fill out if you currently have an existing jersey)</label>
		                    <input type="number" class="form-control border-input" name="currentJersey">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			                  <div class="form-group">
			                    <label class="teamSelect">Select Team (Will be verified by Team Captain)</label><br>
								<select class="teamID" name="teamID" style="padding: 7px;">
								  <option value=""></option>
								  <!--- <cfloop query="getTeams">
								  	<option value="#getTeams.TeamID#">#getTeams.TeamName#</option>
								  </cfloop> --->
								  <option value="0">I am signing up as a free agent</option>
								</select>
								<!--- <br>
								<b>If you have a team but do not see it here, please register at a later time once your team has been added.</b> --->
			                  </div>
			               </div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Basketball Experience</label>
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
			              		<label class="biggerLabel">COVID-19 Vaccination Status</label>
			              		<cfloop list="#vaccinationStatus#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" name="FullyVaccinated" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
		              		</div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Position</label>
			              		<cfloop list="#bballPosition#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" name="position" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
		              		</div>
		              </div>
		              <div class="row">
			              <div class="col-md-6 ml-auto mr-auto nonTextQuestions">
			                  <div class="form-group">
			                    <label>Height</label><br>
								<select name="height" style="padding: 7px;">
								  <cfloop list="#heightOptions#" index="i" item="x">
								  	<option value="#x#">#x#</option>
								  </cfloop>
								</select>
			                  </div>
			               </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Weight</label>
		                    <input type="number" class="form-control border-input" placeholder="Weight" name="weight">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Hometown</label>
		                    <input type="text" class="form-control border-input" placeholder="Hometown" name="hometown">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Last School Attended</label>
		                    <input type="text" class="form-control border-input" placeholder="Last School Attended" name="school">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Why do you like basketball?</label>
		                    <input type="text" class="form-control border-input" name="whyBasketball">
		                  </div>
		                </div>
		              </div>
	                  <!--- <div class="form-group">
						  Are you over 18?
						 <input class="registerRadio firstRadio" type="radio" name="over18" value="1"> Yes
						 <input class="registerRadio secondRadio" type="radio" name="over18" value="0"> No
                	  </div> --->
		              <!--- <div class="form-group">
		                <label>Description</label>
		                <textarea class="form-control textarea-limited" placeholder="This is a textarea limited to 150 characters." rows="3" maxlength="150"></textarea>
		                <h5><small><span id="textarea-limited-message" class="pull-right">150 characters left</span></small></h5>
		              </div>
		              <label>Notifications</label> ---> 
		              <ul class="notifications">
		                <li class="notification-item">
		                  Are you over 18?
		                  <input type="checkbox" name="over18" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                  Are you a free agent?
		                  <input type="checkbox" name="freeAgent" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                  Do we have your permission to share above information on our website for Player Profiles?
		                  <input type="checkbox" name="permissionToShare" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                  Do you wish to play in the Master's League? (Age 40+)
		                  <input type="checkbox" name="mastersLeague" data-toggle="switch" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                	<!--- Divider --->
		                </li>
		              </ul>
		            <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##waiverModal">
		              Athletic Waiver
		            </button>
		            <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##photoModal">
		              Photo/Video Waiver
		            </button>
		              <ul class="notifications acknowledged">
		                <li class="notification-item">
		                  I have acknowledged, read, and agreed to the terms of the Athletic Waiver.
				            <div class="form-check">
				              <label class="form-check-label">
				                <input class="form-check-input waiverCheck" type="checkbox" value="1" name="athleticWaiver">
				                <span class="form-check-sign"></span>
				              </label>
				            </div>
		                </li>
		                <li class="notification-item">
		                  I have acknowledged, read, and agreed to the terms of the Photo/Video Waiver.
				            <div class="form-check">
				              <label class="form-check-label">
				                <input class="form-check-input waiverCheck" type="checkbox" value="1" name="photoWaiver">
				                <span class="form-check-sign"></span>
				              </label>
				            </div>
		                </li>
		              </ul>
		              <div class="text-center errorDiv">
		                <span class="errorMessage"></span>
		              </div>
		              <div class="text-center">
		                <button type="submit" class="btn btn-wd btn-info btn-round saveBtn" disabled>Save</button>
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
<script src="../Register/register.js?v=1.1"></script>