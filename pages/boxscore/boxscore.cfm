<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers
	FROM PlayerGameLog pgl
	JOIN Players p on p.playerID = pgl.playerID
	WHERE PlayerGameLogID IN (97, 98, 99)
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <label>Blazers vs Lakers - 11/17/2021</label>
        <table>
        	<thead>
        		<tr>
        			<th>Player</th>
	        		<th>FG</th>
	        		<th>3PT</th>
	        		<th>FT</th>
	        		<th>REB</th>
	        		<th>AST</th>
	        		<th>STL</th>
	        		<th>BLK</th>
	        		<th>TO</th>
	        		<th>PTS</th>
        		</tr>
        	</thead>
        	<tbody>
        		<cfloop query="getPlayerLogs">
        			<tr>
        				<td>#getPlayerLogs.firstName# #getPlayerLogs.LastName#</td>
        				<td>#getPlayerLogs.FGM# - #getPlayerLogs.FGA#</td>
        				<td>#getPlayerLogs.3FGM# - #getPlayerLogs.3FGA#</td>
        				<td>#getPlayerLogs.FTM# - #getPlayerLogs.FTA#</td>
        				<td>#getPlayerLogs.Rebounds#</td>
        				<td>#getPlayerLogs.Assists#</td>
        				<td>#getPlayerLogs.Steals#</td>
        				<td>#getPlayerLogs.Blocks#</td>
        				<td>#getPlayerLogs.Turnovers#</td>
        				<td>#getPlayerLogs.Points#</td>
        			</tr>
        		</cfloop>
        	</tbody>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

