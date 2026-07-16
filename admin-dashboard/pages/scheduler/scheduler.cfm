
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<link href="../scheduler/scheduler.css?v=1.4" rel="stylesheet">

<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>
<cfparam name="form.divisionID" default="#getDivisions.divisionID#">
<cfparam name="toastMsg" default="">
<cfparam name="toastClass" default="">

<cfparam name="form.formMode" default="">

<cfif isDefined("form.editScheduleID")>
  <cfinclude template="scheduler-save.cfm">
</cfif>

<cfquery name="getSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore, s.divisionID
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND s.divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
  AND s.date >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#createDate(year(now()), month(now()), day(now()))#">
  ORDER BY WEEK, date, startTime
</cfquery>

<!--- All active teams this season across every division, plus any team already referenced by this
      division's schedule (even if Inactive/stale) so editing an existing row never loses its current
      team. Grouped by division so the edit modal can offer non-conference opponents. --->
<cfquery name="getAllTeams" datasource="roundleague">
  SELECT DISTINCT teamID, teamName, divisionID, divisionName FROM (
    SELECT t.teamID, t.teamName, d.DivisionID AS divisionID, d.DivisionName AS divisionName
    FROM teams t
    JOIN Divisions d ON d.DivisionID = t.divisionID
    WHERE t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND t.status = 'Active'

    UNION

    SELECT t.teamID, t.teamName, d.DivisionID AS divisionID, d.DivisionName AS divisionName
    FROM teams t
    JOIN schedule s ON (s.homeTeamID = t.teamID OR s.awayTeamID = t.teamID)
    JOIN Divisions d ON d.DivisionID = t.divisionID
    WHERE s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND s.divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
  ) combinedTeams
  ORDER BY divisionID, teamName
</cfquery>

<!--- Season-wide (all divisions) upcoming schedule, used client-side to detect a team already
      booked elsewhere that week -- now that non-conference games are possible, that booking
      may live in a different division than the one currently being viewed. --->
<cfquery name="getSeasonSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND s.date >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#createDate(year(now()), month(now()), day(now()))#">
  ORDER BY WEEK, date, startTime
</cfquery>

<cfset scheduleDataForJS = []>
<cfloop query="getSeasonSchedule">
  <cfset timeLbl = (len(DateTimeFormat(getSeasonSchedule.startTime, "h:nn tt")) GT 0) ? DateTimeFormat(getSeasonSchedule.startTime, "h:nn tt") : "BYE">
  <cfset awayLbl = (timeLbl EQ "BYE") ? "BYE" : getSeasonSchedule.Away>
  <cfset arrayAppend(scheduleDataForJS, {
    "scheduleID": getSeasonSchedule.scheduleID,
    "week": getSeasonSchedule.week,
    "homeTeamID": getSeasonSchedule.homeTeamID,
    "homeName": getSeasonSchedule.Home,
    "awayTeamID": getSeasonSchedule.awayTeamID,
    "awayName": awayLbl,
    "dateLabel": DateFormat(getSeasonSchedule.date, "mm/dd"),
    "timeLabel": timeLbl
  })>
</cfloop>

<cfoutput>
<script>var scheduleData = #serializeJSON(scheduleDataForJS)#;</script>
<div class="content">
    <div class="col-md-12">
      <h3 class="description">Scheduler</h3>
      
      <div class="scheduler-controls">
        <form method="POST" class="division-form">
          <label for="DivisionID">Division</label>
          <select name="DivisionID" id="Divisions" onchange="this.form.submit()">
              <cfloop query="getDivisions">
                  <option value="#getDivisions.DivisionID#"<cfif getDivisions.DivisionID EQ form.DivisionID> selected</cfif>>#getDivisions.DivisionName#</option>
              </cfloop>
          </select>
        </form>
        
        <a href="/admin-dashboard/pages/scheduler/scheduleImport.cfm" class="btn btn-outline-primary btn-round">Import Schedule</a>
      </div>

      <cfif len(toastMsg)>
        <div class="alert #toastClass#">#toastMsg#</div>
      </cfif>

      <!--- Display schedule based on selected division --->
      <table id="myTable" class="grid pure-table pure-table-horizontal bolder">
          <thead>
              <tr>
                  <th>Home</th>
                  <th>Away</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th></th>
              </tr>
          </thead>
          <tbody>
              <cfset currentWeek = 1>
              <cfloop query="getSchedule">

                <cfif homeScore GT awayScore>
                  <cfset homeBoldClass = 'boldClass'>
                  <cfset awayBoldClass = ''>
                <cfelseif awayScore GT homeScore>
                  <cfset homeBoldClass = ''>
                  <cfset awayBoldClass = 'boldClass'>
                <cfelse>
                  <cfset homeBoldClass = ''>
                  <cfset awayBoldClass = ''>
                </cfif>

                <cfif currentWeek NEQ getSchedule.week OR getSchedule.currentRow EQ 1>
                  <cfset currentWeek = getSchedule.week>
                  <tr class="weekRow" id="week_#currentWeek#">
                    <td colspan="5">Week #currentWeek#</td>
                  </tr>
                </cfif>

                <cfif len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) GT 0>
                  <cfset timeLabel = DateTimeFormat(getSchedule.startTime, "h:nn tt")>
                  <cfset awayLabel = getSchedule.Away>
                <cfelse>
                  <cfset timeLabel = "BYE">
                  <cfset awayLabel = "BYE">
                </cfif>
                <cfset gameLabel = "Week " & getSchedule.week & " - " & getSchedule.Home & " vs " & awayLabel & " - " & DateFormat(getSchedule.date, "mm/dd") & " " & timeLabel>

                  <tr>

                    <cfif getSchedule.homeScore NEQ ''>
                      <td data-label="Home"><a class="#homeBoldClass#" href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">#getSchedule.Home# #getSchedule.HomeScore#</a></td>
                    <cfelse>
                      <td data-label="Home">#getSchedule.Home#</td>
                    </cfif>

                    <cfif getSchedule.AwayScore NEQ ''>
                      <td data-label="Away"><a class="#awayBoldClass#" href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">#getSchedule.Away# #getSchedule.AwayScore#</a></td>
                    <cfelse>
                      <td data-label="Away">
                      #(len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) GT 0) ? evaluate('getSchedule.Away') : 'BYE'#
                      </td>
                    </cfif>
                    
                    <td data-label="Date">
                      #DateFormat(getSchedule.Date, "mm/dd/yyyy")#
                    </td>
                    <td data-label="Time">
                      #(len(DateTimeFormat(getSchedule.startTime, "h:nn tt")) GT 0) ? DateTimeFormat(getSchedule.startTime, "h:nn tt") : 'BYE'#
                    </td>
                    <td data-label="Edit">
                      <button type="button" class="btn btn-sm btn-link editGameBtn" data-toggle="modal" data-target="##editGameModal"
                        data-scheduleid="#getSchedule.scheduleID#"
                        data-week="#getSchedule.week#"
                        data-hometeamid="#getSchedule.homeTeamID#"
                        data-awayteamid="#getSchedule.awayTeamID#"
                        data-date="#DateFormat(getSchedule.date, 'yyyy-mm-dd')#"
                        data-time="#(isDate(getSchedule.startTime)) ? TimeFormat(getSchedule.startTime, 'HH:mm') : ''#"
                        data-label="#htmlEditFormat(gameLabel)#"
                        data-home-name="#htmlEditFormat(getSchedule.Home)#"
                        data-away-name="#htmlEditFormat(awayLabel)#">
                        Edit
                      </button>
                    </td>
                  </tr>
              </cfloop>
          </tbody>
      </table>

      <cfif getSchedule.recordCount EQ 0>
        <p class="no-schedule-msg">No games scheduled for this division yet. <a href="/admin-dashboard/pages/scheduler/scheduleImport.cfm">Import a schedule</a> to get started.</p>
      </cfif>
    </div>
</div>

<!--- Edit Game Modal --->
<div class="modal fade" id="editGameModal" tabindex="-1" role="dialog" aria-labelledby="editGameModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <form method="POST" action="/admin-dashboard/pages/scheduler/scheduler.cfm">
        <div class="modal-header">
          <h5 class="modal-title" id="editGameModalLabel">Edit Game</h5>
        </div>
        <div class="modal-body">
          <input type="hidden" name="DivisionID" value="#form.divisionID#">
          <input type="hidden" name="editScheduleID" id="editScheduleID" value="">
          <input type="hidden" name="swapScheduleID" id="swapScheduleID" value="">
          <input type="hidden" name="swapSide" id="swapSide" value="">
          <input type="hidden" name="swapOriginalTeamID" id="swapOriginalTeamID" value="">

          <div class="form-group">
            <label for="editHomeTeamID">Home Team</label>
            <select name="editHomeTeamID" id="editHomeTeamID" class="form-control">
              <cfset lastDivisionID = "">
              <cfloop query="getAllTeams">
                <cfif getAllTeams.divisionID NEQ lastDivisionID>
                  <cfif lastDivisionID NEQ "">
                    </optgroup>
                  </cfif>
                  <optgroup label="#getAllTeams.divisionName#">
                  <cfset lastDivisionID = getAllTeams.divisionID>
                </cfif>
                <option value="#getAllTeams.teamID#">#getAllTeams.teamName#</option>
              </cfloop>
              <cfif lastDivisionID NEQ "">
                </optgroup>
              </cfif>
            </select>
          </div>
          <div class="form-group">
            <label for="editAwayTeamID">Away Team</label>
            <select name="editAwayTeamID" id="editAwayTeamID" class="form-control">
              <cfset lastDivisionID = "">
              <cfloop query="getAllTeams">
                <cfif getAllTeams.divisionID NEQ lastDivisionID>
                  <cfif lastDivisionID NEQ "">
                    </optgroup>
                  </cfif>
                  <optgroup label="#getAllTeams.divisionName#">
                  <cfset lastDivisionID = getAllTeams.divisionID>
                </cfif>
                <option value="#getAllTeams.teamID#">#getAllTeams.teamName#</option>
              </cfloop>
              <cfif lastDivisionID NEQ "">
                </optgroup>
              </cfif>
            </select>
          </div>
          <div class="form-group">
            <label for="editDate">Date</label>
            <input type="date" name="editDate" id="editDate" class="form-control" required>
          </div>
          <div class="form-group">
            <label for="editTime">Time</label>
            <input type="time" name="editTime" id="editTime" class="form-control" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!--- Swap Confirmation Modal: shown when the newly selected team is already scheduled elsewhere this week --->
<div class="modal fade" id="swapConfirmModal" tabindex="-1" role="dialog" aria-labelledby="swapConfirmModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="swapConfirmModalLabel">Team Already Scheduled</h5>
      </div>
      <div class="modal-body">
        <p id="swapConfirmIntro"></p>
        <p>After the swap:</p>
        <ul id="swapConfirmPreview"></ul>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="cancelSwapBtn"></button>
        <button type="button" class="btn btn-primary" id="confirmSwapBtn">Swap Teams</button>
      </div>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/scheduler/scheduler.js?v=1.8"></script>