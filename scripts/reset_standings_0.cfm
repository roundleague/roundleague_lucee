<cfoutput>

Script for Resetting Standings to 0


<style>
.testClass, td{
  border: 1px solid;
  color: black;
}
</style>

<cfquery name="updateStandingsOutsideTheLoop" datasource="roundleague">
    UPDATE standings
    SET Wins = 0, Losses = 0
    WHERE seasonID < 7
</cfquery>

<cfquery name="resetStandings" datasource="roundleague">
	SELECT TeamID, Wins, Losses
	FROM standings
	WHERE seasonID < 7
</cfquery>

<cfloop query="resetStandings">
    <br>
    TeamID = #TeamID# <br>
    Wins = #Wins# <br>
    Losses = #Losses# <br>
    <br>
</cfloop>

<table>
   	<thead>
       <tr>
        <td>TeamID</td>
        <td>Wins</td>
        <td>Losses</td>
       </tr>
    </thead>
    <tbody>
		<cfloop query="resetStandings">
			<tr>
				<br>
                    <td data-label="Team">#resetStandings.TeamID#</td>
                    <td data-label="Wins">#val(resetStandings.Wins)#</td>
                    <td data-label="Losses">#val(resetStandings.Losses)#</td>
				<br>
			</tr>
		</cfloop>
	</tbody>
</table>


</cfoutput>

