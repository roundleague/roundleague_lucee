<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://demos.creative-tim.com/paper-kit-2-pro/assets/css/paper-kit.min.css?v=2.3.1" rel="stylesheet">
<cfoutput><link href="../RegisterTeam/registerTeam.css?v=#DateDiff('s', CreateDate(1970,1,1), Now())#" rel="stylesheet"></cfoutput>

<cfoutput>

<cfset leagueOptions = "Men's League,Women's League,Master's 40+ League">
<cfset playerCountOptions = "I have 8-10 Players,I will need players from Free Agency">
<cfset dayOptions = "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday">

<cfif isDefined("form.registerTeamSubmit")>
	<cfinclude template="registerTeam-save.cfm">
	<cfexit>
</cfif>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<div class="wrapper">
		    <div class="profile-content section" style="padding-top: 20px">
		      <div class="container" style="padding-bottom: 20px">
		      </div>

		      <div class="container">
		        <div class="row">
		          <div class="col-md-6 ml-auto mr-auto">
		            <h3 class="description">Register Your Team</h3>
		            <form class="settings-form" method="POST">

		              <div class="form-group">
		                <label>Team Name</label>
		                <input type="text" required class="form-control border-input" placeholder="Team Name" name="teamName">
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Which League are you Interested in Joining?</label>
			              		<cfloop list="#leagueOptions#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" required name="selectedDivision" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
			              		</div>
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Is everyone on your team over 18?</label>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="allPlayersOver18" value="Yes"> Yes
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="allPlayersOver18" value="No"> No
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              </div>
		              </div>

		              <div class="form-group">
		                <label>Team Captain/Manager's Name</label>
		                <input type="text" required class="form-control border-input" placeholder="Captain/Manager's Name" name="captainName">
		              </div>

		              <div class="form-group">
		                <label>Team Manager's Phone Number</label>
		                <input type="tel" required id="teamPhoneField" class="form-control border-input" name="phoneNumber" placeholder="123-456-7890">
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Player Count</label>
			              		<cfloop list="#playerCountOptions#" index="i" item="x">
						            <div class="form-check-radio">
						              <label class="form-check-label">
						                <input class="form-check-input" type="radio" required name="playerCountEstimate" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
			              </div>
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Team's Overall Level of Experience</label>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="highestLevel" value="1"> 1 - Recreational
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="highestLevel" value="2"> 2 - High School Varsity
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="highestLevel" value="3"> 3 - College
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="highestLevel" value="4"> 4 - D-1 University
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input" type="radio" required name="highestLevel" value="5"> 5 - Professional
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              </div>
		              </div>

		              <div class="form-group">
		                <label>Number of Players Fully Vaccinated</label>
		                <input type="number" min="0" max="12" required class="form-control border-input" placeholder="0" name="vaccinatedCount">
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">Preference for League Days</label>
			              		<cfloop list="#dayOptions#" index="i" item="x">
						            <div class="form-check">
						              <label class="form-check-label">
						                <input class="form-check-input" type="checkbox" name="dayPreference" value="#x#"> #x#
						                <span class="form-check-sign"></span>
						              </label>
						            </div>
					        	</cfloop>
			              </div>
		              </div>

		              <div class="row">
			              <div class="col-md-12 ml-auto mr-auto nonTextQuestions">
			              		<label class="biggerLabel">How did you hear about us?</label>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input referralRadio" type="radio" required name="referralSource" value="Friends"> Friends
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input referralRadio" type="radio" required name="referralSource" value="Instagram"> Instagram
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input referralRadio" type="radio" required name="referralSource" value="Website"> Website
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-check-radio">
			              		  <label class="form-check-label">
			              		    <input class="form-check-input referralRadio" type="radio" required name="referralSource" value="Other"> Other
			              		    <span class="form-check-sign"></span>
			              		  </label>
			              		</div>
			              		<div class="form-group" id="referralOtherItem" style="display:none;">
			              		  <input type="text" class="form-control border-input" placeholder="Please specify" name="referralOther" id="referralOtherInput">
			              		</div>
			              </div>
		              </div>

		              <input type="hidden" name="registerTeamSubmit" value="1">

		              <div class="text-center errorDiv">
		                <span class="errorMessage"></span>
		              </div>
		              <div class="text-center">
		                <button type="submit" class="btn btn-wd btn-info btn-round saveBtn">Submit Registration</button>
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
<cfoutput><script src="../RegisterTeam/registerTeam.js?v=#DateDiff('s', CreateDate(1970,1,1), Now())#"></script></cfoutput>
