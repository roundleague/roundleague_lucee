
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<link href="../scheduler/scheduler.css?v=1.1" rel="stylesheet">

<!--- Save Logic --->
<cfif isDefined("form.updateTeamsDivision")>
  <cfinclude template="updateTeamsDivision.cfm">
</cfif>

<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>
<cfparam name="form.divisionID" default="#getDivisions.divisionID#">

<cfquery name="getSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore, s.divisionID
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND s.divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
  ORDER BY WEEK, date, startTime
</cfquery>

<!--- Get all active teams for drop down --->
<cfquery name="getAllActiveTeams" datasource="roundleague">
  SELECT teamName, teamID
  FROM teams
  WHERE status = 'Active'
  AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  ORDER BY teamName
</cfquery>

<!--- Teams in division --->
<cfquery name="getTeamsInDivision" datasource="roundleague">
  SELECT teamName, teamID
  FROM teams
  WHERE divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
  ORDER BY teamName
</cfquery>

<cfoutput>
<!-- End Navbar -->
<div class="content">
    <div class="col-md-12">
      <h3 class="description">Scheduler</h3>
      <form method="POST">

        <label for="DivisionID">Division</label>
        <select name="DivisionID" id="Divisions" onchange="this.form.submit()">
          <cfloop query="getDivisions">
            <option value="#getDivisions.DivisionID#"<cfif getDivisions.DivisionID EQ form.DivisionID> selected</cfif>>#getDivisions.DivisionName#</option>
          </cfloop>
        </select>
        <br>
          <table id="myTable" class="grid pure-table pure-table-horizontal bolder" style="width: 33%">
              <thead>
                  <tr>
                      <th>Team</th>
                  </tr>
              </thead>
              <tbody>
                <cfloop query="getTeamsInDivision">
                   <tr>
                      <td>
                        <select class="teamID" name="teamID" style="padding: 7px;">
                          <cfloop query="getAllActiveTeams">
                            <option data-value="#getAllActiveTeams.TeamID#" value="#getAllActiveTeams.TeamID#"<cfif getAllActiveTeams.teamID EQ getTeamsInDivision.teamID>selected</cfif>>#getAllActiveTeams.TeamName#</option>
                          </cfloop>
                        </select>
                      </td>
                   </tr>
                <input type="hidden" name="teamID_#getTeamsInDivision.currentRow#" class="teamID_#getTeamsInDivision.currentRow#" value="#getTeamsInDivision.TeamID#">
                </cfloop>
              </tbody>
          </table>
        <br>
        <button type="submit" class="btn btn-wd btn-info btn-round saveBtn" name="updateTeamsDivision">Update Teams in Division</button>
        <br>
        <br>
        <!--- Toggle for replace all or single update --->
        <label>
          Update All (If toggled, changing a team will replace all instances of that team)
          <input type="checkbox" data-toggle="switch" checked="" data-on-color="primary" data-off-color="primary">
          <span class="toggle"></span>
        </label>

        <!--- Display schedule based on selected division --->
        <table id="myTable" class="grid pure-table pure-table-horizontal bolder" style="width: 80%">
            <thead>
                <tr>
                    <th>Home</th>
                    <th>Away</th>
                    <th>Date</th>
                    <th>Time</th>
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
                      <td colspan="4">Week #currentWeek#</td>
                    </tr>
                  </cfif>
                    <tr>

                      <cfif getSchedule.homeScore NEQ ''>
                        <td data-label="Home"><a class="#homeBoldClass#" href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">#getSchedule.Home# #getSchedule.HomeScore#</a></td>
                      <cfelse>
                        <td data-label="Home">#getSchedule.Home#</td>
                      </cfif>

                      <cfif getSchedule.AwayScore NEQ ''>
                        <td data-label="Away"><a class="#awayBoldClass#" href="/pages/boxscore/boxscore.cfm?scheduleID=#getSchedule.scheduleID#">#getSchedule.Away# #getSchedule.AwayScore#</a></td>
                      <cfelse>
                        <!--- Extra logic for away; if schedule includes a BYE --->
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
                    </tr>
                </cfloop>
            </tbody>
        </table>
        <input type="hidden" name="updateDivisionID" value="#getSchedule.divisionID#" />
      </form>
    </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/scheduler/scheduler.js"></script>