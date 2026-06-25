<cfinclude template="/header.cfm">

<!--- LOCAL ONLY: Reset game data for re-testing --->
<cfif (CGI.HTTP_HOST CONTAINS "localhost" OR CGI.HTTP_HOST CONTAINS "127.0.0.1") AND isDefined("form.resetGame") AND isDefined("url.scheduleID")>
    <cfquery datasource="roundleague">
        DELETE FROM PlayerGameLog WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>
    <cfquery datasource="roundleague">
        DELETE FROM recaps WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>
    <cfquery datasource="roundleague">
        DELETE FROM game_subs WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>
    <cfquery datasource="roundleague">
        DELETE FROM game_plays WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>
    <cfquery datasource="roundleague">
        UPDATE schedule
        SET homeScore = NULL, awayScore = NULL, status = 'scheduled'
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>
    <cflocation url="boxscore.cfm?scheduleID=#url.scheduleID#" addtoken="false">
</cfif>

<!--- Page Specific CSS/JS Here --->
<cfset _v = getFileInfo(expandPath("/pages/boxscore/boxscore.css")).lastModified.getTime()>
<link href="/pages/boxscore/boxscore.css?v=<cfoutput>#_v#</cfoutput>" rel="stylesheet">
<!--- POG-style fonts for player stats modal --->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Oswald:wght@400;500;600;700&family=Barlow+Condensed:wght@600;700&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">

<cfquery name="getPlayerLogs" datasource="roundleague">
	SELECT DISTINCT pgl.PlayerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, pgl.teamID, t.teamName, pgl.Fouls, r.jersey, p.PermissionToShare, pgl.plusMinus
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

<cfquery name="getPlayByPlay" datasource="roundleague">
    SELECT gp.playID, gp.stat_type, gp.points_scored,
           gp.home_score, gp.away_score, gp.period,
           p.firstName, p.lastName, t.teamName
    FROM game_plays gp
    JOIN Players p ON p.playerID = gp.playerID
    JOIN Teams t   ON t.teamID   = gp.teamID
    WHERE gp.scheduleID   = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
      AND gp.points_scored > 0
      AND gp.is_removed    = 0
    ORDER BY gp.playID DESC
</cfquery>

<cfset boxscore = createObject("component", "boxscore")>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 25px;">
    <div class="section text-center">
      <div class="container">

        <h4 class="gameTitle desktop"> <a class="playerLink" href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.HomeTeamID#"> #getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# </a>(#getWinsAndLossesHomeTeam.Wins#-#getWinsAndLossesHomeTeam.Losses#) | <a class="playerLink" href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.AwayTeamID#"> #getTeamsPlaying.Away# #getTeamsPlaying.AwayScore# </a> (#getWinsAndLossesAwayTeam.Wins#-#getWinsAndLossesAwayTeam.Losses#)</h4>
        <h5>#getTeamsPlaying.Date#</h5> 
        <cfset teamScores = '#getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# | ' & '#getTeamsPlaying.Away# #getTeamsPlaying.AwayScore#' />


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

        <cfset defaultTab = (getPlayerLogs.recordCount EQ 0) ? "playbyplay" : "boxscore">

        <ul class="nav nav-tabs" id="gameTab">
            <li class="<cfif defaultTab EQ 'boxscore'>active</cfif>"><a href="##boxscore-tab">Box Score</a></li>
            <li class="<cfif defaultTab EQ 'playbyplay'>active</cfif>"><a href="##playbyplay-tab">Play-By-Play</a></li>
        </ul>

        <div class="tab-content">

        <!--- Box Score Tab --->
        <div class="tab-pane <cfif defaultTab EQ 'boxscore'>active</cfif>" id="boxscore-tab">
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

            <cfset playerListPrompts = ''>
    		<cfloop query="getPlayerLogs">

                <cfset playerPrompt = boxscore.generatePlayerStatsPrompt(getPlayerLogs, getPlayerlogs.teamID)>
                <cfset playerListPrompts = playerPrompt & playerListPrompts>

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
                            <td colspan="13">#GetPlayerLogs.teamName#</td>
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
                                <th>+/-</th>
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
                        <cfif listFind("536,1001", getPlayerLogs.playerID)>
                        <i class="fa-solid fa-chart-bar mobileStatsIcon"
                           onclick="openPlayerStatsModal('#JSStringFormat(getPlayerLogs.firstName)#', '#JSStringFormat(getPlayerLogs.lastName)#', '###getPlayerlogs.jersey#', '#JSStringFormat(GetPlayerLogs.teamName)#', '#getPlayerLogs.FGM#', '#getPlayerLogs.FGA#', '#getPlayerLogs.3FGM#', '#getPlayerLogs.3FGA#', '#getPlayerLogs.FTM#', '#getPlayerLogs.FTA#', '#getPlayerLogs.Points#', '#getPlayerLogs.Rebounds#', '#getPlayerLogs.Assists#', '#getPlayerLogs.Steals#', '#getPlayerLogs.Blocks#', '#getPlayerLogs.Turnovers#', '#val(getPlayerLogs.Fouls)#', '#getPlayerLogs.playerID#')"></i>
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
                    <td data-label="+/-"><cfif NOT isNull(getPlayerLogs.plusMinus) AND getPlayerLogs.plusMinus NEQ ""><cfif getPlayerLogs.plusMinus GT 0><span style="color:##2e7d32;font-weight:bold">+#getPlayerLogs.plusMinus#</span><cfelseif getPlayerLogs.plusMinus LT 0><span style="color:##c62828;font-weight:bold">#getPlayerLogs.plusMinus#</span><cfelse>0</cfif><cfelse>&mdash;</cfif></td>
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
                        <td data-label="+/-">&mdash;</td>
                        <td data-label="PTS"><b>#TotalPTS#</b></td>
                    </tr>
                    <cfif currentTeamID NEQ nextTeamID>
                        <cfset firstTeamStruct = {
                            "TotalFGM": TotalFGM,
                            "TotalFGA": TotalFGA,
                            "Total3FGM": Total3FGM,
                            "Total3FGA": Total3FGA,
                            "TotalFTM": TotalFTM,
                            "TotalFTA": TotalFTA,
                            "TotalREB": TotalREB,
                            "TotalAST": TotalAST,
                            "TotalSTL": TotalSTL,
                            "TotalBLK": TotalBLK,
                            "TotalTO": TotalTO,
                            "TotalFLS": TotalFLS,
                            "TotalPTS": TotalPTS
                        }>
                        <cfset firstTeamTotals = boxscore.generateTeamStatsPrompt(GetPlayerLogs.teamName, firstTeamStruct)>
                    </cfif>
                    <cfif getPlayerlogs.recordCount EQ getPlayerLogs.currentRow>
                        <cfset secondTeamStruct = {
                            "TotalFGM": TotalFGM,
                            "TotalFGA": TotalFGA,
                            "Total3FGM": Total3FGM,
                            "Total3FGA": Total3FGA,
                            "TotalFTM": TotalFTM,
                            "TotalFTA": TotalFTA,
                            "TotalREB": TotalREB,
                            "TotalAST": TotalAST,
                            "TotalSTL": TotalSTL,
                            "TotalBLK": TotalBLK,
                            "TotalTO": TotalTO,
                            "TotalFLS": TotalFLS,
                            "TotalPTS": TotalPTS
                        }>
                        <cfset secondTeamTotals = boxscore.generateTeamStatsPrompt(GetPlayerLogs.teamName, secondTeamStruct)>
                    </cfif>
                </cfif>
        	</cfloop>
        </table>
        </div><!--- end #boxscore-tab --->

        <!--- Play-By-Play Tab --->
        <div class="tab-pane <cfif defaultTab EQ 'playbyplay'>active</cfif>" id="playbyplay-tab">
            <cfif getPlayByPlay.recordCount EQ 0>
                <p style="color:##888;text-align:center;padding:40px 0;font-size:14px;">No scoring plays recorded yet.</p>
            <cfelse>
                <table class="pbp-table">
                    <thead>
                        <tr>
                            <th>PER</th>
                            <th>TEAM</th>
                            <th>PLAYER</th>
                            <th>PLAY</th>
                            <th style="text-align:right;">SCORE</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="getPlayByPlay">
                            <cfif stat_type EQ "FGM">
                                <cfset badgeClass = "pbp-badge-2pt">
                                <cfset badgeText = "2PT">
                            <cfelseif stat_type EQ "3FGM">
                                <cfset badgeClass = "pbp-badge-3pt">
                                <cfset badgeText = "3PT">
                            <cfelseif stat_type EQ "FTM">
                                <cfset badgeClass = "pbp-badge-ft">
                                <cfset badgeText = "FT">
                            <cfelse>
                                <cfset badgeClass = "">
                                <cfset badgeText = stat_type>
                            </cfif>
                            <tr>
                                <td class="pbp-period">H#period#</td>
                                <td class="pbp-team">#teamName#</td>
                                <td class="pbp-player">#firstName# #lastName#</td>
                                <td><span class="pbp-badge #badgeClass#">#badgeText#</span></td>
                                <td class="pbp-score">#home_score# &ndash; #away_score#</td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
                <p class="pbp-legend">#getTeamsPlaying.Home# (home) &bull; #getTeamsPlaying.Away# (away)</p>
            </cfif>
        </div><!--- end ##playbyplay-tab --->

        </div><!--- end .tab-content --->
        <br>
        <cfinclude template="recap.cfm">

        <cfif CGI.HTTP_HOST CONTAINS "localhost" OR CGI.HTTP_HOST CONTAINS "127.0.0.1">
        <div style="margin:24px auto;max-width:500px;padding:16px;background:##fff3cd;border:1px solid ##ffc107;border-radius:6px;text-align:center;">
            <form method="POST" action="boxscore.cfm?scheduleID=#url.scheduleID#" onsubmit="return confirm('Reset all data for scheduleID #url.scheduleID#? This deletes PlayerGameLog, recaps, game_subs and sets status back to scheduled.')">
                <input type="hidden" name="resetGame" value="1">
                <button type="submit" style="background:##dc3545;color:white;border:none;padding:8px 20px;border-radius:4px;font-weight:bold;cursor:pointer;font-size:14px;">&##x26A0; Reset Game Data</button>
                <div style="font-size:11px;color:##856404;margin-top:6px;">Deletes PlayerGameLog &bull; recaps &bull; game_subs &bull; Resets score + status &mdash; LOCAL ONLY</div>
            </form>
        </div>
        </cfif>

      </div>
    </div>
</div>

</cfoutput>

<!--- Player Stats Modal (Mobile) --->
<div class="modal fade" id="playerStatsModal" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content" style="background: #0d0d0d; border: none; border-radius: 12px; overflow: hidden;">
      <div class="pogModal-topBar"></div>
      <div class="modal-body" style="padding: 0;">
        <button type="button" class="close pogModal-closeBtn" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <div id="pogModalCapture">
        <div class="pogModal-topBarInner"></div>
        <div class="pogModal-photoSection">
          <img id="modalPlayerPhoto" class="pogModal-playerPhoto" src="/assets/img/PlayerProfiles/default.JPG" alt="Player Photo">
          <div class="pogModal-photoOverlay"></div>
        </div>
        <div class="pogModal-header">
          <img class="pogModal-logo" src="/assets/img/Logos/4_trimmed.png" alt="Round League">
          <span class="pogModal-badge">PLAYER STATS</span>
        </div>
        <div class="pogModal-nameSection">
          <div class="pogModal-firstName" id="modalFirstName"></div>
          <div class="pogModal-lastName" id="modalLastName"></div>
          <div class="pogModal-teamName" id="modalTeamName"></div>
        </div>
        <div class="pogModal-primaryStats">
          <div class="pogModal-statItem">
            <div class="pogModal-statValue" id="modalPTS"></div>
            <div class="pogModal-statLabel">PTS</div>
          </div>
          <div class="pogModal-statDivider"></div>
          <div class="pogModal-statItem">
            <div class="pogModal-statValue" id="modalREB"></div>
            <div class="pogModal-statLabel">REB</div>
          </div>
          <div class="pogModal-statDivider"></div>
          <div class="pogModal-statItem">
            <div class="pogModal-statValue" id="modalAST"></div>
            <div class="pogModal-statLabel">AST</div>
          </div>
        </div>
        <div class="pogModal-secondaryStats">
          <div class="pogModal-secStatRow">
            <div class="pogModal-secStat"><span class="pogModal-secLabel">FG</span><span class="pogModal-secValue" id="modalFG"></span></div>
            <div class="pogModal-secStat"><span class="pogModal-secLabel">3PT</span><span class="pogModal-secValue" id="modal3PT"></span></div>
            <div class="pogModal-secStat"><span class="pogModal-secLabel">FT</span><span class="pogModal-secValue" id="modalFT"></span></div>
          </div>
          <div class="pogModal-secStatRow">
            <div class="pogModal-secStat"><span class="pogModal-secLabel">STL</span><span class="pogModal-secValue" id="modalSTL"></span></div>
            <div class="pogModal-secStat"><span class="pogModal-secLabel">BLK</span><span class="pogModal-secValue" id="modalBLK"></span></div>
            <div class="pogModal-secStat"><span class="pogModal-secLabel">TO</span><span class="pogModal-secValue" id="modalTO"></span></div>
          </div>
          <div class="pogModal-secStatRow">
            <div class="pogModal-secStat"><span class="pogModal-secLabel">FLS</span><span class="pogModal-secValue" id="modalFLS"></span></div>
          </div>
        </div>
        <div class="pogModal-bottomBar"></div>
        </div><!--- end pogModalCapture --->
        <div class="pogModal-downloadHint"><i class="fa-solid fa-hand-pointer"></i> Hold to save image</div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="../boxscore/playerStatsModal.js?v=1.0"></script>

<script>
(function() {
    var navLinks = document.querySelectorAll('#gameTab a');
    var panes    = document.querySelectorAll('.tab-content .tab-pane');
    navLinks.forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            var targetId = this.getAttribute('href').replace('#', '');
            navLinks.forEach(function(l) { l.parentElement.classList.remove('active'); });
            this.parentElement.classList.add('active');
            panes.forEach(function(p) { p.classList.remove('active'); });
            document.getElementById(targetId).classList.add('active');
        });
    });
})();
</script>
<cfinclude template="/footer.cfm">
<script src="../boxscore/recap.js?v=1.1"></script>
