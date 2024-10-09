<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<cfset duplicateMsg = 'Duplicate team name, please press back on your browser and enter a different team name.'>
<cfset successConfirmMsg = 'Thank you for submitting your registration for The Round League! We are are excited about the possibility of having your team join the best competitive basketball league in Portland.'>

<cfquery name="checkDuplicate" datasource="roundleague">
	SELECT teamName
	FROM pending_teams
	WHERE teamName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.teamName#">
</cfquery>
<cfif !checkDuplicate.recordCount>
	<cfquery name="addTeam" datasource="roundleague" result="playerAdd">
		INSERT INTO pending_teams 
		(
			dateAdded,
			teamName,
			status,
			selectedDivision,
			captainFirstName,
			captainLastName,
			age,
			email,
			phoneNumber,
			highestLevel,
			dayPreference,
			primaryTimePref,
			secondaryTimePref,
			playerCountEstimate
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), "mm/dd/yyyy")#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.teamName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Pending">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.divisionSelect#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.age#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.highestLevel#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.dayPreference#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.primaryTimePref#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.secondaryTimePref#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.numberOfPlayers#">
		)
	</cfquery>	
</cfif>


<!--- Convert birthday to age --->

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

      	<cfif checkDuplicate.recordCount>
			 <p class="confirmation-message" style="font-size: 18px; font-weight: normal; color: ##2c3e50; padding: 20px; background-color: ##f4f4f9; border-radius: 10px;">Duplicate team name, please press back on your browser and enter a different team name.
		      </p>      		
      	<cfelse>
	        <p class="confirmation-message" style="font-size: 18px; font-weight: normal; color: ##2c3e50; padding: 20px; background-color: ##f4f4f9; border-radius: 10px;">
	          Thank you for submitting your registration for The Round League! We're excited about the possibility of having your team join the best competitive basketball league in Portland.
	        </p>

	        <p class="confirmation-message" style="font-size: 18px; font-weight: normal; color: ##2c3e50; padding: 10px; background-color: ##ffffff; border-radius: 10px;">
	          Here's what happens next:
	        </p>

	        <ul style="font-size: 16px; text-align: left; list-style-type: none; padding: 0;">
	            <li><strong>Team Slot Availability:</strong> We will reach out to confirm if there's a spot available for your team in the upcoming season.</li>
	            <li><strong>Confirm Your Availability:</strong> Once a spot is confirmed, we'll check your team's availability to ensure you're ready to play.</li>
	            <li><strong>Pay Your Deposit:</strong> To secure your place, you'll need to pay a deposit.</li>
	            <li><strong>Get Ready to Play:</strong> Once the deposit is received, get ready for an exciting season of competitive basketball!</li>
	        </ul>
      	</cfif>

      </div>
    </div>
</div>

</cfoutput>
<cfinclude template="/footer.cfm">
