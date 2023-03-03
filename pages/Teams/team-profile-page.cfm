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
  AND seasonID > 3
</cfquery>

<cfquery name="getTeamStandings" datasource="roundleague">
  SELECT wins, losses, teamID, seasonID
  FROM standings
  WHERE teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
  AND seasonID > 3
</cfquery>

<cfquery name="getLeadingScorer" datasource="roundleague">
  SELECT ps.PlayerID, ps.points, s.SeasonName, t.teamName
  FROM playerstats ps
  JOIN seasons s ON s.seasonID = ps.seasonID
  JOIN teams t ON ps.teamID = t.teamID
  WHERE ps.Points IN (
        SELECT
          MAX(ps.Points) AS MaxPoints
        FROM seasons s
        JOIN playerstats ps ON s.SeasonID = ps.SeasonID
        JOIN teams t ON ps.teamID = t.teamID
        WHERE t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
        GROUP BY s.SeasonName
        ORDER BY s.SeasonName ASC )
  AND t.teamID = <cfqueryparam cfsqltype="INTEGER" value="#url.teamID#">
</cfquery>

<cfdump var="#getLeadingScorer#" />

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
              <td>W/L%</td>
              <td>Playoffs W/L%</td>
              <td>Leading Scorer</td>
            </tr>
          </thead>
          <tbody>
            <cfloop query="getTeamStandings">

              <!--- Behind the scenes, calculate wins / losses percentage --->
              <cfset totalGames = getTeamStandings.Wins + getTeamStandings.Losses>
              <cfset winPercentage = NumberFormat(getTeamStandings.Wins / totalGames, '.999')>

              <tr>
                <td data-label="Season">
                  #getTeamStandings.seasonID#
                </td>
                <td data-label="Wins">#getTeamStandings.wins#</td>
                <td data-label="Losses">#getTeamStandings.losses#</td>
                <td data-label="W/L%">#winPercentage#</td>
                <td data-label="Playoffs W/L%"></td>
                <td data-label="Leading Scorer">#getLeadingScorer.playerID#</td>
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

