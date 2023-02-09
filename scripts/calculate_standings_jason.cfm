<cfoutput>

Loop through each season and calculate standings <br>

<!--- This will be the real query --->
<!--- <cfquery name="getSeasons" datasource="roundleague">
    SELECT *
    FROM schedule
    WHERE seasonID IN (3,4,5,6)
</cfquery> --->

<!--- This is our small smaple size test query --->
<cfquery name="getGamesInSelectedSeasons" datasource="roundleague">
    SELECT homeTeamID, awayTeamID, HomeScore, AwayScore, SeasonID
    FROM schedule
    WHERE seasonID = 3
    AND divisionID = 4
    AND WEEK = 1
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
















