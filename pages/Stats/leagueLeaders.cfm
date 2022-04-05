<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Stats/leagueLeaders.css?v=1.1" rel="stylesheet" />

<cfparam name="form.leagueSelect" default="0">

<cfquery name="getMinGamesLimit" datasource="roundleague">
    SELECT max(gamesPlayed) as TotalGames
    FROM playerstats
    WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfif getMinGamesLimit.totalGames IS NULL>
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
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND IFNULL(d.isWomens, 0) = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
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
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND IFNULL(d.isWomens, 0) = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
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
	WHERE ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND IFNULL(d.isWomens, 0) = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.leagueSelect#">
    AND ps.gamesplayed >= <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gamesLimit#">
    ORDER BY Assists desc
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
                    <option value="0" <cfif form.leagueSelect EQ 0>selected</cfif>>Men's League</option>
                    <option value="1" <cfif form.leagueSelect EQ 1>selected</cfif>>Women's League</option>
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
        		<h4 class="noTopSpace">#getPointsLeaders.currentRow#. #getPointsLeaders.FirstName# #getPointsLeaders.LastName# - #getPointsLeaders.Points#</h4>
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
        		<h4 class="noTopSpace">#getReboundsLeaders.currentRow#. #getReboundsLeaders.FirstName# #getReboundsLeaders.LastName# - #getReboundsLeaders.Rebounds#</h4>
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
        		<h4 class="noTopSpace">#getAssistsLeaders.currentRow#. #getAssistsLeaders.FirstName# #getAssistsLeaders.LastName# - #getAssistsLeaders.Assists#</h4>
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

