<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Stats/leagueLeaders.css?v=1.1" rel="stylesheet" />

<cfquery name="getMinGamesLimit" datasource="roundleague">
    SELECT max(gamesPlayed) as TotalGames
    FROM playerstats
    WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfquery name="getLeagues" datasource="roundleague">
    SELECT LeagueID, LeagueName
    FROM leagues
    WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfparam name="form.leagueSelect" default="#getLeagues.leagueID#">

<cfif getMinGamesLimit.totalGames NEQ ''>
    <cfset gamesLimit = getMinGamesLimit.TotalGames / 2>
<cfelse>
    <cfset gamesLimit = 1>
</cfif>

<cfquery name="getPointsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.points, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY points desc
	LIMIT 10
</cfquery>

<cfquery name="getReboundsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.Rebounds, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY Rebounds desc
	LIMIT 10
</cfquery>

<cfquery name="getAssistsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.Assists, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY Assists desc
	LIMIT 10
</cfquery>

<cfquery name="getStealsLeaders" datasource="roundleague">
    SELECT ps.playerID, ps.Steals, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
    FROM playerstats ps
    JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
    WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY Steals desc
    LIMIT 10
</cfquery>

<cfquery name="getBlocksLeaders" datasource="roundleague">
    SELECT ps.playerID, ps.Blocks, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
    FROM playerstats ps
    JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
    WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY Blocks desc
    LIMIT 10
</cfquery>

<cfquery name="get3FGMLeaders" datasource="roundleague">
    SELECT pgl.playerID, SUM(pgl.3FGM) AS 3PTS, p.firstName, p.lastName, r.jersey, t.teamName, ps.gamesplayed
    FROM playergamelog pgl
    JOIN playerstats ps ON ps.playerID = pgl.playerID
    JOIN players p ON p.playerID = ps.playerID
    JOIN teams t ON t.teamID = ps.teamID
    JOIN divisions d ON t.divisionID = d.divisionID
    JOIN roster r on r.playerID = p.playerID
    JOIN leagues l on l.leagueID = d.leagueID
    WHERE pgl.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND l.leagueID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    GROUP BY PlayerID
    ORDER BY 3PTS DESC
    LIMIT 10
</cfquery>

<cfoutput>
<form method="POST">
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <div class="selectLeagueBox">
            <label for="seasonID">Select League</label>
            <select name="leagueSelect" id="Seasons" onchange="this.form.submit()">
                <cfloop query="getLeagues">
                    <option value="#getLeagues.leagueID#" <cfif form.leagueSelect EQ getLeagues.leagueID>selected</cfif>>#getLeagues.leagueName#</option>
                </cfloop>
            </select>
        </div>
<h2 id="title" style="color: black;">League Leaders</h2> 
<div class="hover-table-layout">
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/#getPointsLeaders.playerID#.JPG">
		    <cfif FileExists(imgPath)>
            	<img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
            	<img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">Points</h1>
              </div>
        </div>
        <div class="listing">
        	<cfloop query="getPointsLeaders">
        		<h4 class="noTopSpace">#getPointsLeaders.currentRow#. #getPointsLeaders.FirstName# #getPointsLeaders.LastName# - #NumberFormat(getPointsLeaders.Points, "0.0")#</h4>
        	</cfloop>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/#getReboundsLeaders.playerID#.JPG">
		    <cfif FileExists(imgPath)>
            	<img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
            	<img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">Rebounds</h1>
              </div>
        </div>
        <div class="listing">
        	<cfloop query="getReboundsLeaders">
        		<h4 class="noTopSpace">#getReboundsLeaders.currentRow#. #getReboundsLeaders.FirstName# #getReboundsLeaders.LastName# - #NumberFormat(getReboundsLeaders.Rebounds, "0.0")#</h4>
        	</cfloop>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/#getAssistsLeaders.playerID#.JPG">
		    <cfif FileExists(imgPath)>
            	<img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
            	<img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">Assists</h1>
              </div>
        </div>
        <div class="listing">
        	<cfloop query="getAssistsLeaders">
        		<h4 class="noTopSpace">#getAssistsLeaders.currentRow#. #getAssistsLeaders.FirstName# #getAssistsLeaders.LastName# - #NumberFormat(getAssistsLeaders.Assists, "0.0")#</h4>
        	</cfloop>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
            <cfset imgPath = "/assets/img/PlayerProfiles/#get3FGMLeaders.playerID#.JPG">
            <cfif FileExists(imgPath)>
                <img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
                <img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">3 Pointers</h1>
              </div>
        </div>
        <div class="listing">
            <cfloop query="get3FGMLeaders">
                <h4 class="noTopSpace">#get3FGMLeaders.currentRow#. #get3FGMLeaders.FirstName# #get3FGMLeaders.LastName# - #get3FGMLeaders.3PTS#</h4>
            </cfloop>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
            <cfset imgPath = "/assets/img/PlayerProfiles/#getStealsLeaders.playerID#.JPG">
            <cfif FileExists(imgPath)>
                <img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
                <img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">Steals</h1>
              </div>
        </div>
        <div class="listing">
            <cfloop query="getStealsLeaders">
                <h4 class="noTopSpace">#getStealsLeaders.currentRow#. #getStealsLeaders.FirstName# #getStealsLeaders.LastName# - #NumberFormat(getStealsLeaders.Steals, "0.0")#</h4>
            </cfloop>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
            <cfset imgPath = "/assets/img/PlayerProfiles/#getBlocksLeaders.playerID#.JPG">
            <cfif FileExists(imgPath)>
                <img class="playerPic" src="#imgPath#" alt="image">
            <cfelse>
                <img class="playerPic" src="/assets/img/PlayerProfiles/default.JPG">
            </cfif>
              <div class="caption">
                <h1 class="noTopSpace catTitle">Blocks</h1>
              </div>
        </div>
        <div class="listing">
            <cfloop query="getBlocksLeaders">
                <h4 class="noTopSpace">#getBlocksLeaders.currentRow#. #getBlocksLeaders.FirstName# #getBlocksLeaders.LastName# - #NumberFormat(getBlocksLeaders.Blocks, "0.0")#</h4>
            </cfloop>
        </div>
    </div>
    <p><i>* Must have played at least half the season to qualify</i></p>
</div>

      </div>
    </div>
</div>
</form>
</cfoutput>
<cfinclude template="/footer.cfm">

