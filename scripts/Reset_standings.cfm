Script for Resetting Standings to 

<cfoutput>

<cfquery name="resetStandings" datasource="roundleague">
	UPDATE standings
	Set Wins = 0 , Losses = 0
	Where seasonId in (3,4,5,6)
</cfquery>

<cfquery name = "displayStandings" datasource="roundleague">
	SELECT TeamID, Wins, Losses
	from standings
	WHERE seasonID in (3,4,5,6)
</cfquery>


<cfloop query="displayStandings">
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
    <cfloop query="displayStandings">
                    <tr>
                        <td data-label="TeamID">#val(displayStandings.TeamID)#</td>
                        <td data-label="Wins">#val(displayStandings.Wins)#</td>
                        <td data-label="Losses">#val(displayStandings.Losses)#</td>
                        
                    </tr>
                </cfloop>
	          </tbody>
</table>
<style>
.testClass, td{
  border: 1px solid;
  color: black;
}
</style>

</cfoutput>