<cfinclude template="/header.cfm">
<cfparam name="url.switched" default="0">
<cfparam name="url.teamName" default="">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfoutput>
<cfinclude template="account_header.cfm">
<!--- Player queries are now included in account_header.cfm --->

<!--- If player is on a team, get their schedule --->
<cfif isDefined("getPlayerData") AND getPlayerData.recordCount GT 0>
	<cfquery name="getPlayerSchedule" datasource="roundleague">
		SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.homeScore, s.awayScore, s.StartTime, s.date
		FROM schedule s
		LEFT JOIN teams as a ON s.hometeamID = a.teamID
		LEFT JOIN teams as b ON s.awayTeamID = b.teamID
		WHERE (
			a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">
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
			a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">
			OR 
			b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">)
		AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
		AND homeScore IS NOT null
	</cfquery>
<cfelse>
	<!--- Create empty queries for free agents --->
	<cfset getPlayerSchedule = queryNew("")>
	<cfset getPrevPlayerSchedule = queryNew("")>
</cfif>

<!--- Account Page Content --->
<cfif getPlayerData.recordCount GT 0>
    <div class="schedule-tabs nav nav-tabs" role="tablist">
        <a class="tab nav-link active" data-toggle="tab" href="##follows" role="tab">Upcoming Schedule</a>
        <a class="tab nav-link" data-toggle="tab" href="##following" role="tab">Previous</a>
    </div>
<cfelse>
    <div class="free-agent-notice">
        <div class="alert alert-info" role="alert">
            <h4><i class="fa-solid fa-info-circle"></i> You're currently a Free Agent</h4>
            <p>You are not currently on a team roster. When you join a team, your game schedule will appear here.</p>
        </div>
    </div>
</cfif>

<cfif getPlayerData.recordCount GT 0>
<div class="tab-content following">
    <div class="tab-pane fade show active" id="follows" role="tabpanel">
        <div class="schedule-content">
            <cfif getPlayerSchedule.recordCount GT 0>
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
                    </div>                </div>
                </cfloop>
            <cfelse>
                <div class="no-games-message">
                    <p><i class="fa-solid fa-calendar-xmark"></i> No upcoming games scheduled.</p>
                </div>
            </cfif>
        </div>
    </div>                
    <div class="tab-pane fade" id="following" role="tabpanel">
        <div class="schedule-content">
            <cfif getPrevPlayerSchedule.recordCount GT 0>
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
                    </div>                </a>
                </cfloop>
            <cfelse>
                <div class="no-games-message">
                    <p><i class="fa-solid fa-calendar-xmark"></i> No previous games found.</p>
                </div>
            </cfif>
        </div>
    </div>
</div>
</cfif>
</div>
</div>
</cfoutput>
<cfif url.switched EQ 1>
<cfoutput>
<div id="switch-toast" style="position:fixed; bottom:30px; left:50%; transform:translateX(-50%); background:##1abc9c; color:##fff; padding:16px 28px; border-radius:8px; font-size:15px; font-weight:600; box-shadow:0 4px 16px rgba(0,0,0,0.18); z-index:9999; text-align:center; max-width:90%;">
    Congratulations, you have successfully signed with #htmlEditFormat(url.teamName)#!
</div>
<script>
  setTimeout(function() {
    $('##switch-toast').fadeOut(600);
  }, 4000);
</script>
</cfoutput>
</cfif>

<cfinclude template="/footer.cfm">

