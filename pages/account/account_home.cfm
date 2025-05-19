<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />

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

<cfinclude template="account_header.cfm">

<!--- Account Page Content --->
<div class="schedule-tabs nav nav-tabs" role="tablist">
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
                        <p>Week #getPlayerSchedule.week#</p>
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
                    <cfset isWin = getPrevPlayerSchedule.homeScore GT getPrevPlayerSchedule.awayScore>
                    <cfset teamScore = getPrevPlayerSchedule.homeScore>
                    <cfset oppScore = getPrevPlayerSchedule.awayScore>
                <cfelse>
                    <cfset opponentTeam = getPrevPlayerSchedule.home>
                    <cfset isWin = getPrevPlayerSchedule.awayScore GT getPrevPlayerSchedule.homeScore>
                    <cfset teamScore = getPrevPlayerSchedule.awayScore>
                    <cfset oppScore = getPrevPlayerSchedule.homeScore>
                </cfif>

                <a href="/pages/boxscore/boxscore.cfm?scheduleID=#getPrevPlayerSchedule.scheduleID#" class="event-card-link">
                    <div class="event-card">
                        <div class="event-header">
                            <h3>#opponentTeam#</h3>
                            <p>Week #getPrevPlayerSchedule.week#</p>
                            <p class="game-result #isWin ? 'win' : 'loss'#">
                                #isWin ? 'W' : 'L'# #teamScore#-#oppScore#
                            </p>
                        </div>
                        <div class="event-details">
                            <p class="date-time">
                                <i class="fa fa-calendar"></i>
                                #DateFormat(date, "mmm d, yyyy")# | #DateTimeFormat(StartTime, "h:nn tt")#
                            </p>
                        </div>
                    </div>
                </a>
            </cfloop>
        </div>
    </div>
</div>
</div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

