<cfinclude template="/header.cfm">

<!--- Only check security on prod --->
<cfif !findNoCase("127.0.0.1", CGI.HTTP_HOST)>
    <cfinclude template="captain_security_check.cfm">
</cfif>

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfoutput>

<cfquery name="getPlayerData" datasource="roundleague">
	SELECT p.playerID, lastName, firstName, position, height, weight, hometown, school, t.teamName, t.teamID
	FROM Players p
	JOIN Roster r on r.playerID = p.playerID
	JOIN Teams t on r.teamID = t.teamID
	WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
	AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND t.status = 'Active'
</cfquery>

<cfquery name="getPlayerSchedule" datasource="roundleague">
	SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.homeScore, s.awayScore, s.StartTime, s.date
	FROM schedule s
	LEFT JOIN teams as a ON s.hometeamID = a.teamID
	LEFT JOIN teams as b ON s.awayTeamID = b.teamID
	WHERE (
		a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID# ">
		OR 
		b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">)
	AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND homeScore IS null
</cfquery>

<cfquery name="getPrevPlayerSchedule" datasource="roundleague">
	SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.homeScore, s.awayScore, s.StartTime, s.date
	FROM schedule s
	LEFT JOIN teams as a ON s.hometeamID = a.teamID
	LEFT JOIN teams as b ON s.awayTeamID = b.teamID
	WHERE (
		a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID# ">
		OR 
		b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">)
	AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND homeScore IS NOT null
</cfquery>

<!--- Photo logic --->
<cfset playerPhoto = ''>
<cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
<cfset altPath = "/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG">
<cfset defaultPath = "/assets/img/PlayerProfiles/default.JPG">

<cfif FileExists(imgPath)>
    <cfset playerPhoto = imgPath>
<cfelseif FileExists(altPath)>
    <cfset playerPhoto = altPath>
<cfelse>
    <cfset playerPhoto = defaultPath>
</cfif>

<div class="main" style="background-color: var(--background-light);">
    <div class="section">
        <div class="container">
            <div class="account-header">
                <div class="profile-image">
                    <img src="#playerPhoto#" alt="#GetPlayerData.FirstName# #GetPlayerData.LastName#">
                </div>
                <div class="account-info">
                    <h1>My Account</h1>
                    <p>#GetPlayerData.FirstName# #GetPlayerData.LastName#</p>
                    <p class="position">#GetPlayerData.Position#</p>
                    <p class="team">#GetPlayerData.TeamName#</p>
                </div>
            </div>

            <div class="navigation">
                <btn class="nav-button">
                    <i class="fa fa-cog"></i> Account Settings
                </btn>
                <a href="" class="nav-button">
                    <i class="fa fa-credit-card-alt"></i> Payments
                </a>
                <a href="" class="nav-button">
                    <i class="fa-solid fa-photo-film"></i> My Media
                </a>
                <a href="" class="nav-button">
                    <i class="fa-solid fa-basketball"></i> My Career
                </a>
                <a href="" class="nav-button">
                    <i class="fa-solid fa-people-group"></i> Find Players / Team
                </a>
            </div>            <div class="schedule-tabs nav nav-tabs" role="tablist">
                <a class="tab nav-link active" data-toggle="tab" href="##follows" role="tab">Upcoming Schedule</a>
                <a class="tab nav-link" data-toggle="tab" href="##following" role="tab">Previous</a>
            </div>

            <div class="tab-content following">
                <div class="tab-pane fade show active" id="follows" role="tabpanel">
                    <div class="schedule-content">
                        <cfloop query="getPlayerSchedule">
                            <cfif getPlayerData.teamID EQ getPlayerSchedule.hometeamID>
                                <cfset opponentTeam = getPlayerSchedule.away>
                            <cfelse>
                                <cfset opponentTeam = getPlayerSchedule.home>
                            </cfif>

                            <div class="event-card">
                                <div class="event-header">
                                    <h3>#opponentTeam#</h3>
                                    <p>Game ##</p>
                                </div>
                                <div class="event-details">
                                    <p class="date-time">
                                        <i class="fa fa-calendar"></i>
                                        #DateFormat(date, "mmm d, yyyy")# | #DateTimeFormat(StartTime, "h:nn tt")#
                                    </p>
                                </div>
                            </div>
                        </cfloop>
                    </div>
                </div>                <div class="tab-pane fade" id="following" role="tabpanel">
                    <div class="schedule-content">
                        <cfloop query="getPrevPlayerSchedule">
                            <cfif getPlayerData.teamID EQ getPrevPlayerSchedule.hometeamID>
                                <cfset opponentTeam = getPrevPlayerSchedule.away>
                            <cfelse>
                                <cfset opponentTeam = getPrevPlayerSchedule.home>
                            </cfif>

                            <div class="event-card">
                                <div class="event-header">
                                    <h3>#opponentTeam#</h3>
                                    <p>Game ##</p>
                                </div>
                                <div class="event-details">
                                    <p class="date-time">
                                        <i class="fa fa-calendar"></i>
                                        #DateFormat(date, "mmm d, yyyy")# | #DateTimeFormat(StartTime, "h:nn tt")#
                                    </p>
                                </div>
                            </div>
                        </cfloop>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

