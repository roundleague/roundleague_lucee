<cfoutput>
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
	<cfquery name="transferPlayersToNextSeason" datasource="roundleague">
		INSERT INTO roster (playerID, teamID, seasonID, divisionID, jersey)
		SELECT playerID, teamID, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, divisionID, jersey
		FROM roster
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>
	<cfset toastMsg = 'Successfully progressed to #getNewSeason.SeasonName# Season!'>

</cfoutput>