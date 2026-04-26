<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Handle POST actions --->
<cfif isDefined("form.action") AND form.action EQ "create">

    <!--- Get a DivisionID from an existing real team in this season --->
    <cfquery name="getDivision" datasource="roundleague">
        SELECT TOP 1 DivisionID FROM teams
        WHERE SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND Status != 'Test'
        AND DivisionID IS NOT NULL
    </cfquery>
    <cfset divID = getDivision.DivisionID>

    <!--- Insert Team A --->
    <cfquery name="insertTeamA" datasource="roundleague" result="teamAResult">
        INSERT INTO teams (Status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID)
        VALUES ('Test', 'TEST TEAM A', 0, NOW(), <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divID#">, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">)
    </cfquery>
    <cfset teamAID = teamAResult.GENERATED_KEY>

    <!--- Insert Team B --->
    <cfquery name="insertTeamB" datasource="roundleague" result="teamBResult">
        INSERT INTO teams (Status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID)
        VALUES ('Test', 'TEST TEAM B', 0, NOW(), <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divID#">, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">)
    </cfquery>
    <cfset teamBID = teamBResult.GENERATED_KEY>

    <!--- Insert 6 players for Team A --->
    <cfset teamAPlayerIDs = []>
    <cfloop from="1" to="6" index="i">
        <cfquery name="insertPlayer" datasource="roundleague" result="pResult">
            INSERT INTO players (firstName, lastName, RegisterDate, Status, Gender)
            VALUES (
                'Test',
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Player A#i#">,
                NOW(), 'Test', 'Male'
            )
        </cfquery>
        <cfset arrayAppend(teamAPlayerIDs, pResult.GENERATED_KEY)>
    </cfloop>

    <!--- Insert 6 players for Team B --->
    <cfset teamBPlayerIDs = []>
    <cfloop from="1" to="6" index="i">
        <cfquery name="insertPlayer" datasource="roundleague" result="pResult">
            INSERT INTO players (firstName, lastName, RegisterDate, Status, Gender)
            VALUES (
                'Test',
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Player B#i#">,
                NOW(), 'Test', 'Male'
            )
        </cfquery>
        <cfset arrayAppend(teamBPlayerIDs, pResult.GENERATED_KEY)>
    </cfloop>

    <!--- Insert roster entries for Team A --->
    <cfloop from="1" to="6" index="i">
        <cfquery datasource="roundleague">
            INSERT INTO roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey, Starter)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamAPlayerIDs[i]#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamAID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                1
            )
        </cfquery>
    </cfloop>

    <!--- Insert roster entries for Team B --->
    <cfloop from="1" to="6" index="i">
        <cfquery datasource="roundleague">
            INSERT INTO roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey, Starter)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamBPlayerIDs[i]#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamBID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                1
            )
        </cfquery>
    </cfloop>

    <!--- Insert test schedule row --->
    <cfquery datasource="roundleague" result="schedResult">
        INSERT INTO schedule (HomeTeamID, AwayTeamID, Week, StartTime, Date, DivisionID, SeasonID, status, clock_status, clock_remaining_seconds, clock_period)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamAID#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamBID#">,
            99,
            '18:00:00',
            NOW(),
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#divID#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
            'scheduled', 'stopped', 1500, 1
        )
    </cfquery>

    <cflocation url="/admin-dashboard/pages/testGame/index.cfm" addtoken="false">

<cfelseif isDefined("form.action") AND form.action EQ "cleanup">

    <!--- Delete in reverse-dependency order --->
    <cfquery datasource="roundleague">
        DELETE FROM schedule
        WHERE HomeTeamID IN (SELECT teamId FROM teams WHERE Status = 'Test' AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">)
        OR AwayTeamID IN (SELECT teamId FROM teams WHERE Status = 'Test' AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">)
    </cfquery>

    <cfquery datasource="roundleague">
        DELETE FROM roster
        WHERE TeamID IN (SELECT teamId FROM teams WHERE Status = 'Test' AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">)
    </cfquery>

    <cfquery datasource="roundleague">
        DELETE FROM players WHERE Status = 'Test'
    </cfquery>

    <cfquery datasource="roundleague">
        DELETE FROM teams
        WHERE Status = 'Test' AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    </cfquery>

    <cflocation url="/admin-dashboard/pages/testGame/index.cfm" addtoken="false">

</cfif>

<!--- Detect existing test data --->
<cfquery name="getTestTeams" datasource="roundleague">
    SELECT teamId, teamName FROM teams
    WHERE Status = 'Test' AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    ORDER BY teamId
</cfquery>

<cfset hasTestData = getTestTeams.recordCount EQ 2>

<cfif hasTestData>
    <cfset teamAID = getTestTeams.teamId[1]>
    <cfset teamBID = getTestTeams.teamId[2]>
    <cfquery name="getTestSchedule" datasource="roundleague">
        SELECT scheduleID FROM schedule
        WHERE HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamAID#">
        AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    </cfquery>
    <cfset testScheduleID = getTestSchedule.scheduleID>
</cfif>

<cfoutput>
<div class="content">
  <div class="row">
    <div class="col-md-8 col-md-offset-2">

      <cfif hasTestData>
        <div class="card">
          <div class="header">
            <h4 class="title">Test Game Active</h4>
            <p class="category">Season ID: #session.currentSeasonID# &nbsp;&bull;&nbsp; Schedule ID: <strong>#testScheduleID#</strong></p>
          </div>
          <div class="content">
            <table class="table">
              <tbody>
                <tr>
                  <td><strong>TEST TEAM A</strong> (ID: #teamAID#)</td>
                  <td>
                    <a href="/pages/StatsApp/StatsApp.cfm?teamID=#teamAID#&scheduleID=#testScheduleID#&isPlayoffs=0" target="_blank" class="btn btn-info btn-sm">Open StatsApp &nearr;</a>
                  </td>
                </tr>
                <tr>
                  <td><strong>TEST TEAM B</strong> (ID: #teamBID#)</td>
                  <td>
                    <a href="/pages/StatsApp/StatsApp.cfm?teamID=#teamBID#&scheduleID=#testScheduleID#&isPlayoffs=0" target="_blank" class="btn btn-info btn-sm">Open StatsApp &nearr;</a>
                  </td>
                </tr>
                <tr>
                  <td><strong>Scoreboard</strong></td>
                  <td>
                    <a href="/pages/scoreboard/scoreboard.cfm?game=#testScheduleID#&home=TEST+TEAM+A&away=TEST+TEAM+B" target="_blank" class="btn btn-success btn-sm">Open Scoreboard &nearr;</a>
                  </td>
                </tr>
              </tbody>
            </table>

            <form method="POST" style="margin-top:20px;">
              <input type="hidden" name="action" value="cleanup">
              <button type="submit" class="btn btn-danger"
                onclick="return confirm('Delete all test teams, players, roster entries, and the schedule row?')">
                Clean Up Test Records
              </button>
            </form>
          </div>
        </div>

      <cfelse>
        <div class="card">
          <div class="header">
            <h4 class="title">Test Game Setup</h4>
            <p class="category">Creates 2 test teams with 6 players each and a test schedule row in the current active season. None of this affects real standings or schedule views.</p>
          </div>
          <div class="content">
            <form method="POST">
              <input type="hidden" name="action" value="create">
              <button type="submit" class="btn btn-primary">Create Test Game</button>
            </form>
          </div>
        </div>
      </cfif>

    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
