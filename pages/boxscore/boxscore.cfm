<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../boxscore/boxscore.css?v=2.0" rel="stylesheet">

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

<cfset boxscore = createObject("component", "boxscore")>

<!--- Compute top performers per team --->
<cfset homeTopPts = {name="", val=0}>
<cfset homeTopReb = {name="", val=0}>
<cfset homeTopAst = {name="", val=0}>
<cfset awayTopPts = {name="", val=0}>
<cfset awayTopReb = {name="", val=0}>
<cfset awayTopAst = {name="", val=0}>
<cfloop query="getPlayerLogs">
    <cfset pName = getPlayerLogs.firstName & " " & getPlayerLogs.lastName>
    <cfif getPlayerLogs.teamID EQ getTeamsPlaying.HomeTeamID>
        <cfif getPlayerLogs.Points GT homeTopPts.val><cfset homeTopPts = {name=pName, val=getPlayerLogs.Points}></cfif>
        <cfif getPlayerLogs.Rebounds GT homeTopReb.val><cfset homeTopReb = {name=pName, val=getPlayerLogs.Rebounds}></cfif>
        <cfif getPlayerLogs.Assists GT homeTopAst.val><cfset homeTopAst = {name=pName, val=getPlayerLogs.Assists}></cfif>
    <cfelse>
        <cfif getPlayerLogs.Points GT awayTopPts.val><cfset awayTopPts = {name=pName, val=getPlayerLogs.Points}></cfif>
        <cfif getPlayerLogs.Rebounds GT awayTopReb.val><cfset awayTopReb = {name=pName, val=getPlayerLogs.Rebounds}></cfif>
        <cfif getPlayerLogs.Assists GT awayTopAst.val><cfset awayTopAst = {name=pName, val=getPlayerLogs.Assists}></cfif>
    </cfif>
</cfloop>

<cfoutput>
<div class="main" style="margin-top: 70px;">
  <div class="bs-page">
    <div class="container">

      <!--- ===== SCOREBOARD HEADER ===== --->
      <div class="scoreboard">
        <div class="scoreboard-status">FINAL</div>
        <div class="scoreboard-body">
          <div class="scoreboard-team">
            <a href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.HomeTeamID#" class="scoreboard-team-link">
              <span class="scoreboard-team-name">#getTeamsPlaying.Home#</span>
              <span class="scoreboard-team-record">(#getWinsAndLossesHomeTeam.Wins#-#getWinsAndLossesHomeTeam.Losses#)</span>
            </a>
          </div>
          <div class="scoreboard-scores">
            <cfset homeWon = getTeamsPlaying.HomeScore GT getTeamsPlaying.AwayScore>
            <span class="scoreboard-score #homeWon ? 'score-winner' : ''#">#getTeamsPlaying.HomeScore#</span>
            <span class="scoreboard-divider">&ndash;</span>
            <span class="scoreboard-score #NOT homeWon ? 'score-winner' : ''#">#getTeamsPlaying.AwayScore#</span>
          </div>
          <div class="scoreboard-team">
            <a href="/pages/teams/team-profile-page.cfm?teamID=#getTeamsPlaying.AwayTeamID#" class="scoreboard-team-link">
              <span class="scoreboard-team-name">#getTeamsPlaying.Away#</span>
              <span class="scoreboard-team-record">(#getWinsAndLossesAwayTeam.Wins#-#getWinsAndLossesAwayTeam.Losses#)</span>
            </a>
          </div>
        </div>
        <div class="scoreboard-date">#getTeamsPlaying.Date#</div>
      </div>

      <!--- ===== TEAM CARDS WITH STATS ===== --->
      <cfset teamScores = '#getTeamsPlaying.Home# #getTeamsPlaying.HomeScore# | ' & '#getTeamsPlaying.Away# #getTeamsPlaying.AwayScore#' />
      <cfset currentTeamID = ''>
      <cfset totalFGM = 0><cfset totalFGA = 0>
      <cfset total3FGM = 0><cfset total3FGA = 0>
      <cfset totalFTM = 0><cfset totalFTA = 0>
      <cfset totalREB = 0><cfset totalAST = 0>
      <cfset totalSTL = 0><cfset totalBLK = 0>
      <cfset totalTO = 0><cfset totalFLS = 0>
      <cfset totalPTS = 0>
      <cfset playerListPrompts = ''>
      <cfset isFirstTeam = true>

      <cfloop query="getPlayerLogs">

        <cfset playerPrompt = boxscore.generatePlayerStatsPrompt(getPlayerLogs, getPlayerlogs.teamID)>
        <cfset playerListPrompts = playerPrompt & playerListPrompts>

        <cfif getPlayerlogs.teamID NEQ currentTeamID>
          <!--- Close previous card if not first team --->
          <cfif NOT isFirstTeam>
                    <tr class="totals-row">
                      <td>TOTALS</td>
                      <td>#TotalFGM# - #TotalFGA#</td>
                      <td>#Total3FGM# - #Total3FGA#</td>
                      <td>#TotalFTM# - #TotalFTA#</td>
                      <td class="col-highlight">#TotalREB#</td>
                      <td class="col-highlight">#TotalAST#</td>
                      <td>#TotalSTL#</td>
                      <td>#TotalBLK#</td>
                      <td>#TotalTO#</td>
                      <td>#TotalFLS#</td>
                      <td class="col-pts">#TotalPTS#</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <cfset firstTeamStruct = {
              "TotalFGM": TotalFGM, "TotalFGA": TotalFGA,
              "Total3FGM": Total3FGM, "Total3FGA": Total3FGA,
              "TotalFTM": TotalFTM, "TotalFTA": TotalFTA,
              "TotalREB": TotalREB, "TotalAST": TotalAST,
              "TotalSTL": TotalSTL, "TotalBLK": TotalBLK,
              "TotalTO": TotalTO, "TotalFLS": TotalFLS,
              "TotalPTS": TotalPTS
            }>
            <cfset firstTeamTotals = boxscore.generateTeamStatsPrompt(prevTeamName, firstTeamStruct)>
          </cfif>

          <!--- Reset totals --->
          <cfset totalFGM = 0><cfset totalFGA = 0>
          <cfset total3FGM = 0><cfset total3FGA = 0>
          <cfset totalFTM = 0><cfset totalFTA = 0>
          <cfset totalREB = 0><cfset totalAST = 0>
          <cfset totalSTL = 0><cfset totalBLK = 0>
          <cfset totalTO = 0><cfset totalFLS = 0>
          <cfset totalPTS = 0>

          <!--- Determine top performers for this team --->
          <cfif getPlayerLogs.teamID EQ getTeamsPlaying.HomeTeamID>
            <cfset topPts = homeTopPts><cfset topReb = homeTopReb><cfset topAst = homeTopAst>
          <cfelse>
            <cfset topPts = awayTopPts><cfset topReb = awayTopReb><cfset topAst = awayTopAst>
          </cfif>

          <!--- Open new team card --->
          <div class="team-card">
            <div class="team-card-header">
              <h3 class="team-card-name">#GetPlayerLogs.teamName#</h3>
            </div>

            <!--- Top Performers --->
            <div class="top-performers">
              <div class="performer-card">
                <span class="performer-icon">🔥</span>
                <span class="performer-stat">#topPts.val# PTS</span>
                <span class="performer-name">#topPts.name#</span>
              </div>
              <div class="performer-card">
                <span class="performer-icon">💪</span>
                <span class="performer-stat">#topReb.val# REB</span>
                <span class="performer-name">#topReb.name#</span>
              </div>
              <div class="performer-card">
                <span class="performer-icon">🎯</span>
                <span class="performer-stat">#topAst.val# AST</span>
                <span class="performer-name">#topAst.name#</span>
              </div>
            </div>

            <div class="table-scroll-wrapper">
              <table class="bs-table">
                <thead>
                  <tr>
                    <th class="col-player">Player</th>
                    <th>FG</th>
                    <th>3PT</th>
                    <th>FT</th>
                    <th class="col-highlight">REB</th>
                    <th class="col-highlight">AST</th>
                    <th>STL</th>
                    <th>BLK</th>
                    <th>TO</th>
                    <th>FLS</th>
                    <th class="col-pts">PTS</th>
                  </tr>
                </thead>
                <tbody>
        </cfif>

        <!--- Accumulate totals --->
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

        <!--- Determine if this player is the top scorer for their team --->
        <cfset isTopScorer = false>
        <cfif getPlayerLogs.teamID EQ getTeamsPlaying.HomeTeamID AND getPlayerLogs.Points EQ homeTopPts.val AND getPlayerLogs.Points GT 0>
          <cfset isTopScorer = true>
        <cfelseif getPlayerLogs.teamID EQ getTeamsPlaying.AwayTeamID AND getPlayerLogs.Points EQ awayTopPts.val AND getPlayerLogs.Points GT 0>
          <cfset isTopScorer = true>
        </cfif>

        <tr class="player-row<cfif isTopScorer> top-scorer-row</cfif>" data-playerid="#getPlayerLogs.playerID#">
          <td class="col-player">
            <cfif getPlayerlogs.PermissionToShare EQ 'Yes'>
              <a class="player-link" href="/pages/teams/Player_Profiles/player-profile-2.cfm?playerID=#playerID#">
                <span class="jersey-badge">###getPlayerlogs.jersey#</span> #getPlayerLogs.firstName# #getPlayerLogs.LastName#
              </a>
            <cfelse>
              <span class="jersey-badge">###getPlayerlogs.jersey#</span> #getPlayerLogs.firstName# #getPlayerLogs.LastName#
            </cfif>
          </td>
          <td>#getPlayerLogs.FGM#-#getPlayerLogs.FGA#</td>
          <td>#getPlayerLogs.3FGM#-#getPlayerLogs.3FGA#</td>
          <td>#getPlayerLogs.FTM#-#getPlayerLogs.FTA#</td>
          <td class="col-highlight">#getPlayerLogs.Rebounds#</td>
          <td class="col-highlight">#getPlayerLogs.Assists#</td>
          <td>#getPlayerLogs.Steals#</td>
          <td>#getPlayerLogs.Blocks#</td>
          <td>#getPlayerLogs.Turnovers#</td>
          <td>#val(getPlayerLogs.Fouls)#</td>
          <td class="col-pts">#getPlayerLogs.Points#</td>
        </tr>

        <cfset currentTeamID = getPlayerlogs.teamID>
        <cfset prevTeamName = getPlayerLogs.teamName>
        <cfset isFirstTeam = false>

        <!--- Close last team card --->
        <cfif getPlayerlogs.recordCount EQ getPlayerLogs.currentRow>
                  <tr class="totals-row">
                    <td>TOTALS</td>
                    <td>#TotalFGM# - #TotalFGA#</td>
                    <td>#Total3FGM# - #Total3FGA#</td>
                    <td>#TotalFTM# - #TotalFTA#</td>
                    <td class="col-highlight">#TotalREB#</td>
                    <td class="col-highlight">#TotalAST#</td>
                    <td>#TotalSTL#</td>
                    <td>#TotalBLK#</td>
                    <td>#TotalTO#</td>
                    <td>#TotalFLS#</td>
                    <td class="col-pts">#TotalPTS#</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <cfset secondTeamStruct = {
            "TotalFGM": TotalFGM, "TotalFGA": TotalFGA,
            "Total3FGM": Total3FGM, "Total3FGA": Total3FGA,
            "TotalFTM": TotalFTM, "TotalFTA": TotalFTA,
            "TotalREB": TotalREB, "TotalAST": TotalAST,
            "TotalSTL": TotalSTL, "TotalBLK": TotalBLK,
            "TotalTO": TotalTO, "TotalFLS": TotalFLS,
            "TotalPTS": TotalPTS
          }>
          <cfset secondTeamTotals = boxscore.generateTeamStatsPrompt(GetPlayerLogs.teamName, secondTeamStruct)>
        </cfif>
      </cfloop>

      <br>
      <cfinclude template="recap.cfm">
    </div>
  </div>
</div>

</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../boxscore/boxscore.js?v=2.0"></script>
<script src="../boxscore/recap.js?v=1.1"></script>
