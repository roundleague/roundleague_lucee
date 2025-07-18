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
	<cfquery name="addPlayerUser" datasource="roundleague">
			INSERT INTO users (
				userName,
				password,
				dateModified,
				playerID,
				status,
				role
			)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(form.password, 'SHA')#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), 'yyyy-mm-dd')#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#newPlayerId#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Active">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Player">
		)
	</cfquery>
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

		<cfquery name="addUserIfCaptain" datasource="roundleague">
			UPDATE users
			SET role = 'Captain'
			WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerId#">
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

		<cfquery name="updatePlayer" datasource="roundleague">
			UPDATE Players 
			SET 
				Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
				FirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstName#">,
				LastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastName#">,
				BirthDate = <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(form.birthDate, "mm/dd/yyyy")#">,
				Phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Phone#">,
				HighestLevel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.HighestLevel#">,
				FreeAgent = <cfif isDefined("form.freeAgent")>'Yes'<cfelse>'No'</cfif>,
				Position = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Position#">,
				Height = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Height#">,
				Weight = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Weight#">,
				Hometown = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Hometown#">,
				School = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.School#">,
				PermissionToShare = <cfif isDefined("form.PermissionToShare")>'Yes'<cfelse>'No'</cfif>,
				Instagram = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Instagram#">,
				Gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Gender#">,
				MastersLeague = <cfif isDefined("form.MastersLeague")>'Yes'<cfelse>'No'</cfif>,
				ZipCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zipCode#">
			WHERE PlayerID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkDuplicate.playerID#">
		</cfquery>

		<cfquery name="addPlayerUser" datasource="roundleague" result="playerAdd">
			INSERT INTO users (
				playerID,
				userName,
				password,
				dateModified,
				status,
				role
			)
			SELECT 
				<cfqueryparam cfsqltype="cf_sql_integer" value="#checkDuplicate.playerID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(form.password, 'SHA')#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), 'yyyy-mm-dd')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="Active">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="Player">
			FROM dual
			WHERE NOT EXISTS (
				SELECT 1 
				FROM users 
				WHERE userName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
			)
		</cfquery>


		<!--- If captain checkbox selected, set them as team captain --->
		<cfif isDefined("form.captainCheck")>
			<cfquery name="setCaptainId" datasource="roundleague">
				UPDATE Teams
				SET captainPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">
				WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
			</cfquery>

			<cfquery name="addUserIfCaptain" datasource="roundleague">
				UPDATE users
				SET role = 'Captain'
				WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#checkDuplicate.playerID#">
			</cfquery>
		</cfif>

		<cfset toastMessage = "Welcome back #checkDuplicate.firstName#, you have successfully been added to #teamName#">
		<cfif isDefined("form.captainCheck")>
			<cfset toastMessage &= ". You are now the captain of #teamName#.">
		</cfif>
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
		<a href="/pages/Login/captains_login.cfm" class="btn btn-primary btn-round mt-3">Log In to Your Account</a>

	  </div>
	</div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">