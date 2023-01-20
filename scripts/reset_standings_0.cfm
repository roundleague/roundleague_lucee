<cfoutput>

Script for Resetting Standings to 0

<cfquery name="resetStandings" datasource="roundleague">
	SELECT TeamID, Wins, Losses
	FROM standings
	WHERE seasonID < 7
	AND seasonID = 1 /* Making it smaller sample size, remove later */
</cfquery>

<cfloop query="resetStandings">
	<br>
	TeamID = #TeamID# <br>
	Wins = #Wins# <br> 
	Losses = #Losses# <br>
	<br>
</cfloop>

</cfoutput>