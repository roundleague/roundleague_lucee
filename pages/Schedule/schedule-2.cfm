<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<!--- Scripts --->
<cfoutput>
<script>window.SCHEDULE_API_BASE = '#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#';</script>
</cfoutput>
<script src="/pages/Schedule/schedule-2.js"></script>
<link href="../Schedule/schedule-2.css?v=1.2" rel="stylesheet">

<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfparam name="form.divisionID" default="#getDivisions.divisionID#">

<cfquery name="getSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore, s.status, d.divisionID, d.divisionName
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  JOIN divisions d ON s.DivisionID = d.divisionID
  JOIN leagues l ON l.leagueID = d.leagueID
  WHERE s.seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  AND d.divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
  ORDER BY WEEK, date, startTime
</cfquery>

<cfquery name="getLatestWeek" dbtype="query">
  SELECT max(week)+1 as latestWeek
  FROM getSchedule
  WHERE homeScore IS NOT NULL
</cfquery>


<cfif getLatestWeek.recordCount EQ 0>
  <!--- Only if all weeks have been played --->
  <cfquery name="getLatestWeek" dbtype="query">
    SELECT max(week) as latestWeek
    FROM getSchedule
  </cfquery>
</cfif>

<cfoutput>
  <form method="POST">
    <div class="main" style="background-color: white; margin-top: 25px;">
      <div class="schedulePageWrap">

        <!--- Page Header Row --->
        <div class="scheduleHeaderRow">
          <h1 class="schedulePageTitle">Schedule</h1>
          <div class="scheduleControls">
            <select name="DivisionID" id="Divisions" class="scheduleSelect" onchange="this.form.submit()">
              <cfloop query="getDivisions">
                <option value="#getDivisions.DivisionID#"<cfif getDivisions.DivisionID EQ form.DivisionID> selected</cfif>>#getDivisions.DivisionName#</option>
              </cfloop>
            </select>
            <input type="text" class="scheduleSearchInput" id="myInput" onkeyup="myFunction()" placeholder="Search for teams..." title="Type in a team">
          </div>
        </div>

        <!--- ============ DESKTOP TABLE ============ --->
        <div class="scheduleTableWrap">
          <table id="myTable" class="scheduleTable">
            <thead>
              <tr>
                <th>Home</th>
                <th class="vsColHeader"></th>
                <th>Away</th>
                <th>Date</th>
                <th>Time</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <cfset currentWeek = 1>
              <cfset weekFirstDate = "">
              <cfset currentDay = "">
              <cfloop query="getSchedule">

                <!--- Determine game status --->
                <cfset gameIsBye = (len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) EQ 0)>
                <cfset gameHasScore = (getSchedule.homeScore NEQ '' AND getSchedule.awayScore NEQ '')>
                <cfset gameIsToday = (isDate(getSchedule.date) AND DateFormat(getSchedule.date, 'yyyy-mm-dd') EQ DateFormat(now(), 'yyyy-mm-dd'))>
                <cfset gameIsChampionship = (getSchedule.homeTeamID EQ '' AND getSchedule.awayTeamID EQ '' AND NOT gameIsBye)>
                <cfset dbStatus = lCase(getSchedule.status)>
                <cfif gameIsBye>
                  <cfset gameStatus = 'BYE'>
                  <cfset statusClass = 'statusBye'>
                <cfelseif gameIsChampionship>
                  <cfset gameStatus = 'CHAMPIONSHIP'>
                  <cfset statusClass = 'statusChampionship'>
                <cfelseif dbStatus EQ 'final'>
                  <cfset gameStatus = 'FINAL'>
                  <cfset statusClass = 'statusFinal'>
                <cfelseif dbStatus EQ 'live'>
                  <cfset gameStatus = 'LIVE'>
                  <cfset statusClass = 'statusLive'>
                <cfelseif gameIsToday>
                  <cfset gameStatus = 'TODAY'>
                  <cfset statusClass = 'statusToday'>
                <cfelse>
                  <cfset gameStatus = 'SCHEDULED'>
                  <cfset statusClass = 'statusUpcoming'>
                </cfif>

                <cfif homeScore GT awayScore>
                  <cfset homeBoldClass = 'winnerScore'>
                  <cfset awayBoldClass = ''>
                <cfelseif awayScore GT homeScore>
                  <cfset homeBoldClass = ''>
                  <cfset awayBoldClass = 'winnerScore'>
                <cfelse>
                  <cfset homeBoldClass = ''>
                  <cfset awayBoldClass = ''>
                </cfif>

                <cfif currentWeek NEQ getSchedule.week OR getSchedule.currentRow EQ 1>
                  <cfset currentWeek = getSchedule.week>
                  <cfset weekFirstDate = getSchedule.date>
                  <cfset currentDay = "">
                  <tr class="weekRow" id="week_#currentWeek#">
                    <td colspan="6" class="weekHeaderCell">
                      WEEK #currentWeek#
                    </td>
                  </tr>
                </cfif>

                <cfif isDate(getSchedule.date) AND DateFormat(getSchedule.date, 'yyyy-mm-dd') NEQ currentDay>
                  <cfset currentDay = DateFormat(getSchedule.date, 'yyyy-mm-dd')>
                  <tr class="dayRow">
                    <td colspan="6" class="dayHeaderCell">#uCase(DateFormat(getSchedule.date, "dddd, mmmm d, yyyy"))#</td>
                  </tr>
                </cfif>

                <tr class="gameRow<cfif gameHasScore> hasScore</cfif>">
                  <!--- Home --->
                  <td data-label="Home" class="teamCell">
                    <cfif gameHasScore>
                      <a href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">
                        <span class="teamName #homeBoldClass#">#getSchedule.Home#</span>
                        <span class="teamScore #homeBoldClass#">#getSchedule.HomeScore#</span>
                      </a>
                    <cfelse>
                      <span class="teamName">#(getSchedule.Home EQ '' ? 'TBD' : getSchedule.Home)#</span>
                    </cfif>
                  </td>

                  <td class="vsCell">vs</td>

                  <!--- Away --->
                  <td data-label="Away" class="teamCell">
                    <cfif gameHasScore>
                      <a href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">
                        <span class="teamName #awayBoldClass#">#getSchedule.Away#</span>
                        <span class="teamScore #awayBoldClass#">#getSchedule.AwayScore#</span>
                      </a>
                    <cfelse>
                      <span class="teamName">#(gameIsBye ? 'BYE' : (getSchedule.Away EQ '' ? 'TBD' : getSchedule.Away))#</span>
                    </cfif>
                  </td>

                  <td data-label="Date">
                    #DateFormat(getSchedule.Date, "mm/dd/yyyy")#
                  </td>
                  <td data-label="Time">
                    #(len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) GT 0) ? DateTimeFormat(getSchedule.startTime, "h:nn tt") : 'BYE'#
                  </td>
                  <td data-label="Status">
                    <div class="statusCellWrap">
                      <span class="statusBadge #statusClass#">#gameStatus#</span>
                      <cfif dbStatus EQ 'live'>
                        <span class="liveClockEl" data-schedule-id="#getSchedule.scheduleID#">--:-- H1</span>
                      </cfif>
                    </div>
                  </td>
                </tr>
              </cfloop>
            </tbody>
          </table>
        </div>

        <!--- ============ MOBILE CARDS (NBA STYLE) ============ --->
        <div class="scheduleMobileWrap">
          <cfset mobileWeek = 0>
          <cfset mobileDay = "">
          <cfloop query="getSchedule">

            <!--- Determine game status --->
            <cfset mGameIsBye = (len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) EQ 0)>
            <cfset mGameHasScore = (getSchedule.homeScore NEQ '' AND getSchedule.awayScore NEQ '')>
            <cfset mGameIsToday = (isDate(getSchedule.date) AND DateFormat(getSchedule.date, 'yyyy-mm-dd') EQ DateFormat(now(), 'yyyy-mm-dd'))>
            <cfset mGameIsChampionship = (getSchedule.homeTeamID EQ '' AND getSchedule.awayTeamID EQ '' AND NOT mGameIsBye)>
            <cfset mDbStatus = lCase(getSchedule.status)>
            <cfif mGameIsBye>
              <cfset mGameStatus = 'BYE'>
              <cfset mStatusClass = 'statusBye'>
            <cfelseif mGameIsChampionship>
              <cfset mGameStatus = 'CHAMPIONSHIP'>
              <cfset mStatusClass = 'statusChampionship'>
            <cfelseif mDbStatus EQ 'final'>
              <cfset mGameStatus = 'FINAL'>
              <cfset mStatusClass = 'statusFinal'>
            <cfelseif mDbStatus EQ 'live'>
              <cfset mGameStatus = 'LIVE'>
              <cfset mStatusClass = 'statusLive'>
            <cfelseif mGameIsToday>
              <cfset mGameStatus = 'TODAY'>
              <cfset mStatusClass = 'statusToday'>
            <cfelse>
              <cfset mGameStatus = 'SCHEDULED'>
              <cfset mStatusClass = 'statusUpcoming'>
            </cfif>

            <cfif homeScore GT awayScore>
              <cfset mHomeBold = 'winnerScore'>
              <cfset mAwayBold = ''>
            <cfelseif awayScore GT homeScore>
              <cfset mHomeBold = ''>
              <cfset mAwayBold = 'winnerScore'>
            <cfelse>
              <cfset mHomeBold = ''>
              <cfset mAwayBold = ''>
            </cfif>

            <cfif mobileWeek NEQ getSchedule.week OR getSchedule.currentRow EQ 1>
              <cfset mobileWeek = getSchedule.week>
              <cfset mobileDay = "">
              <div class="mobileWeekHeader weekRowMobile" id="mweek_#mobileWeek#">
                WEEK #mobileWeek#
              </div>
            </cfif>

            <cfif isDate(getSchedule.date) AND DateFormat(getSchedule.date, 'yyyy-mm-dd') NEQ mobileDay>
              <cfset mobileDay = DateFormat(getSchedule.date, 'yyyy-mm-dd')>
              <div class="mobileDayHeader">#uCase(DateFormat(getSchedule.date, "dddd, mmmm d, yyyy"))#</div>
            </cfif>

            <!--- NBA-style game block --->
            <div class="gameBlock gameCardItem<cfif mGameHasScore> hasScore</cfif>" data-home="#getSchedule.Home#" data-away="#getSchedule.Away#">

              <cfif mGameHasScore>
                <!--- === COMPLETED GAME === --->
                <a href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#" class="gameBlockLink">
                  <div class="gameBlockLine">
                    <span class="gbTeam #mHomeBold#">#uCase(getSchedule.Home)#</span>
                    <span class="gbScore #mHomeBold#">#getSchedule.HomeScore#</span>
                  </div>
                  <div class="gameBlockLine">
                    <span class="gbTeam #mAwayBold#">#uCase(getSchedule.Away)#</span>
                    <span class="gbScore #mAwayBold#">#getSchedule.AwayScore#</span>
                  </div>
                </a>
                <div class="gameBlockFooter">
                  <span class="statusBadge #mStatusClass#">#mGameStatus#</span>
                  <cfif mDbStatus EQ 'live'>
                    <span class="liveClockEl" data-schedule-id="#getSchedule.scheduleID#">--:-- H1</span>
                  </cfif>
                </div>

              <cfelseif mGameIsBye>
                <!--- === BYE WEEK === --->
                <div class="gameBlockLine">
                  <span class="gbTeam">#uCase(getSchedule.Home)#</span>
                </div>
                <div class="gameBlockFooter">
                  <span class="statusBadge statusBye">BYE</span>
                </div>

              <cfelse>
                <!--- === UPCOMING GAME === --->
                <div class="gameBlockLine">
                  <span class="gbTeam">#uCase(getSchedule.Home EQ '' ? 'TBD' : getSchedule.Home)#</span>
                </div>
                <div class="gameBlockVs">VS</div>
                <div class="gameBlockLine">
                  <span class="gbTeam">#uCase(getSchedule.Away EQ '' ? 'TBD' : getSchedule.Away)#</span>
                </div>
                <div class="gameBlockFooter">
                  <span class="statusBadge #mStatusClass#">#mGameStatus#</span>
                  <span class="gameBlockMeta">
                    <cfif isDate(getSchedule.date)>#DateFormat(getSchedule.Date, "ddd")# &bull; </cfif>#DateTimeFormat(getSchedule.startTime, "h:nn tt")#
                  </span>
                </div>
              </cfif>

            </div>
          </cfloop>
        </div>

      </div><!--- /.schedulePageWrap --->
    </div>
  </form>
</cfoutput>

<cfinclude template="/footer.cfm">
