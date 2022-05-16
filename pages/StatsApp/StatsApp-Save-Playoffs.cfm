<cfoutput>
    <cftry>
    <!--- Get the active seasonID --->
    <cfquery name="getActiveSeasonID" datasource="roundleague">
        SELECT SeasonID
        FROM Seasons
        WHERE Status = 'Active'
    </cfquery>
    <cfset playerIDList = form.playerIDList>

    <cfloop list="#playerIDList#" index="count" item="i">
        <cfif form["FGA_" & i] EQ 0 AND form["PTS_" & i] EQ 0 AND form["REBS_" & i] EQ 0 AND form["ASTS_" & i] EQ 0 AND form["STLS_" & i] EQ 0 AND form["BLKS_" & i] EQ 0 AND form["FOULS_" & i] EQ 0>
            <!--- Do not insert into player game log - DNP --->
        <cfelse>
            <cfquery name="dupGameLogCheck" datasource="roundleague">
                SELECT playerID
                FROM Playoffs_PlayerGameLog
                Where Playoffs_ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
                AND playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
            </cfquery>
            <cfif dupGameLogCheck.recordCount EQ 0>
                <cfquery name="savePlayerLogs" datasource="roundleague">
                        INSERT INTO Playoffs_PlayerGameLog (
                            PlayerID, 
                            FGM,
                            FGA,
                            3FGM,
                            3FGA,
                            FTM,
                            FTA,
                            Points,
                            Rebounds,
                            Assists,
                            Steals,
                            Blocks,
                            Turnovers,
                            SeasonID,
                            TeamID,
                            Playoffs_ScheduleID,
                            Fouls
                            )
                        VALUES
                             (
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">, 
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FGM_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FGA_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["3FGM_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["3FGA_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FTM_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FTA_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["PTS_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["REBS_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["ASTS_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["STLS_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["BLKS_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["TO_" & i]#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">,
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FOULS_" & i]#">
                            )
                </cfquery>
            </cfif>
        </cfif>
    </cfloop>

    <cfquery name="scoresExist" datasource="roundleague">
        SELECT homeScore
        From Playoffs_Schedule
        WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#"> 
    </cfquery>

    <!--- Scores / Standings have already been updated --->
    <cfif scoresExist.homeScore EQ ''>

        <cfquery name="updateScheduleScore" datasource="roundleague">
            UPDATE Playoffs_Schedule 
            SET 
                    homeScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.homeScore#">, 
                    awayScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.awayScore#">
            WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
        </cfquery>


        <!--- Advance Winning Team --->
        <cfset nextRound = url.bracketRoundID + 1>
        <cfquery name="advanceSchedule" datasource="roundleague">
            SELECT Playoffs_scheduleID, HomeTeamID, AwayTeamID
            FROM Playoffs_Schedule
            WHERE Playoffs_BracketID = 1 <!--- Fix later --->
            AND bracketRoundID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#nextRound#">
            AND (homeTeamID IS NULL OR awayTeamID IS NULL)
            LIMIT 1
        </cfquery>

        <cfif advanceSchedule.recordCount NEQ 0>
            <!--- If this is not the championship game --->
            <cfif advanceSchedule.homeTeamID EQ ''>
                <cfset updateTeamCol = 'HomeTeamID'>
            <cfelse>
                <cfset updateTeamCol = 'AwayTeamID'>
            </cfif>

            <cfif form.homeScore GT form.awayScore>
                <!--- Advance Home Team --->
                <cfquery name="advanceTeam" datasource="roundleague">
                    UPDATE Playoffs_Schedule
                    SET #updateTeamCol# = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">
                    WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#advanceSchedule.Playoffs_scheduleID#">
                </cfquery>
            <cfelse>
                <!--- Advance Away Team --->
                <cfquery name="advanceTeam" datasource="roundleague">
                    UPDATE Playoffs_Schedule
                    SET #updateTeamCol# = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">
                    WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#advanceSchedule.Playoffs_scheduleID#">
                </cfquery>
            </cfif>
        <cfelse>
            <!--- Championship Game --->
        </cfif>
    </cfif>

        <cflocation url="StatsApp-Select.cfm?saved=true">

    <cfcatch><cfdump var="#cfcatch#" /></cfcatch>
    </cftry>
</cfoutput>