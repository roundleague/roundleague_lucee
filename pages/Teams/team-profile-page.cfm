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

<cfquery name="checkTeamPlayedSeason" datasource="roundleague"> 
  SELECT count(DISTINCT seasonID) AS seasonsPlayed
  FROM schedule 
  WHERE HomeTeamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  AND seasonID > 3
</cfquery>

<cfquery name="getTeamStandings" datasource="roundleague">
  SELECT wins, losses, teamID, s.seasonID, sea.seasonName
  FROM standings s
  JOIN seasons sea on sea.seasonID = s.seasonID
  WHERE teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  AND s.seasonID > 3
</cfquery>

<cfquery name="getLeadingScorer" datasource="roundleague">
   WITH MaxPointsPerSeason AS (
    SELECT
      s.SeasonName,
      MAX(ps.Points) AS MaxPoints
    FROM playerstats ps
    JOIN seasons s ON s.SeasonID = ps.SeasonID
    JOIN teams t ON ps.teamID = t.teamID
    WHERE t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
    GROUP BY s.SeasonName
  )

  SELECT
    ps.PlayerID,
    ps.Points,
    s.SeasonName,
    t.teamName,
    s.SeasonID,
    p.firstName,
    p.lastName
  FROM playerstats ps
  JOIN seasons s ON s.SeasonID = ps.SeasonID
  JOIN teams t ON ps.teamID = t.teamID
  JOIN players p ON p.PlayerID = ps.PlayerID
  JOIN MaxPointsPerSeason mps ON s.SeasonName = mps.SeasonName
  WHERE ps.Points = mps.MaxPoints AND t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
</cfquery>

<cfset playoffsObject = createObject("component", "library.playoffs") />

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
          <caption>Seasons: #checkTeamPlayedSeason.seasonsPlayed#</caption>
          <thead>
            <tr>
              <td>Season</td>
              <td>Wins</td>
              <td>Losses</td>
              <td>W/L%</td>
              <td>Playoffs</td>
              <td>Leading Scorer</td>
            </tr>
          </thead>
          <tbody>
            <cfloop query="getTeamStandings">

              <cfquery name="getPlayerIdBySeason" dbtype="query">
                Select PlayerID, FirstName, LastName, Points
                From [getLeadingScorer]
                Where seasonID = #getTeamStandings.seasonID#
              </cfquery>

              <cfquery name="getPlayoffFinish" datasource="roundleague">
                SELECT t.teamName, ps.seasonID, max(ps.bracketRoundID) as maxBracketRoundID, pb.MaxTeamSize, pb.Playoffs_bracketID, pb.Name
                FROM playoffs_schedule ps
                JOIN playoffs_bracket pb ON ps.Playoffs_BracketID = pb.Playoffs_bracketID
                JOIN teams t ON t.teamId = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
                WHERE (hometeamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#"> OR awayteamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">)
                AND ps.seasonID = <cfqueryparam cfsqltype="INTEGER" value="#getTeamStandings.seasonID#">
              </cfquery>

              <!--- There is no way to tell which team played in which bracket... --->
              <!--- If the teamID is in this query, they are a champion --->
              <cfquery name="getChampion" datasource="roundleague">
                SELECT championsID
                FROM champions
                WHERE teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
                AND seasonID = <cfqueryparam cfsqltype="INTEGER" value="#getTeamStandings.seasonID#">
              </cfquery>

              <!--- Get first initial --->
              <cfset playerName = getPlayerIdBySeason.FirstName>
              <cfset firstInitial = Mid(playerName, 1, 1)>

              <!--- Format points --->
              <cfset formattedPoints = NumberFormat(getPlayerIdBySeason.points, "0.0")>

              <!--- Behind the scenes, calculate wins / losses percentage --->
              <cfset totalGames = getTeamStandings.Wins + getTeamStandings.Losses>
              <cfif totalGames NEQ 0>
                <cfset winPercentage = NumberFormat(getTeamStandings.Wins / totalGames, '.999')>
              <cfelse>
                <cfset winPercentage = NumberFormat(0, '.999')>
              </cfif>

              <!--- Playoffs Finished Logic --->
              <!--- Check champion query first --->
              <cfif getChampion.recordCount>
                <cfset playoffsFinishedText = '<b>Champion</b>'>
              <cfelseif getPlayoffFinish.maxBracketRoundID NEQ ''>
                <!--- If the team is not the champion that season --->
                <cfset playoffsFinishedText = playoffsObject.getPlayoffTextByMaxBracketRoundID(getPlayoffFinish.maxBracketRoundID, getPlayoffFinish.MaxTeamSize)>
              <cfelse>
                <cfset playoffsFinishedText = '-'>
              </cfif>

              <!--- NIT Prefix Logic --->
              <cfif getPlayoffFinish.Name EQ 'NIT'>
                <cfset playoffsFinishedText &= " (NIT)">
              </cfif>

              <tr>
                <td data-label="Season">
                  #getTeamStandings.seasonName#
                </td>
                <td data-label="Wins">#getTeamStandings.wins#</td>
                <td data-label="Losses">#getTeamStandings.losses#</td>
                <td data-label="W/L%">#winPercentage#</td>
                <td data-label="Playoffs">
                  #playoffsFinishedText#
                </td>
                <td data-label="Leading Scorer">
                    <a href="Player_Profiles/player-profile-2.cfm?playerID=#getPlayerIdBySeason.playerID#" style="font-weight: bold;">
                      #firstInitial#. #getPlayerIdBySeason.LastName#
                    </a>
                    (#formattedPoints#)
                </td>
              </tr>
          </cfloop>
          </tbody>
        </table>
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../Teams/team-profile-page.js?v=1.1"></script>

