<cfparam name="form.dayPreference" default="">
<cfparam name="form.vaccinatedCount" default="">
<cfparam name="form.referralOther" default="">

<!--- Required-field validation. Every field checked here maps to a NOT NULL
      column with no usable default, so a missing value must never reach the
      INSERT below (send the user back to the form instead of crashing). --->
<cfset local.missingFields = []>
<cfif len(trim(form.teamName)) EQ 0><cfset arrayAppend(local.missingFields, "Team Name")></cfif>
<cfif len(trim(form.selectedDivision)) EQ 0><cfset arrayAppend(local.missingFields, "League")></cfif>
<cfif len(trim(form.allPlayersOver18)) EQ 0><cfset arrayAppend(local.missingFields, "Over 18 confirmation")></cfif>
<cfif len(trim(form.captainName)) EQ 0><cfset arrayAppend(local.missingFields, "Captain Name")></cfif>
<cfif len(trim(form.phoneNumber)) EQ 0><cfset arrayAppend(local.missingFields, "Phone Number")></cfif>
<cfif len(trim(form.playerCountEstimate)) EQ 0><cfset arrayAppend(local.missingFields, "Player Count")></cfif>
<cfif len(trim(form.highestLevel)) EQ 0><cfset arrayAppend(local.missingFields, "Level of Experience")></cfif>
<cfif NOT len(trim(form.vaccinatedCount)) OR NOT isNumeric(form.vaccinatedCount) OR form.vaccinatedCount LT 0 OR form.vaccinatedCount GT 12>
  <cfset arrayAppend(local.missingFields, "Number of Players Fully Vaccinated (0-12)")>
</cfif>
<cfif len(trim(form.referralSource)) EQ 0><cfset arrayAppend(local.missingFields, "How you heard about us")></cfif>

<cfif len(trim(form.teamName)) GT 200 OR len(trim(form.captainName)) GT 200>
  <cfthrow message="Team name and captain name must be under 200 characters.">
</cfif>

<cfif arrayLen(local.missingFields)>
  <cfoutput>
  <div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">
        <p class="toastMessage" style="color: red;">Please go back and fill out all required fields: #arrayToList(local.missingFields, ", ")#</p>
        <a href="/pages/RegisterTeam/registerTeam.cfm" class="btn btn-primary btn-round mt-3">Back to Registration Form</a>
      </div>
    </div>
  </div>
  </cfoutput>
  <cfexit>
</cfif>

<cfset local.suspiciousPattern = "(?i)(pg_sleep|waitfor\s+delay|dbms_pipe|union\s+select|sleep\s*\()">
<cfif reFind(local.suspiciousPattern, form.teamName)
      OR reFind(local.suspiciousPattern, form.captainName)
      OR reFind(local.suspiciousPattern, form.phoneNumber)
      OR reFind(local.suspiciousPattern, form.referralOther)>
  <cflog file="register_security" type="warning"
         text="Suspicious team registration payload rejected from #cgi.remote_addr# teamName=#htmlEditFormat(form.teamName)#">
  <cfthrow message="Invalid characters in submitted fields.">
</cfif>

<!--- Split captain name into first/last (first word / remainder) --->
<cfset local.cleanCaptainName = trim(form.captainName)>
<cfset local.firstSpacePos = find(" ", local.cleanCaptainName)>
<cfif local.firstSpacePos>
  <cfset local.captainFirstName = left(local.cleanCaptainName, local.firstSpacePos - 1)>
  <cfset local.captainLastName = trim(mid(local.cleanCaptainName, local.firstSpacePos + 1, len(local.cleanCaptainName)))>
<cfelse>
  <cfset local.captainFirstName = local.cleanCaptainName>
  <cfset local.captainLastName = "">
</cfif>

<!--- "Other" free-text only applies when Other was actually selected --->
<cfset local.referralOtherValue = (form.referralSource EQ "Other") ? form.referralOther : "">

<cfquery name="addPendingTeam" datasource="roundleague">
  INSERT INTO pending_teams
  (
    teamName, selectedDivision, status, captainFirstName, captainLastName,
    allPlayersOver18, phoneNumber, highestLevel, playerCountEstimate,
    vaccinatedCount, dayPreference, referralSource, referralOther, dateAdded
  )
  VALUES
  (
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.teamName#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectedDivision#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.captainFirstName#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.captainLastName#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.allPlayersOver18#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phoneNumber#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.highestLevel#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.playerCountEstimate#">,
    <cfqueryparam cfsqltype="cf_sql_integer" value="#form.vaccinatedCount#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.dayPreference#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.referralSource#">,
    <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.referralOtherValue#">,
    <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), 'mm/dd/yyyy')#">
  )
</cfquery>

<cflog file="register_security" type="information"
       text="New team registration submitted: teamName=#htmlEditFormat(form.teamName)# IP=#cgi.remote_addr#">

<cfset toastMessage = "Thank you! Your team registration has been submitted and is pending review. We'll follow up with you shortly.">

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
	<div class="section text-center">
	  <div class="container">

		<!--- Content Here --->
		<p class="toastMessage">#toastMessage#</p>
		<a href="/" class="btn btn-primary btn-round mt-3">Return to Home</a>

	  </div>
	</div>
</div>
</cfoutput>
