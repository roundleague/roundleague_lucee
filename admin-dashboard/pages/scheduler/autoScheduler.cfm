<cffunction name="generateRoundRobinSchedule" access="public" returntype="void">
    <cfargument name="numberOfWeeks" type="numeric" required="yes">
    <cfargument name="startDate" type="date" required="yes">
    <cfargument name="startTime" type="string" required="yes">
    <cfargument name="preferredStartTimes" type="struct" required="yes">
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
    
    <!--- Create a list of team IDs --->
    <cfset teamList = []>
    <cfloop query="getAllActiveTeams">
        <cfset arrayAppend(teamList, {teamID: teamID, teamName: teamName})>
    </cfloop>
    
    <!--- If the number of teams is odd, add a "Bye" --->
    <cfif numTeams mod 2 neq 0>
        <cfset arrayAppend(teamList, {teamID: 0, teamName: "Bye"})>
        <cfset numTeams = numTeams + 1>
    </cfif>

    <!--- Generate round robin schedule --->
    <cfloop from="1" to="#arguments.numberOfWeeks#" index="i">
        <cfif dateCompare(currentDate, skipDate) EQ 0>
            <cfset currentDate = dateAdd("d", 7, currentDate)>
        </cfif>
        
        <!--- Initialize the start time for the first game of the week --->
        <cfset gameTime = createDateTime(year(currentDate), month(currentDate), day(currentDate), listFirst(arguments.startTime, ":"), listLast(arguments.startTime, ":"), 0)>
        
        <!--- Create a list of games for the week --->
        <cfset weeklyGames = []>
        <cfloop from="1" to="#numTeams / 2#" index="match">
            <cfset homeTeam = teamList[match]>
            <cfset awayTeam = teamList[numTeams - match + 1]>
            <cfif homeTeam.teamID neq 0 and awayTeam.teamID neq 0>
                <cfset arrayAppend(weeklyGames, {
                    homeTeamID: homeTeam.teamID,
                    awayTeamID: awayTeam.teamID
                })>
            </cfif>
        </cfloop>

        <!--- Slot teams with preferred start times first --->
        <cfset gameTime = createDateTime(year(currentDate), month(currentDate), day(currentDate), listFirst(arguments.startTime, ":"), listLast(arguments.startTime, ":"), 0)>
        <cfset usedTeams = []>
        <cfloop list="#structKeyList(arguments.preferredStartTimes)#" index="teamID">
            <cfif arguments.preferredStartTimes[teamID] neq "" and arguments.preferredStartTimes[teamID] neq arguments.startTime>
                <cfset homeStartTime = arguments.preferredStartTimes[teamID]>
                <cfset homeStartHour = listFirst(homeStartTime, ":")>
                <cfset homeStartMinute = listLast(homeStartTime, ":")>
                <cfset preferredGameTime = createDateTime(year(currentDate), month(currentDate), day(currentDate), homeStartHour, homeStartMinute, 0)>
                
                <!--- Find the matching game and assign the preferred time --->
                <cfloop array="#weeklyGames#" index="game" item="weeklyGame">
                    <cfif (weeklyGame.homeTeamID EQ teamID OR weeklyGame.awayTeamID EQ teamID) AND NOT (arrayContains(usedTeams, weeklyGame.homeTeamID) OR arrayContains(usedTeams, weeklyGame.awayTeamID))>
                        <cfset arrayAppend(schedule, {
                            homeTeamID: weeklyGame.homeTeamID,
                            awayTeamID: weeklyGame.awayTeamID,
                            week: week,
                            startTime: timeFormat(preferredGameTime, "HH:mm:ss"),
                            date: dateFormat(currentDate, "yyyy-mm-dd"),
                            divisionID: arguments.divisionID,
                            seasonID: session.currentSeasonID
                        })>
                        <cfset arrayAppend(usedTeams, weeklyGame.homeTeamID)>
                        <cfset arrayAppend(usedTeams, weeklyGame.awayTeamID)>
                        <cfset arrayDeleteAt(weeklyGames, arrayIndex(weeklyGames, weeklyGame))>
                        <cfbreak>
                    </cfif>
                </cfloop>
            </cfif>
        </cfloop>

        <!--- Assign the remaining games --->
        <cfloop array="#weeklyGames#" index="weeklyGame">
            <cfif NOT (arrayContains(usedTeams, weeklyGame.homeTeamID) OR arrayContains(usedTeams, weeklyGame.awayTeamID))>
                <cfset arrayAppend(schedule, {
                    homeTeamID: weeklyGame.homeTeamID,
                    awayTeamID: weeklyGame.awayTeamID,
                    week: week,
                    startTime: timeFormat(gameTime, "HH:mm:ss"),
                    date: dateFormat(currentDate, "yyyy-mm-dd"),
                    divisionID: arguments.divisionID,
                    seasonID: session.currentSeasonID
                })>
                <cfset gameTime = dateAdd("n", 65, gameTime)>
            </cfif>
        </cfloop>
        
        <!--- Rotate teams except the first one --->
        <cfset temp = teamList[2]>
        <cfloop from="2" to="#numTeams - 1#" index="j">
            <cfset teamList[j] = teamList[j + 1]>
        </cfloop>
        <cfset teamList[numTeams] = temp>

        <cfset currentDate = dateAdd("d", 7, currentDate)>
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
