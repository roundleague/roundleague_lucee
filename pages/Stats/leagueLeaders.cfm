<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Stats/leagueLeaders.css" rel="stylesheet" />

<cfquery name="getPointsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.points, p.firstName, p.lastName
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	ORDER BY points desc
	LIMIT 10
</cfquery>

<cfquery name="getReboundsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.Rebounds, p.firstName, p.lastName
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	ORDER BY Rebounds desc
	LIMIT 10
</cfquery>

<cfquery name="getAssistsLeaders" datasource="roundleague">
	SELECT ps.playerID, ps.Assists, p.firstName, p.lastName
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	ORDER BY Assists desc
	LIMIT 10
</cfquery>

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

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
</div>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

