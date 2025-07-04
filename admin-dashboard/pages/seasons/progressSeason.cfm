<cfoutput>
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

	<!-- 2. Activate the new season, deactivate the old one, and move teams -->
	<cfquery name="updateLatestSeasonToActive" datasource="roundleague">
		UPDATE seasons
		SET status = 'Active'
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">;

		UPDATE seasons
		SET status = 'Inactive'
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">;

		UPDATE teams
		SET seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>

	<!-- 3. Copy roster records -->
	<cfquery name="transferPlayersToNextSeason" datasource="roundleague">
		INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
		SELECT playerID, teamID, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, divisionID, jersey
		FROM roster
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>

	<!-- 4. Copy leagues -->
	<cfquery name="transferLeaguesToNextSeason" datasource="roundleague">
		INSERT INTO leagues (seasonID, LeagueName)
		SELECT <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, LeagueName
		FROM leagues
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>

	<!-- 5. Final toast -->
	<cfset toastMsg = 'Successfully progressed to #getNewSeason.SeasonName# Season!'>
</cfoutput>
