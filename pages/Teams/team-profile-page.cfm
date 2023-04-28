<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="../Teams/team-profile-page.css">

<cfquery name="getTeamData" datasource="roundleague">
	SELECT 
    p.playerID, 
    lastName, 
    firstName, 
    teamName, 
    position, 
    height, 
    weight, 
    hometown, 
    school, 
    s.seasonName, 
    d.divisionName,
    t.captainPlayerID,
    r.jersey,
    p.PermissionToShare
	FROM players p
	JOIN roster r ON r.PlayerID = p.playerID
	JOIN teams t ON t.teamId = r.teamID
	JOIN divisions d ON d.divisionID = t.DivisionID
	JOIN seasons s ON s.seasonID = t.seasonID
	WHERE r.seasonID = s.seasonID
	AND t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  <!--- AND p.PermissionToShare != 'No' --->
  GROUP BY lastName, firstName
</cfquery>

<cfquery name="getTeamDataStats" datasource="roundleague">
  SELECT 
    p.playerID, 
    lastName, 
    firstName, 
    t.captainPlayerID,
    r.jersey,
    p.PermissionToShare,
    ps.Points,
    ps.Rebounds,
    ps.Assists,
    ps.Blocks,
    ps.Steals
  FROM players p
  JOIN roster r ON r.PlayerID = p.playerID
  JOIN teams t ON t.teamId = r.teamID
  JOIN divisions d ON d.divisionID = t.DivisionID
  JOIN seasons s ON s.seasonID = t.seasonID
  JOIN playerstats ps ON ps.PlayerID = p.playerID AND ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  WHERE r.seasonID = s.seasonID
  AND t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  GROUP BY lastName, firstName
</cfquery>

<cfquery name="getTeamDataM" datasource="roundleague"> 
  SELECT count(DISTINCT seasonID) AS seasonsPlayed
  FROM schedule 
  WHERE HomeTeamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  and seasonID > 3
</cfquery>
<cfquery name="getTeamStandings" datasource="roundleague">
  SELECT standings.TeamID, standings.Wins, standings.Losses, standings.SeasonID, Seasons.SeasonName
  FROM standings
  JOIN seasons
  ON standings.SeasonID = seasons.SeasonID
  WHERE standings.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  AND standings.seasonID > 3
</cfquery>

<cfquery name = "getLeadingScore" datasource = "roundleague">
  SELECT playerstats.PlayerID, playerstats.points, seasons.SeasonName, teams.teamName, seasons.SeasonID, players.firstName, players.lastName
  FROM playerstats
  JOIN seasons ON seasons.SeasonID = playerstats.SeasonID
  Join players ON playerstats.PlayerID = players.playerID
  JOIN teams ON playerstats.teamID = teams.teamID
  WHERE playerstats.Points IN (
    Select MAX(playerstats.Points) AS MaxPoints
    FROM seasons
    JOIN playerstats ON seasons.SeasonID = playerstats.SeasonID
    JOIN teams ON playerstats.teamID = teams.teamID
    WHERE teams.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
    GROUP BY seasons.SeasonName
    ORDER BY seasons.SeasonName ASC)
  AND teams.teamId = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
</cfquery>

<cfset playoffsObject = createObject("component", "library.playoffs")/>


<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">

      <!-- Tab links -->
      <div class="tab">
        <button class="tablinks playerInfoBtn" id="defaultOpen">Player Info</button>
        <button class="tablinks playerStatsBtn">Player Stats</button>
        <button class="tablinks franchiseInfoBtn">Franchise Info</button>
      </div>

      <!--- PlayerInfo tab --->
      <div id="PlayerInfo" class="container tabcontent">

        <!--- Content Here --->
        <h1>#getTeamData.teamName#</h1>

        <table class="bolder">
          <caption>#getTeamData.seasonName# Roster</caption>
          <thead>
            <tr>
            	<td>Name</td>
              <td>Jersey</td>
            	<td>Position</td>
            	<td>Height</td>
            	<td>Weight</td>
            	<td>Hometown</td>
            	<td>School</td>
            </tr>
          </thead>
          <tbody>
          	<cfloop query="getTeamData">
	            <tr>
	            	<td>
                  <cfif PermissionToShare EQ 'YES'>
                    <a href="Player_Profiles/player-profile-2.cfm?playerID=#playerID#" style="font-weight: bold;">
                      #firstName# #lastName# <cfif getTeamData.captainPlayerID EQ getTeamData.playerID>(C)</cfif>
                    </a>
                  <cfelse>
                    #firstName# #lastName# <cfif getTeamData.captainPlayerID EQ getTeamData.playerID>(C)</cfif>
                  </cfif>
                </td>
                <td>#Jersey#</td>
	            	<td>#Position#</td>
	            	<td><cfif PermissionToShare EQ 'Yes'>#Height#</cfif></td>
	            	<td><cfif PermissionToShare EQ 'Yes'>#Weight#</cfif></td>
	            	<td><cfif PermissionToShare EQ 'Yes'>#Hometown#</cfif></td>
	            	<td><cfif PermissionToShare EQ 'Yes'>#School#</cfif></td>
	            </tr>
        	</cfloop>
          </tbody>
        </table>
        
      </div>

      <!--- Player averages tab --->
      <div id="PlayerStats" class="container tabcontent">
        <!--- Content Here --->
        <h1>#getTeamData.teamName#</h1>

        <table class="bolder">
          <caption>#getTeamData.seasonName# Roster Stats</caption>
          <thead>
            <tr>
              <td>Name</td>
              <td>Jersey</td>
              <td>Points</td>
              <td>Rebounds</td>
              <td>Asts</td>
              <td>Blks</td>
              <td>Stls</td>
            </tr>
          </thead>
          <tbody>
            <cfloop query="getTeamDataStats">
              <tr>
                <td data-label="Name">
                  <cfif PermissionToShare EQ 'YES'>
                    <a href="Player_Profiles/player-profile-2.cfm?playerID=#playerID#" style="font-weight: bold;">
                      #firstName# #lastName# <cfif getTeamDataStats.captainPlayerID EQ getTeamDataStats.playerID>(C)</cfif>
                    </a>
                  <cfelse>
                    #firstName# #lastName# <cfif getTeamDataStats.captainPlayerID EQ getTeamDataStats.playerID>(C)</cfif>
                  </cfif>
                </td>
                <td data-label="Jersey">#Jersey#</td>
                <td data-label="Points">#NumberFormat(Points, "0.0")#</td>
                <td data-label="Rebounds">#NumberFormat(Rebounds, "0.0")#</td>
                <td data-label="Asts">#NumberFormat(Assists, "0.0")#</td>
                <td data-label="Blks">#NumberFormat(Blocks, "0.0")#</td>
                <td data-label="Stls">#NumberFormat(Steals, "0.0")#</td>
              </tr>
          </cfloop>
          </tbody>
        </table>
      </div>

    <!--- FranchiseInfo Tab --->
      <div id="FranchiseInfo" class="container tabcontent">

        <!--- Content Here --->
        <h1>#getTeamData.teamName#</h1>

        <table class="bolder">
          <caption>Seasons: #getTeamDataM.seasonsPlayed#</caption>
          <thead>
            <tr>
              <td>Season</td>
              <td>Wins</td>
              <td>Losses</td>
              <td>PCT</td>
              <td>Playoffs</td>
              <td>Leading Score</td>
            </tr>
          </thead>
          <tbody>
            <cfloop query="getTeamStandings">

              <!--- Query of Queries --->
              <cfquery name = "getPlayerIDBySeason" dbtype= "query">
                SELECT PlayerID, lastName, firstName, points
                FROM [getLeadingScore]
                Where seasonID = #getTeamStandings.seasonID#
              </cfquery>

              <cfquery name = "getPlayoffsFinish" datasource="roundleague">
                SELECT t.teamName, ps.seasonID, max(ps.bracketRoundID) as maxBracketRoundID, pb.MaxTeamSize, pb.Playoffs_bracketID, pb.Name
                FROM playoffs_schedule ps
                JOIN playoffs_bracket pb ON ps.Playoffs_BracketID = pb.Playoffs_bracketID
                JOIN teams t ON t.teamId = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
                WHERE (hometeamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#"> OR awayteamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">)
                AND ps.seasonID = #getTeamStandings.seasonID#
              </cfquery>

              <cfquery name = "getChampion" datasource="roundleague">
                Select championsID
                From champions
                WHERE teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#"> 
                AND seasonID = <cfqueryparam cfsqltype="INTEGER" value="#getTeamStandings.seasonID#">
              </cfquery>


              <!---setting variables for initial and points --->
              <cfset firstInitial = Mid(#getPlayerIDBySeason.firstName#, 1, 1)>
              <cfset formatPoints = NumberFormat(#getPlayerIDBySeason.points#, '0.0')>

             <!--- Behind the scenes, calculate wins / losses percentage --->
             <cfset totalGames = getTeamStandings.Wins + getTeamStandings.Losses>
             <cfset wins_percentage = NumberFormat(getTeamStandings.Wins/totalGames, '.999')>

              <!---Championship Logic --->
              <cfif getChampion.recordCount>
                <cfset playoffsFinishedText = '<b>Champion</b>'>
              <cfelseif getPlayoffsFinish.maxBracketRoundID NEQ ''>
              <!--- If the team is not the champion that season --->
                <cfset playoffsFinishedText = playoffsObject.getPlayoffTextByMaxBracketRoundID(getPlayoffsFinish.maxBracketRoundID, getPlayoffsFinish.MaxTeamSize)>
              <cfelse>
                <cfset playoffsFinishedText = '-'>
              </cfif>

              <!--- NIT Profix Logic --->
              <cfif getPlayoffsFinish.Name EQ 'NIT'>
                <cfset playoffsFinishedText &= " (NIT)">
              </cfif>

               <tr>

                <!--- data area--->
                <td data-label="Seasons">#getTeamStandings.SeasonName#</td>
                <td data-label="Wins">#getTeamStandings.Wins#</td>
                <td data-label="Losses">#getTeamStandings.Losses#</td>
                <td data-label="Win Percentage">#wins_percentage#</td>
                <td data-label="Playoffs">
                  #playoffsFinishedText#
                </td>
                <td data-label="Leading Score">
                  <a href="Player_Profiles/player-profile-2.cfm?playerID=#getPlayerIDBySeason.playerID#" style="font-weight: bold;">
                      #firstInitial#. #getPlayerIDBySeason.lastName#
                  </a>(#formatPoints#)
                </td>
              </tr>
          </cfloop>
          </tbody>
        </table>
      </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../Teams/team-profile-page.js?v=1.1"></script>

