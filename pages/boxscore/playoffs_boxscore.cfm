<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../boxscore/boxscore.css" rel="stylesheet">

<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, t.teamName, pgl.Fouls, p.PermissionToShare, r.jersey
	FROM Playoffs_PlayerGameLog pgl
	JOIN Players p on p.playerID = pgl.playerID
    JOIN Teams t on t.teamID = pgl.teamID
    JOIN Roster r on r.playerID = p.playerID and r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    ORDER by t.teamName
</cfquery>

<cfquery name="getTeamsPlaying" datasource="roundleague">
    SELECT Playoffs_scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, Date_FORMAT(s.date, "%M %d, %Y") AS Date, s.homeScore, s.awayscore, a.teamID as HomeTeamID, b.teamID as AwayTeamID
    FROM Playoffs_schedule s
    LEFT JOIN teams as a ON s.hometeamID = a.teamID
    LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE s.Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    ORDER BY WEEK, startTime
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 25px;">
    <div class="section text-center">
      <div class="container">

        <h4 class="gameTitle"> 
            <a class="playerLink" href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.HomeTeamID#">
                #getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# 
            </a> | 
            <a class="playerLink" href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.AwayTeamID#">
                #getTeamsPlaying.Away# #getTeamsPlaying.AwayScore# 
            </a> 
        </h4>
        <h5>#getTeamsPlaying.Date#</h5>

        <table class="bolder smallFont">
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
                            <td colspan="12">#GetPlayerLogs.teamName#</td>
                        </tr>
                            <tr>
                                <th colspan="2">Player</th>
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
    				<td data-label="Player" colspan="2">
                        <cfif getPlayerlogs.PermissionToShare EQ 'Yes'>
                            <a class="playerLink" href="/pages/teams/Player_Profiles/player-profile-2.cfm?playerID=#playerID#">
                                #getPlayerLogs.firstName# #getPlayerLogs.LastName# ###getPlayerlogs.jersey#
                            </a>
                        <cfelse> 
                             #getPlayerLogs.firstName# #getPlayerLogs.LastName# ###getPlayerlogs.jersey#
                        </cfif>
                    </td>
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
                        <tr class="smallFont">
                            <td colspan="2" style="text-align: center; font-weight: bold;">TOTALS</td>
                            <td data-label="FG"><b>#TotalFGM# - #TotalFGA#</b></td> 
                            <td data-label="3FG"><b>#Total3FGM# - #Total3FGA#</b></td>
                            <td data-label="FT"><b>#TotalFTM# - #TotalFTA#</b></td>
                            <td data-label="REBS"><b>#TotalREB#</b></td>
                            <td data-label="ASTS"><b>#TotalAST#</b></td>
                            <td data-label="STLS"><b>#TotalSTL#</b></td>
                            <td data-label="BLKS"><b>#TotalBLK#</b></td>
                            <td data-label="TO"><b>#TotalTO#</b></td>
                            <td data-label="FLS"><b>#TotalFLS#</b></td>
                            <td data-label="PTS"><b>#TotalPTS#</b></td>
                        </tr>
                </cfif>
        	</cfloop>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

