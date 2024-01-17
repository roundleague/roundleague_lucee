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
			ZipCode,
			ShoeSize,
			ShoeType,
			AdidasConflict,
			AdidasInterestTesting
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
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zipCode#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.shoeSize#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.shoeType#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.brandTestingConflict#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.adidasTesting#">
		)
	</cfquery>
	<cfset newPlayerId = playerAdd.GENERATEDKEY>
	<cfquery name="addToRoster" datasource="roundleague">
		INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey)
		VALUES
		(
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerId#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonSelect#">,
			(
				SELECT DivisionID 
				From Teams 
				Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
			),
			<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.currentJersey#">
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
		<!--- This introduces a bug, if a player plays for 2 teams within the same season, their stats will be updated / combined each game. To avoid, have players register new emails per team (only applicable for Men's / Asian League players) --->

		<cfquery name="checkForPreviousPlayerNewTeam" datasource="roundleague">
			SELECT rosterID
		  	FROM roster
		  	WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">
		  	AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
		</cfquery>
		<cfif checkForPreviousPlayerNewTeam.recordCount>
			<cfquery name="removePlayer" datasource="roundleague">
				DELETE FROM roster
				WHERE rosterID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkForPreviousPlayerNewTeam.rosterID#">
			</cfquery>
		</cfif>

		<cfquery name="addToRoster" datasource="roundleague">
			INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey)
			VALUES
			(
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonSelect#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getDivision.DivisionID#">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.currentJersey#">
			)
		</cfquery>

		<!--- If returning player, save Adidas Information --->
		<cfquery name="updateAdidasInfo" datasource="roundleague">
			UPDATE players
				SET ShoeSize = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.shoeSize#">,
					ShoeType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.shoeType#">,
					AdidasConflict = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.brandTestingConflict#">,
					AdidasInterestTesting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.adidasTesting#">
			WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">
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