<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<!--- Scripts --->
<script src="/pages/Schedule/schedule-2.js"></script>
<link href="../Schedule/schedule-2.css?v=1.1" rel="stylesheet">

<cfquery name="getSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  JOIN divisions d ON s.DivisionID = d.divisionID
  JOIN leagues l ON l.leagueID = d.leagueID
  WHERE s.seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  AND l.leagueName LIKE '%Asian%'
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
  <div class="main" style="background-color: white; margin-top: 25px;">
      <div class="section text-center">
        <!--- Mobile Only --->
        <div class="jumpToBottom bottomSpacing">
            <a href="##week_#getLatestWeek.latestWeek#">Jump to latest week</a><br>
        </div>
        <div class="container">
          <input type="text" class="bottomSpacing" id="myInput" onkeyup="myFunction()" placeholder="Search for teams.." title="Type in a team">
          <!--- Content Here --->
          <table id="myTable" class="grid pure-table pure-table-horizontal bolder">
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
        </div>
      </div>
  </div>
</cfoutput>

<cfinclude template="/footer.cfm">
