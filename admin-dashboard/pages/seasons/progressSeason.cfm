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
	<cfquery name="transferLeaguesToNextSeason" datasource="roundleague">
		INSERT INTO leagues (seasonID, LeagueName)
		SELECT <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, LeagueName
		FROM leagues
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>
	<!--- Grab new leagues based on name, (get latest leagueID top 1, then insert here) --->
	<cfquery name="transferDivisionsToNextSeason" datasource="roundleague">
		INSERT INTO divisions (seasonID, DivisionName, IsWomens, LeagueID)
		SELECT <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">, DivisionName, IsWomens, (SELECT LeagueID 
			FROM leagues
			WHERE leagueName = (SELECT leagueName FROM leagues WHERE leagueID = d.leagueID)
			ORDER BY leagueID DESC
			LIMIT 1)
		FROM divisions d
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>
	<!--- Copy all schedule games from previous season to new season, then edit from there --->
	<!--- Grab new divisions based on name, (get latest divisionID top 1, then insert here) --->
	<cfquery name="transferScheduleToNextSeason" datasource="roundleague">
		INSERT INTO schedule (HomeTeamID, AwayTeamID, Week, StartTime, Date, DivisionID, SeasonID)
		SELECT HomeTeamID, AwayTeamID, Week, StartTime, Date, (SELECT DivisionID 
			FROM Divisions
			WHERE DivisionName = (SELECT DivisionName FROM Divisions WHERE DivisionID = s.divisionID)
			ORDER BY DivisionID DESC
			LIMIT 1), <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
		FROM schedule s 
		WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPreviousSeasonID.PreviousSeasonID#">
	</cfquery>
	<!--- Update teams divisionID in teams table to new divisions --->
	<cfquery name="getActiveTeams">
		SELECT teamID
		FROM teams
		WHERE STATUS = 'active'
	</cfquery>
	<!--- Technical Debt: Ideally we want to loop while we are in cfquery, just don't remember syntax for it --->
	<cfloop query="getActiveTeams">
		<!--- Order by week ONLY WORKS if first game of season is NOT a Non-Divisional Game --->
		<cfquery name="transferScheduleToNextSeason" datasource="roundleague" result="updateQuery">
			UPDATE teams
			SET divisionID = (	
								SELECT divisionID
								FROM schedule
								WHERE (hometeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveTeams.teamID#"> OR awayteamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveTeams.teamID#">)
								AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
								ORDER BY WEEK
								LIMIT 1	
							)
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#progressToSeasonId#">
			AND teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveTeams.teamID#">
		</cfquery>
	</cfloop>
	<cfset toastMsg = 'Successfully progressed to #getNewSeason.SeasonName# Season!'>
</cfoutput>