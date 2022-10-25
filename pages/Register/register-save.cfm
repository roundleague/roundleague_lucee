<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<cfset teamObject = createObject("component", "library.teams") />
<cfset teamName = teamObject.getTeamNameByTeamID(form.teamID)>

<cfquery name="checkDuplicate" datasource="roundleague">
	SELECT PlayerID, firstName, lastName
	FROM Players
	WHERE Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
	ORDER BY playerID DESC
</cfquery>
<cfif checkDuplicate.recordCount EQ 0>
	<cfquery name="addPlayer" datasource="roundleague" result="playerAdd">
		INSERT INTO Players 
		(
			RegisterDate, 
			Email, 
			FirstName, 
			LastName, 
			BirthDate, 
			Phone, 
			HighestLevel, 
			FullyVaccinated,
			FreeAgent,
			Position,
			Height,
			Weight,
			Hometown,
			School,
			PermissionToShare,
			Instagram,
			Gender,
			MastersLeague,
			ZipCode
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), "mm/dd/yyyy")#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastName#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(form.birthDate, "mm/dd/yyyy")#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Phone#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.HighestLevel#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.FullyVaccinated#">,
			<cfif isDefined("form.freeAgent")>'Yes'<cfelse>'No'</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Position#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Height#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Weight#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Hometown#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.School#">,
			<cfif isDefined("form.PermissionToShare")>'Yes'<cfelse>'No'</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Instagram#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Gender#">,
			<cfif isDefined("form.MastersLeague")>'Yes'<cfelse>'No'</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zipCode#">
		)
	</cfquery>
	<cfset newPlayerId = playerAdd.GENERATEDKEY>
	<cfquery name="addToRoster" datasource="roundleague">
		INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID)
		VALUES
		(
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerId#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonSelect#">,
			(
				SELECT DivisionID 
				From Teams 
				Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
			)
		)
	</cfquery>
	<!--- If captain checkbox selected, set them as team captain --->
	<cfif isDefined("form.captainCheck")>
		<cfquery name="setCaptainId" datasource="roundleague">
			UPDATE Teams
			SET captainPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerId#">
			WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
		</cfquery>
	</cfif>

	<cfset toastMessage = "Player Registration info successfully submitted! Note: If you signed up as a free agent, you will be contacted if a free agent spot opens up.">
<cfelse>
	<cfquery name="getDivision" datasource="roundleague">
		SELECT DivisionID 
		From Teams 
		Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
	</cfquery>
	<!--- Get team name by id --->
	<cftry>
		<!--- If duplicate player, use old player id to insert into new roster record --->
		<cfquery name="addToRoster" datasource="roundleague">
			INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID)
			VALUES
			(
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonSelect#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getDivision.DivisionID#">
			)
		</cfquery>
		<cfset toastMessage = "Welcome back #checkDuplicate.firstName#, you have successfully been added to #teamName#.">
	<cfcatch>
		<cfdump var="#cfcatch#" /><cfabort />
	</cfcatch>
	</cftry>
</cfif>

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <p class="toastMessage">#toastMessage#</p>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">