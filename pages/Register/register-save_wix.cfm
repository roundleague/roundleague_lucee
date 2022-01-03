<cfinclude template="/header-wix.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<cfquery name="checkDuplicate" datasource="roundleague">
	SELECT PlayerID
	FROM Players
	WHERE Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
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
			Instagram
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
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Instagram#">
		)
	</cfquery>
	<cfset newPlayerId = playerAdd.GENERATEDKEY>
	<cfquery name="addToRoster" datasource="roundleague">
		INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID)
		VALUES
		(
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerId#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
			(
				SELECT DivisionID 
				From Teams 
				Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
			)
		)
	</cfquery>
	<cfset toastMessage = "Player Registration info successfully submitted! Note: If you signed up as a free agent, you will be contacted if a free agent spot opens up.">
<cfelse>
	<!--- We use the duplicate playerID email to Insert Into Roster --->
	<cfquery name="checkRosterDuplicate" datasource="roundleague">
		SELECT playerID
		FROM Roster
		Where playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.PlayerID#">
		AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	</cfquery>	
	<cfif checkRosterDuplicate.recordCount EQ 0>
		<!--- User has a record in player table but not current roster, season --->
		<cfquery name="addToRoster" datasource="roundleague">
			INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey)
			VALUES
			(
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.PlayerID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
				(
					SELECT DivisionID 
					From Teams 
					Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
				),
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.currentJersey#">
			)
		</cfquery>
		<cfset toastMessage = "Player Registration info successfully submitted! Note: If you signed up as a free agent, you will be contacted if a free agent spot opens up.">
	<cfelse>
		<!--- User has a record in current roster, season --->
		<cfset toastMessage = "Player with email has already been added for this season.">
	</cfif>
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
<cfinclude template="/footer-wix.cfm">