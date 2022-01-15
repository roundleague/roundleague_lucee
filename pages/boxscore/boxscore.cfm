<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../boxscore/boxscore.css" rel="stylesheet">

<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, t.teamName, pgl.Fouls
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

            <!--- Keep Track of Totals --->
            <cfset totalFGM = 0>
            <cfset totalFGA = 0>
            <cfset total3FGM = 0>
            <cfset total3FGA = 0>
            <cfset totalFTM = 0>
            <cfset totalFTA = 0>
            <cfset totalREB = 0>
            <cfset totalAST = 0>
            <cfset totalSTL = 0>
            <cfset totalBLK = 0>
            <cfset totalTO = 0>
            <cfset totalFLS = 0>
            <cfset totalPTS = 0>

    		<cfloop query="getPlayerLogs">

                <cfif getPlayerlogs.teamID NEQ currentTeamID>
                    <cfset totalFGM = 0>
                    <cfset totalFGA = 0>
                    <cfset total3FGM = 0>
                    <cfset total3FGA = 0>
                    <cfset totalFTM = 0>
                    <cfset totalFTA = 0>
                    <cfset totalREB = 0>
                    <cfset totalAST = 0>
                    <cfset totalSTL = 0>
                    <cfset totalBLK = 0>
                    <cfset totalTO = 0>
                    <cfset totalFLS = 0>
                    <cfset totalPTS = 0>
                    <thead>
                        <tr>
                            <td colspan="11">#GetPlayerLogs.teamName#</td>
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
                                <th>FLS</th>
                                <th>PTS</th>
                            </tr>
                    </thead>
                </cfif>

                <cfset totalFGM += getPlayerLogs.FGM>
                <cfset totalFGA += getPlayerLogs.FGA>
                <cfset total3FGM += getPlayerLogs.3FGM>
                <cfset total3FGA += getPlayerLogs.3FGA>
                <cfset totalFTM += getPlayerLogs.FTM>
                <cfset totalFTA += getPlayerLogs.FTA>
                <cfset totalREB += getPlayerLogs.Rebounds>
                <cfset totalAST += getPlayerLogs.Assists>
                <cfset totalSTL += getPlayerLogs.Steals>
                <cfset totalBLK += getPlayerLogs.Blocks>
                <cfset totalTO += getPlayerLogs.Turnovers>
                <cfset totalFLS += val(getPlayerLogs.Fouls)>
                <cfset totalPTS += getPlayerLogs.Points>

    			<tr>
    				<td data-label="Player">#getPlayerLogs.firstName# #getPlayerLogs.LastName#</td>
    				<td data-label="FG">#getPlayerLogs.FGM# - #getPlayerLogs.FGA#</td>
    				<td data-label="3FG">#getPlayerLogs.3FGM# - #getPlayerLogs.3FGA#</td>
    				<td data-label="FT">#getPlayerLogs.FTM# - #getPlayerLogs.FTA#</td>
    				<td data-label="REBS">#getPlayerLogs.Rebounds#</td>
    				<td data-label="ASTS">#getPlayerLogs.Assists#</td>
    				<td data-label="STLS">#getPlayerLogs.Steals#</td>
    				<td data-label="BLKS">#getPlayerLogs.Blocks#</td>
    				<td data-label="TO">#getPlayerLogs.Turnovers#</td>
                    <td data-label="FLS">#val(getPlayerLogs.Fouls)#</td>
    				<td data-label="PTS">#getPlayerLogs.Points#</td>
    			</tr>
                <cfset currentTeamID = getPlayerlogs.teamID>

                <cfif getPlayerlogs.recordCount NEQ getPlayerLogs.currentRow>
                    <cfset nextRecord = QueryGetRow(getPlayerLogs, getPlayerLogs.currentRow+1)>
                    <cfset nextTeamId = nextRecord.teamID>
                </cfif>

                <!--- Total Scores --->
                <cfif getPlayerlogs.recordCount EQ getPlayerLogs.currentRow OR currentTeamID NEQ nextTeamID>
                        <tr>
                            <th>Totals</th>
                            <th>#TotalFGM# - #TotalFGA#</th>
                            <th>#Total3FGM# - #Total3FGA#</th> 
                            <th>#TotalFTM# - #TotalFTA#</th>
                            <th>#TotalREB#</th>
                            <th>#TotalAST#</th>
                            <th>#TotalSTL#</th>
                            <th>#TotalBLK#</th>
                            <th>#TotalTO#</th>
                            <th>#TotalFLS#</th>
                            <th>#TotalPTS#</th>
                        </tr>
                </cfif>
        	</cfloop>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

