<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../boxscore/boxscore.css?v=1.4" rel="stylesheet">

<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT DISTINCT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, t.teamName, pgl.Fouls, r.jersey, p.PermissionToShare
	FROM PlayerGameLog pgl
	JOIN Players p on p.playerID = pgl.playerID
    JOIN Teams t on t.teamID = pgl.teamID
    JOIN Roster r on r.playerID = p.playerID and r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    ORDER by t.teamName
</cfquery>

<cfquery name="getTeamsPlaying" datasource="roundleague">
    SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, Date_FORMAT(s.date, "%M %d, %Y") AS Date, s.homeScore, s.awayscore, a.teamID as HomeTeamID, b.teamID as AwayTeamID
    FROM schedule s
    LEFT JOIN teams as a ON s.hometeamID = a.teamID
    LEFT JOIN teams as b ON s.awayTeamID = b.teamID
    WHERE s.scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    ORDER BY WEEK, startTime
</cfquery>

<cfquery name="getWinsAndLossesHomeTeam" datasource="roundleague">
    SELECT Wins,Losses
    FROM standings
    WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.HomeTeamID#">
    AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.CurrentSeasonID#">
</cfquery>

<cfquery name="getWinsAndLossesAwayTeam" datasource="roundleague">
    SELECT Wins,Losses
    FROM standings
    WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.AwayTeamID# ">
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 25px;">
    <div class="section text-center">
      <div class="container">

        <h4 class="gameTitle desktop"> #getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# (#getWinsAndLossesHomeTeam.Wins#-#getWinsAndLossesHomeTeam.Losses#) | #getTeamsPlaying.Away# #getTeamsPlaying.AwayScore# (#getWinsAndLossesAwayTeam.Wins#-#getWinsAndLossesAwayTeam.Losses#)</h4>
        <h5>#getTeamsPlaying.Date#</h5>

        <!--- Mobile score section --->
        <div class="finalScoreSection mobile">
            <!--- First Div Section is Home Team Info --->
            <div class="teamInfoContainer">
                <div class="teamInfo">
                  <div class="teamInfo_teamName"><b>#getTeamsPlaying.Home#</b></div>
                  <div class="teamInfo_record">#getWinsAndLossesHomeTeam.Wins#-#getWinsAndLossesHomeTeam.Losses#</div>
                </div>
                <!--- <div class="homeTeamScore #bolderScore#">#getTeamsPlaying.HomeScore#</div> --->
            </div>

            <!--- Second will be 'FINAL' --->
            <div class="scoresContainer">
                <cfset homeBolderScore = (getTeamsPlaying.HomeScore GT getTeamsPlaying.AwayScore) ? 'homeBolderScore' : ''>
                <div class="homeTeamContainer #homeBolderScore#">#getTeamsPlaying.HomeScore#</div>
                <div class="finalTextDiv">FINAL</div>
                <cfset awayBolderScore = (getTeamsPlaying.AwayScore GT getTeamsPlaying.HomeScore) ? 'awayBolderScore' : ''>
                <div class="awayTeamContainer #awayBolderScore#">#getTeamsPlaying.AwayScore#</div>
            </div>

            <!--- Third will be Away Team Info --->
            <cfset bolderScore = (getTeamsPlaying.AwayScore GT getTeamsPlaying.HomeScore) ? 'bolderScore' : ''>
            <div class="teamInfoContainer">
                <!--- <div class="awayTeamScore #bolderScore#">#getTeamsPlaying.AwayScore#</div> --->
                <div class="teamInfo">
                  <div class="teamInfo_teamName"><b>#getTeamsPlaying.Away#</b></div>
                  <div class="teamInfo_record">#getWinsAndLossesAwayTeam.Wins#-#getWinsAndLossesAwayTeam.Losses#</div>
                </div>
            </div>
        </div>

        <!--- Player of the game should span the whole width of phone and desktop --->
        <!--- <div class="playerOfTheGame">
            <table class="mobile">
                <thead>
                    <tr>
                        <th>Player of the Game</th>
                        <th>Points</th>
                        <th>Rebounds</th>
                        <th>Assists</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td data-label="Name">Tim Huynh</td>
                        <td data-label="Points">25</td>
                        <td data-label="Rebounds">12</td>
                        <td data-label="Assists">6</td>
                    </tr>
                </tbody>
            </table>
        </div> --->

        <div class="rotateTip">Rotate your device to see the full box score</div>

        <!--- End Test --->

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
                        <a class="playerLink" href="/pages/teams/Player_Profiles/player-profile-2.cfm?playerID=#playerID#">#getPlayerLogs.firstName# #getPlayerLogs.LastName# ###getPlayerlogs.jersey#</a>
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
                            <th colspan="2">Totals</th>
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

