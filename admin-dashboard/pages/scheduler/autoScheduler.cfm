<cffunction name="generateRoundRobinSchedule" access="public" returntype="void">
    <cfargument name="numberOfWeeks" type="numeric" required="yes">
    <cfargument name="gamesPerWeek" type="numeric" required="yes">
    <cfargument name="startDate" type="date" required="yes">
    <cfargument name="endDate" type="date" required="yes">
    <cfargument name="skipWeek" type="date" required="no" default="">
    <cfargument name="divisionID" type="numeric" required="yes">

    <!--- Get all active teams in the division --->
    <cfquery name="getAllActiveTeams" datasource="roundleague">
        SELECT teamID, teamName
        FROM teams
        WHERE status = 'Active'
        AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.divisionID#">
        ORDER BY teamName
    </cfquery>

    <!--- Initialize variables --->
    <cfset schedule = []>
    <cfset currentDate = createCustomDateTime(arguments.startDate)>
    <cfset skipDate = createCustomDateTime(arguments.skipWeek)>
    <cfset numTeams = getAllActiveTeams.recordCount>
    <cfset week = 1>
    <cfset gameTimeIncrement = createTimeSpan(0, 1, 5, 0)>

    <!--- Generate round robin schedule --->
    <cfloop from="1" to="#arguments.numberOfWeeks#" index="i">
        <cfif dateCompare(currentDate, skipDate) EQ 0>
            <cfset currentDate = dateAdd("d", 7, currentDate)>
        </cfif>
        <cfloop from="1" to="#arguments.gamesPerWeek#" index="j">
            <cfset gameTime = currentDate>
            <cfloop from="1" to="#numTeams#" index="homeIndex">
                <cfloop from="#homeIndex + 1#" to="#numTeams#" index="awayIndex">
                    <cfset arrayAppend(schedule, {
                        homeTeamID: getAllActiveTeams.teamID[homeIndex],
                        awayTeamID: getAllActiveTeams.teamID[awayIndex],
                        week: week,
                        startTime: timeFormat(gameTime, "HH:mm:ss"),
                        date: dateFormat(currentDate, "yyyy-mm-dd"),
                        divisionID: arguments.divisionID,
                        seasonID: session.currentSeasonID
                    })>
                    <cfset gameTime = dateAdd("n", 65, gameTime)>
                </cfloop>
            </cfloop>
            <cfset currentDate = dateAdd("d", 1, currentDate)>
        </cfloop>
        <cfset week = week + 1>
    </cfloop>

    <!--- Insert schedule into database --->
    <cfloop array="#schedule#" index="game">
        <cfquery datasource="roundleague">
            INSERT INTO schedule (HomeTeamID, AwayTeamID, Week, StartTime, Date, DivisionID, SeasonID)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.homeTeamID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.awayTeamID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.week#">,
                <cfqueryparam cfsqltype="CF_SQL_TIME" value="#game.startTime#">,
                <cfqueryparam cfsqltype="CF_SQL_DATE" value="#game.date#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.divisionID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.seasonID#">
            )
        </cfquery>
    </cfloop>
</cffunction>

<cffunction name="createCustomDateTime" access="private" returntype="date">
    <cfargument name="dateStr" type="string" required="yes">
    <cfset var dateParts = listToArray(arguments.dateStr, "-")>
    <cfreturn createDate(dateParts[1], dateParts[2], dateParts[3])>
</cffunction>

<cfset generateRoundRobinSchedule(
        form.numberOfWeeks,
        form.gamesPerWeek,
        form.startDate,
        form.endDate,
        form.skipWeek,
        form.divisionID
    )>