Calculate Standings
<cfoutput>


<cfquery name = "getGamesInSelectedSeason" datasource="roundleague">
	SELECT homeTeamID, awayTeamID, HomeScore, AwayScore, seasonID
	FROM schedule
	WHERE seasonID in (3,4,5,6)
</cfquery>

<cfloop query="getGamesInSelectedSeason">
	<br>
	HomeTeamID = #HomeTeamID# <br>
	AwayTeamID = #AwayTeamID# <br>
	homeScore = #homeScore# <br>
	awayScore = #awayScore# <br>
	seasonID = #seasonID# <br>
	<cfif homeScore GT awayScore>
		#HomeTeamID# won the game
		<cfquery name="updateWin" datasource="roundleague">
			UPDATE standings
			SET Wins = Wins + 1
			Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HomeTeamID#">
			AND seasonID = #getGamesInSelectedSeason.seasonID#
		</cfquery>
		<cfquery name="updateLosses" datasource="roundleague">
			UPDATE standings
			SET Losses = Losses + 1
			Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AwayTeamID#">
			AND seasonID = #getGamesInSelectedSeason.seasonID#
		</cfquery>

	<cfelse>
		#AwayTeamID# won the game
		<cfquery name="updateWin" datasource="roundleague">
			UPDATE standings
			SET Wins = Wins + 1
			Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AwayTeamID#">
			AND seasonID = #getGamesInSelectedSeason.seasonID#
		</cfquery>
		<cfquery name="updateLosses" datasource="roundleague">
			UPDATE standings
			SET Losses = Losses + 1
			Where TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HomeTeamID#">
			AND seasonID = #getGamesInSelectedSeason.seasonID#
		</cfquery>
	</cfif>
	<br>


</cfloop>



</cfoutput>