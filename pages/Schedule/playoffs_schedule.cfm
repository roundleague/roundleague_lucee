<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<!--- Scripts --->
<script src="/pages/Schedule/schedule-2.js"></script>
<link href="../Schedule/schedule-2.css?v=1.1" rel="stylesheet">

<cfquery name="getBrackets" datasource="roundleague">
  SELECT Playoffs_BracketID as BracketID, Name, SeasonID
  FROM Playoffs_Bracket
  Where SeasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  ORDER BY SortOrder
</cfquery>

<cfparam name="form.bracketID" default="#getBrackets.BracketID#">

<cfquery name="getSchedule" datasource="roundleague">
  SELECT s.Playoffs_ScheduleID, a.teamName AS Home, b.teamName AS Away,
  s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore, s.BracketGameID, s.BracketRoundID, pb.Name as BracketName, s.week,
  pb.BracketFormat, s.GameLabel
  FROM playoffs_schedule s
  JOIN playoffs_bracket pb ON pb.Playoffs_bracketID = s.Playoffs_BracketID
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE pb.seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  AND pb.Playoffs_BracketID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.bracketID#">
  ORDER BY WEEK, date, startTime
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 25px;">
  <form method="POST">
    <div class="section text-center">
      <div class="container">

        <!--- Select for Bracket Type --->
        <label for="BracketID">Bracket</label>
        <select name="BracketID" id="Brackets" onchange="this.form.submit()">
          <cfloop query="getBrackets">
            <option value="#getBrackets.BracketID#"<cfif getBrackets.BracketID EQ form.BracketID> selected</cfif>>#getBrackets.Name#</option>
          </cfloop>
        </select>

        <h1>#getSchedule.BracketName#</h1>

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

                  <!--- Double-elim brackets group by BracketGameID (every game gets its own header,
                        since a round-1 date span can hold many games all sharing the same Week) —
                        single-elim brackets keep grouping by Week, unchanged. --->
                  <cfset currentGroupValue = (getSchedule.BracketFormat EQ 'double_elim_7') ? getSchedule.BracketGameID : getSchedule.week>
                  <cfif currentWeek NEQ currentGroupValue OR getSchedule.currentRow EQ 1>
                    <cfset currentWeek = currentGroupValue>
                    <tr class="weekRow" id="week_#BracketRoundID#">
                      <cfif getSchedule.BracketFormat EQ 'double_elim_7'>
                        <td colspan="4">Game #getSchedule.BracketGameID#</td>
                      <cfelse>
                        <td colspan="4">Round #BracketRoundID#</td>
                      </cfif>
                    </tr>
                  </cfif>
                    <tr>

                      <cfif getSchedule.homeScore NEQ ''>
                        <td data-label="Home"><a class="#homeBoldClass#" href="/pages/boxscore/playoffs_boxscore.cfm?scheduleID=#getSchedule.playoffs_scheduleID#">#getSchedule.Home# #getSchedule.HomeScore#</a></td>
                      <cfelse>
                            <cfif evaluate("getSchedule.Home & getSchedule.HomeScore") neq "">
                              <td data-label="Home">#getSchedule.Home# #getSchedule.HomeScore#</td>
                            <cfelse>
                              <td data-label="Home">-</td>
                            </cfif>
                      </cfif>

                      <cfif getSchedule.AwayScore NEQ ''>
                        <td data-label="Away"><a class="#awayBoldClass#" href="/pages/boxscore/playoffs_boxscore.cfm?scheduleID=#getSchedule.playoffs_scheduleID#">#getSchedule.Away# #getSchedule.AwayScore#</a></td>
                      <cfelse>
                            <cfif evaluate("getSchedule.Away & getSchedule.AwayScore") neq "">
                              <td data-label="Away">#getSchedule.Away# #getSchedule.AwayScore#</td>
                            <cfelse>
                              <td data-label="Away">-</td>
                            </cfif>
                      </cfif>

                      <td data-label="Date">#DateFormat(getSchedule.Date, "mm/dd/yyyy")#</td>
                      <td data-label="Time">#DateTimeFormat(getSchedule.startTime, "h:nn tt")#</td>
                    </tr>
                    <cfif getSchedule.BracketFormat EQ 'double_elim_7' AND len(trim(getSchedule.GameLabel))>
                      <tr class="gameLabelRow">
                        <td colspan="4" style="font-style:italic; font-size:12px; color:##777; padding-top:0;">#getSchedule.GameLabel#</td>
                      </tr>
                    </cfif>
                </cfloop>
            </tbody>
        </table>
      </div>
    </div>
  </form>
</div>
</cfoutput>

<cfinclude template="/footer.cfm">
