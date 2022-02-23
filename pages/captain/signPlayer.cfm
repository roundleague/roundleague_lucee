<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">

<cfquery name="getPlayerStats" datasource="roundleague">
	SELECT firstName, lastName, FGM, FGA, 3FGM, 3FGA, points, rebounds, assists, steals, blocks, turnovers, gamesplayed, r.jersey,t.teamName, height, p.playerID
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
	JOIN roster r on r.playerID = p.playerID AND r.SeasonID = ps.seasonID
	JOIN teams t on r.teamID = t.teamID
	WHERE ps.seasonID = (SELECT s.seasonID From Seasons s Where s.Status = 'Active')
	ORDER BY points desc
</cfquery>

<cfif isDefined("form.signPlayerID")>
	<cfinclude template="signPlayer_confirm.cfm">
	<cfexit>
</cfif>

<cfoutput>
<div class="main" style="background-color: white; padding-top: 50px">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <form method="POST" class="signPlayerForm">
			<table id="signPlayerTable" class="display bolder" style="width:100%">
			        <thead>
			            <tr>
			                <th>Name</th>
			                <th>Team</th>
			                <th>Height</th>
			                <th>FGM</th>
			                <th>3FGM</th>
			                <!--- <th>FG%</th> --->
			                <th>PTS</th>
			                <th>REBS</th>
			                <th>ASTS</th>
			                <th>STLS</th>
			                <th>BLKS</th>
			                <th>TO</th>
			                <th>Sign</th>
			            </tr>
			        </thead>
			        <tbody>
			        	<cfloop query="getPlayerStats">
			        		<tr>
				        		<td data-label="Name">#getPlayerStats.firstName# #getPlayerStats.lastName# ###jersey#</td>
				        		<td data-label="Team">#getPlayerStats.teamname#</td>
				        		<td data-label="Height">#getPlayerStats.Height#</td>
				        		<td data-label="FGM">#getPlayerStats.FGM#</td>
				        		<td data-label="3FGM">#getPlayerStats.3FGM#</td>
				        		<!--- <td data-label="FG%">
				        			<cftry>#NumberFormat(evaluate(getPlayerStats.FGM / getPlayerStats.FGA * 100), '__.0')#%
				        				<cfcatch>0%</cfcatch>
				        			</cftry>
				        		</td> --->
				        		<td data-label="Points">#getPlayerStats.Points#</td>
				        		<td data-label="Rebounds">#getPlayerStats.Rebounds#</td>
				        		<td data-label="Assists">#getPlayerStats.Assists#</td>
				        		<td data-label="Steals">#getPlayerStats.Steals#</td>
				        		<td data-label="Blocks">#getPlayerStats.Blocks#</td>
				        		<td data-label="TO">#getPlayerStats.Turnovers#</td>
				        		<td data-label="Sign">
			            		<button type="submit" class="btn btn-outline-success btn-round removeBtn" name="signPlayerID"value="#playerID#">Sign</button>
				        		</td>
			        		</tr>
			        	</cfloop>
			        </tbody>
			</table>
		</form>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/pages/captain/signPlayer.js"></script>

