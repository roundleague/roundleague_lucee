<!--- Teams Component --->
<cfcomponent displayname="Teams" hint="ColdFusion Component for Teams">
 <cffunction name="getOpponent"
	hint="Get opponent based on 3 teams" returntype="string">
	<cfargument name="homeTeam" default="" required="yes" type="string">
	<cfargument name="awayTeam" default="" required="yes" type="string">
	<cfargument name="userTeam" default="" required="yes" type="string">

		<cfif homeTeam EQ userTeam>
			<cfreturn awayTeam>
		<cfelseif awayTeam EQ userTeam>
			<cfreturn homeTeam>
		<cfelse>
			<cfreturn ''>
		</cfif>
		
 </cffunction>

 <cffunction name="getCurrentSessionTeam"
	hint="Get current session team based on logged in sessionID" returntype="struct">
	<cfargument name="playerID" default="" required="yes" type="numeric">

		<cfquery name="getTeam" datasource="roundleague">
		    SELECT t.teamName, t.teamID
		    FROM players p
		    JOIN roster r on r.playerID = p.playerID
		    JOIN teams t on t.teamID = r.teamID 
		    WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
		    AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#playerID#">
		    AND t.status = 'Active'
		</cfquery>

		<cfset teamObject = {
		  teamName = getTeam.teamName,
		  teamID = getTeam.teamID
		}>

		<cfreturn teamObject>
		
 </cffunction>

 <cffunction name="updateTeamStatus" returntype="any" access="remote" returnformat="json">
 	<cfargument name="status" default="" required="yes" type="string">
 	<cfargument name="teamID" default="" required="yes" type="numeric">

 		<cftry>
 			<cfquery name="updateStatus" datasource="roundleague">
 				UPDATE Teams
 				SET status = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#status#">
 				WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamID#">
 			</cfquery>

 			<cfcatch>
 				<cfreturn cfcatch.message>
 			</cfcatch>
 		</cftry>

 		<cfreturn 'Success'>
 </cffunction> 

  <cffunction name="searchDuplicateCaptains" returntype="any" access="remote" returnformat="json"
	hint="Find existing players matching a pending team's captain by exact name, phone, or email, for duplicate-detection at approval time">
	<cfargument name="firstName" default="" required="yes" type="string">
	<cfargument name="lastName" default="" required="yes" type="string">
	<cfargument name="phone" default="" required="yes" type="string">
	<cfargument name="email" default="" required="no" type="string">

		<cfquery name="matches" datasource="roundleague">
			SELECT p.PlayerID, p.firstName, p.lastName, p.Email, p.Phone, p.Status, p.Team,
			       IFNULL(d.DivisionName, 'N/A') AS DivisionName
			FROM players p
			LEFT JOIN divisions d ON d.DivisionID = p.DivisionID
			WHERE p.mergedIntoPlayerID IS NULL
			AND (
				(
					LOWER(TRIM(p.firstName)) = LOWER(TRIM(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#firstName#">))
					AND LOWER(TRIM(p.lastName)) = LOWER(TRIM(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#lastName#">))
				)
				OR p.Phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#phone#">
				OR (
					LENGTH(TRIM(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#email#">)) > 0
					AND LOWER(TRIM(p.Email)) = LOWER(TRIM(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#email#">))
				)
			)
			ORDER BY p.PlayerID DESC
		</cfquery>

		<cfset results = []>
		<cfloop query="matches">
			<cfset arrayAppend(results, {
				"PlayerID": matches.PlayerID,
				"firstName": matches.firstName,
				"lastName": matches.lastName,
				"Email": matches.Email,
				"Phone": matches.Phone,
				"Status": matches.Status,
				"Team": matches.Team,
				"DivisionName": matches.DivisionName
			})>
		</cfloop>

		<cfreturn results>
 </cffunction>

  <cffunction name="approvePendingTeam" returntype="any" access="remote" returnformat="json"
	hint="Approve a pending team registration: create or link the captain as a player, create the team, and remove the pending record">
	<cfargument name="pendingTeamID" default="" required="yes" type="numeric">
	<cfargument name="divisionID" default="" required="yes" type="numeric">
	<cfargument name="seasonID" default="" required="yes" type="numeric">
	<cfargument name="linkPlayerID" default="0" required="no" type="numeric">

		<cftry>
			<cftransaction>

				<cfquery name="getPending" datasource="roundleague">
					SELECT * FROM pending_teams
					WHERE pending_teamsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pendingTeamID#">
				</cfquery>

				<cfif getPending.recordCount EQ 0>
					<cfreturn "Pending team not found.">
				</cfif>

				<cfif linkPlayerID GT 0>
					<!--- Link to an existing player instead of creating a new one.
					      Players must re-register each season per the site's own
					      "returning player" notice, so refreshing these fields is
					      expected rather than a data-loss risk. --->
					<cfquery name="updateExistingCaptain" datasource="roundleague">
						UPDATE players
						SET Phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.phoneNumber#">,
						    Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.email#">,
						    Status = 'Active',
						    DivisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divisionID#">
						WHERE PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#linkPlayerID#">
					</cfquery>
					<cfset newPlayerID = linkPlayerID>
				<cfelse>
					<!--- Auto-create the captain as a player. BirthDate is NOT NULL with no
					      real value collected on the registration form (only a team-wide
					      over-18 yes/no), so a sentinel placeholder date is used. --->
					<cfquery name="addCaptainPlayer" datasource="roundleague" result="playerInsertResult">
						INSERT INTO players
						(RegisterDate, Email, firstName, lastName, BirthDate, Phone,
						 HighestLevel, FreeAgent, position, height, weight, hometown,
						 School, PermissionToShare, Status, PhotoURL, Instagram,
						 DivisionID, Team, MastersLeague, is_youth)
						VALUES
						(
							<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), 'mm/dd/yyyy')#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.email#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.captainFirstName#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.captainLastName#">,
							<cfqueryparam cfsqltype="cf_sql_date" value="1900-01-01">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.phoneNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.highestLevel#">,
							'No',
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							'No',
							'Active',
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divisionID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.teamName#">,
							'No',
							0
						)
					</cfquery>
					<cfset newPlayerID = playerInsertResult.GENERATEDKEY>
				</cfif>

				<cfquery name="addTeam" datasource="roundleague">
					INSERT INTO Teams (Status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID)
					VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="Active">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#getPending.teamName#">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newPlayerID#">,
						<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(now(), 'mm/dd/yyyy')#">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divisionID#">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#seasonID#">
					)
				</cfquery>

				<cfquery name="deletePending" datasource="roundleague">
					DELETE FROM pending_teams
					WHERE pending_teamsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pendingTeamID#">
				</cfquery>

			</cftransaction>

			<cfcatch>
				<cfreturn cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn 'Success'>
 </cffunction>

 <cffunction name="rejectPendingTeam" returntype="any" access="remote" returnformat="json"
	hint="Mark a pending team registration as Rejected (kept for later review, not deleted)">
	<cfargument name="pendingTeamID" default="" required="yes" type="numeric">

		<cftry>
			<cfquery name="rejectPending" datasource="roundleague">
				UPDATE pending_teams
				SET status = 'Rejected'
				WHERE pending_teamsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pendingTeamID#">
			</cfquery>

			<cfcatch>
				<cfreturn cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn 'Success'>
 </cffunction>

 <cffunction name="restorePendingTeam" returntype="any" access="remote" returnformat="json"
	hint="Move a rejected registration back to Pending">
	<cfargument name="pendingTeamID" default="" required="yes" type="numeric">

		<cftry>
			<cfquery name="restorePending" datasource="roundleague">
				UPDATE pending_teams
				SET status = 'Pending'
				WHERE pending_teamsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pendingTeamID#">
			</cfquery>

			<cfcatch>
				<cfreturn cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn 'Success'>
 </cffunction>

 <cffunction name="deletePendingTeam" returntype="any" access="remote" returnformat="json"
	hint="Permanently delete a pending team registration (e.g. a previously-rejected row the admin is done reviewing)">
	<cfargument name="pendingTeamID" default="" required="yes" type="numeric">

		<cftry>
			<cfquery name="deletePending" datasource="roundleague">
				DELETE FROM pending_teams
				WHERE pending_teamsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pendingTeamID#">
			</cfquery>

			<cfcatch>
				<cfreturn cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn 'Success'>
 </cffunction>

  <cffunction name="getTeamNameByTeamID"
	hint="Get team name by teamID" returntype="string">
	<cfargument name="teamID" default="" required="yes" type="numeric">

		<cfquery name="getTeam" datasource="roundleague">
		    SELECT teamName
		    FROM teams
		    WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamID#">
		</cfquery>

		<cfreturn getTeam.teamName>
		
 </cffunction>
</cfcomponent>