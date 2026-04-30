<cfoutput>
	<cfparam name="form.copyDivisions" default="0">
	<cfparam name="form.divisionMappings" default="">
	
	<!-- 1. Get the new season name and previous season ID -->
	<cfquery name="getNewSeason" datasource="roundleague">
		SELECT SeasonName
		FROM Seasons
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
	</cfquery>

	<cfquery name="getPreviousSeasonID" datasource="roundleague">
		SELECT PreviousSeasonID
		FROM Seasons
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
	</cfquery>

	<!-- 2. Copy leagues FIRST so we can map old league IDs to new ones for divisions -->
	<cfset leagueMapping = {}>
	<cfquery name="getOldLeagues" datasource="roundleague">
		SELECT leagueID, LeagueName
		FROM leagues
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>
	<cfloop query="getOldLeagues">
		<cfquery name="insertNewLeague" datasource="roundleague">
			INSERT INTO leagues (seasonID, LeagueName)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getOldLeagues.LeagueName#">
			)
		</cfquery>
		<cfquery name="getNewLeagueID" datasource="roundleague">
			SELECT LAST_INSERT_ID() AS newLeagueID
		</cfquery>
		<cfset leagueMapping[getOldLeagues.leagueID] = getNewLeagueID.newLeagueID>
	</cfloop>

	<!-- 3. Copy divisions (before moving teams) so we can map old -> new IDs -->
	<cfset divisionMapping = {}>
	<cfset skippedDivisions = []>
	<cfif form.copyDivisions EQ "1">
		<!--- Parse division mappings from form --->
		<cfset existingDivisions = []>
		<cfset newDivisions = []>
		
		<cfif len(trim(form.divisionMappings)) AND isJSON(form.divisionMappings)>
			<cfset mappingsData = deserializeJSON(form.divisionMappings)>
			
			<!--- Handle both old array format and new object format --->
			<cfif isArray(mappingsData)>
				<!--- Old format: simple array --->
				<cfset existingDivisions = mappingsData>
			<cfelseif isStruct(mappingsData)>
				<!--- New format: object with existingDivisions and newDivisions --->
				<cfif structKeyExists(mappingsData, "existingDivisions")>
					<cfset existingDivisions = mappingsData.existingDivisions>
				</cfif>
				<cfif structKeyExists(mappingsData, "newDivisions")>
					<cfset newDivisions = mappingsData.newDivisions>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Build lookup for which divisions to copy and their new names --->
		<cfset divisionCopyMap = {}>
		<cfloop array="#existingDivisions#" index="mapping">
			<cfset divisionCopyMap[mapping.divisionID] = {
				"copy": structKeyExists(mapping, "copy") ? mapping.copy : true,
				"newName": mapping.newName
			}>
		</cfloop>
		
		<!--- Get all divisions from previous season --->
		<cfquery name="getOldDivisions" datasource="roundleague">
			SELECT divisionID, divisionName, isWomens, leagueID
			FROM divisions
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
		</cfquery>
		
		<!--- Insert each division that should be copied --->
		<cfloop query="getOldDivisions">
			<!--- Check if this division should be copied --->
			<cfset shouldCopy = true>
			<cfset newDivisionName = getOldDivisions.divisionName>
			
			<cfif structKeyExists(divisionCopyMap, getOldDivisions.divisionID)>
				<cfset shouldCopy = divisionCopyMap[getOldDivisions.divisionID].copy>
				<cfif shouldCopy AND len(trim(divisionCopyMap[getOldDivisions.divisionID].newName))>
					<cfset newDivisionName = divisionCopyMap[getOldDivisions.divisionID].newName>
				</cfif>
			</cfif>
			
			<cfif shouldCopy>
				<!--- Map old leagueID to new leagueID, fallback to 0 if not found --->
				<cfset newLeagueID = structKeyExists(leagueMapping, getOldDivisions.leagueID) ? leagueMapping[getOldDivisions.leagueID] : 0>
				<cfquery name="insertNewDivision" datasource="roundleague">
					INSERT INTO divisions (seasonID, divisionName, isWomens, leagueID)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newDivisionName#">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getOldDivisions.isWomens#">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newLeagueID#">
					)
				</cfquery>
				
				<cfquery name="getNewDivisionID" datasource="roundleague">
					SELECT LAST_INSERT_ID() AS newDivisionID
				</cfquery>
				
				<cfset divisionMapping[getOldDivisions.divisionID] = getNewDivisionID.newDivisionID>
			<cfelse>
				<!--- Track skipped divisions - teams will need reassignment --->
				<cfset arrayAppend(skippedDivisions, getOldDivisions.divisionID)>
			</cfif>
		</cfloop>
		
		<!--- Create any brand new divisions --->
		<cfloop array="#newDivisions#" index="newDiv">
			<cfif len(trim(newDiv.newName))>
				<cfquery name="insertBrandNewDivision" datasource="roundleague">
					INSERT INTO divisions (seasonID, divisionName, isWomens, leagueID)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newDiv.newName#">,
						0,
						(SELECT leagueID FROM leagues WHERE leagueName = 'Round League' LIMIT 1)
					)
				</cfquery>
			</cfif>
		</cfloop>
		
		<cfset divisionMsg = " Divisions configured.">
	<cfelse>
		<cfset divisionMsg = "">
	</cfif>

	<!-- 4. Activate the new season, deactivate the old one -->
	<cfquery name="updateSeasonStatuses" datasource="roundleague">
		UPDATE seasons
		SET status = 'Active'
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">;

		UPDATE seasons
		SET status = 'Inactive'
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>

	<!-- 5. Move teams to new season and update their divisionIDs to new divisions -->
	<cfif form.copyDivisions EQ "1" AND NOT structIsEmpty(divisionMapping)>
		<!--- Update each team's divisionID to the new mapped division --->
		<cfloop collection="#divisionMapping#" item="oldDivID">
			<cfquery name="updateTeamsDivision" datasource="roundleague">
				UPDATE teams
				SET seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">,
				    divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divisionMapping[oldDivID]#">
				WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
				AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#oldDivID#">
			</cfquery>
		</cfloop>
		
		<!--- Handle teams from skipped divisions - set divisionID to 0 (unassigned) --->
		<cfif arrayLen(skippedDivisions) GT 0>
			<cfloop array="#skippedDivisions#" index="skippedDivID">
				<cfquery name="updateSkippedTeams" datasource="roundleague">
					UPDATE teams
					SET seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">,
					    divisionID = 0
					WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
					AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#skippedDivID#">
				</cfquery>
			</cfloop>
		</cfif>
		
		<!--- Move any remaining teams that weren't in a division --->
		<cfquery name="updateRemainingTeams" datasource="roundleague">
			UPDATE teams
			SET seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
		</cfquery>
	<cfelse>
		<!--- Just move teams without updating divisions --->
		<cfquery name="updateTeamsSeasonOnly" datasource="roundleague">
			UPDATE teams
			SET seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
		</cfquery>
	</cfif>

	<!-- 6. Copy roster records (also update divisionID if divisions were copied) -->
	<cfif form.copyDivisions EQ "1" AND NOT structIsEmpty(divisionMapping)>
		<cfloop collection="#divisionMapping#" item="oldDivID">
			<cfquery name="transferRosterWithDivision" datasource="roundleague">
				INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
				SELECT playerID, teamID, 
				       <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, 
				       <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divisionMapping[oldDivID]#">, 
				       jersey
				FROM roster
				WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
				AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#oldDivID#">
			</cfquery>
		</cfloop>
		
		<!--- Copy roster records from skipped divisions - set divisionID to 0 --->
		<cfif arrayLen(skippedDivisions) GT 0>
			<cfloop array="#skippedDivisions#" index="skippedDivID">
				<cfquery name="transferSkippedRoster" datasource="roundleague">
					INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
					SELECT playerID, teamID, 
					       <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, 
					       0, 
					       jersey
					FROM roster
					WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
					AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#skippedDivID#">
				</cfquery>
			</cfloop>
		</cfif>
		
		<!--- Copy any roster records without a division --->
		<cfquery name="transferRemainingRoster" datasource="roundleague">
			INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
			SELECT playerID, teamID, 
			       <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, 
			       divisionID, 
			       jersey
			FROM roster
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
			AND (divisionID = 0 OR divisionID IS NULL)
		</cfquery>
	<cfelse>
		<cfquery name="transferPlayersToNextSeason" datasource="roundleague">
			INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
			SELECT playerID, teamID, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, divisionID, jersey
			FROM roster
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
		</cfquery>
	</cfif>

	<!-- 7. Final toast -->
	<cfset toastMsg = 'Successfully progressed to #getNewSeason.SeasonName# Season!#divisionMsg#'>
</cfoutput>
