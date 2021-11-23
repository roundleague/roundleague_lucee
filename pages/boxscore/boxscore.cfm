<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../boxscore/boxscore.css" rel="stylesheet">

<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, t.teamName
	FROM PlayerGameLog pgl
	JOIN Players p on p.playerID = pgl.playerID
    JOIN Teams t on t.teamID = pgl.teamID
	WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
</cfquery>

<cfquery name="getTeamsPlaying" datasource="roundleague">
    SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, Date_FORMAT(s.date, "%M %d %Y") AS Date, s.homeScore, s.awayscore
    FROM schedule s
    LEFT JOIN teams as a ON s.hometeamID = a.teamID
    LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE s.scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    ORDER BY WEEK, startTime
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 25px;">
    <div class="section text-center">
      <div class="container">

        <h4 class="gameTitle">#getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# | #getTeamsPlaying.Away# #getTeamsPlaying.AwayScore#</h4>
        <h5>#getTeamsPlaying.Date#</h5>
        <table>
            <cfset currentTeamID = ''>
    		<cfloop query="getPlayerLogs">
                <cfif getPlayerlogs.teamID NEQ currentTeamID>
                    <thead>
                        <tr>
                            <td colspan="10">#GetPlayerLogs.teamName#</td>
                        </tr>
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
                </cfif>
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
                <cfset currentTeamID = getPlayerlogs.teamID>
        		</cfloop>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

