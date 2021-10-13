<cfinclude template="/header_wix.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="https://unpkg.com/purecss@2.0.6/build/pure-min.css" integrity="sha384-Uu6IeWbM+gzNVXJcM9XV3SohHtmWE+3VGi496jvgX1jyvDTXfdK+rfZc8C1Aehk5" crossorigin="anonymous">
<!--- Scripts --->
<script src="/pages/Schedule/schedule-2.js"></script>

<style>
a, td {
  font-weight: 500;
}

.boldClass{
  font-weight: bold;
}
</style>

<cfquery name="getSchedule" datasource="roundleague">
  SELECT scheduleID, WEEK, a.teamName AS Home, b.teamName AS Away, s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore
  FROM schedule s
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE s.seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  ORDER BY WEEK, date, startTime
</cfquery>

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center" style="padding-top: 20px">
      <div class="container">

        <input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search for teams.." title="Type in a team">
        <!--- Content Here --->
        <table id="myTable" class="grid pure-table pure-table-horizontal">
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
                    <tr class="weekRow">
                      <td colspan="4">Week #currentWeek#</td>
                    </tr>
                  </cfif>
                    <tr>

                      <cfset imgPath = "/boxscores/#getSchedule.homeTeamID#_#getSchedule.week#_#getSchedule.seasonID#.pdf">
                      <cfif FileExists("#imgPath#")>
                        <td><a class="#homeBoldClass#" href="#imgPath#" target="_blank">#getSchedule.Home# #getSchedule.HomeScore#</a></td>
                      <cfelse>
                        <td><span class="#homeBoldClass#">#getSchedule.Home# #getSchedule.HomeScore#</span></td>
                      </cfif>

                      <cfset awayImgPath = "/boxscores/#getSchedule.awayTeamID#_#getSchedule.week#_#getSchedule.seasonID#.pdf">
                      <cfif FileExists("#awayImgPath#")>
                        <td><a class="#awayBoldClass#" href="#awayImgPath#" target="_blank">#getSchedule.away# #getSchedule.awayScore#</a></td>
                      <cfelse>
                        <td><span class="#awayBoldClass#">#getSchedule.Away# #getSchedule.AwayScore#</span></td>
                      </cfif>
                      
                      <td>#DateFormat(getSchedule.Date, "mm/dd/yyyy")#</td>
                      <td>#DateTimeFormat(getSchedule.startTime, "h:nn")# PM</td>
                    </tr>
                </cfloop>
            </tbody>
        </table>

      </div>
    </div>
</div>
</cfoutput>

<cfinclude template="/footer_wix.cfm">
