<cfoutput>

Loop through each season and calculate standings <br>

<cfquery name="getGamesInSelectedSeasons" datasource="roundleague">
    SELECT homeTeamID, awayTeamID, HomeScore, AwayScore, SeasonID
    FROM schedule
    WHERE seasonID in (3,4,5,6)
</cfquery>

<cfloop query="getGamesInSelectedSeasons">
	HomeTeamID: #HomeTeamID#, HomeScore: #HomeScore# <br>
	AwayteamID: #AwayTeamID#, AwayScore: #AwayScore# <br>
	<cfif HomeScore GT AwayScore>
		#HomeTeamID# won the game
		<cfquery name="updateWin" datasource="roundleague">
			UPDATE standings
			SET Wins = Wins + 1
			WHERE TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HomeTeamID#">
			AND seasonID = #getGamesInSelectedSeasons.seasonID#
		</cfquery>

		<cfquery name="updateLost" datasource="roundleague">
			UPDATE standings
			SET Losses = Losses + 1
			WHERE TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AwayTeamID#">
			AND seasonID = #getGamesInSelectedSeasons.seasonID# 
		</cfquery>

	<cfelse>
		#AwayTeamID# won the game
		<cfquery name="updateWin" datasource="roundleague">
			UPDATE standings
			SET Wins = Wins + 1
			WHERE TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AwayTeamID#">
			AND seasonID = #getGamesInSelectedSeasons.seasonID#
		</cfquery>

		<cfquery name="updateLost" datasource="roundleague">
			UPDATE standings
			SET Losses = Losses + 1
			WHERE TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HomeTeamID#">
			AND seasonID = #getGamesInSelectedSeasons.seasonID# 
		</cfquery>


	</cfif>

</cfloop>


</cfoutput>
















