<cfoutput>

     <cffunction name="getAdvanceToGameId"
        hint="Get the next bracketGameId to advance to for playoffs" returntype="number">
        <cfargument name="fromGameId" default="" required="yes" type="number">
        <cfargument name="numRounds" default="" required="yes" type="number">

        <cfif numRounds EQ 5>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1,2"><cfreturn 17></cfcase>
                <cfcase value="3,4"><cfreturn 18></cfcase>
                <cfcase value="5,6"><cfreturn 19></cfcase>
                <cfcase value="7,8"><cfreturn 20></cfcase>
                <cfcase value="9,10"><cfreturn 21></cfcase>
                <cfcase value="11,12"><cfreturn 22></cfcase>
                <cfcase value="13,14"><cfreturn 23></cfcase>
                <cfcase value="15,16"><cfreturn 24></cfcase>
                <cfcase value="17,18"><cfreturn 25></cfcase>
                <cfcase value="19,20"><cfreturn 26></cfcase>
                <cfcase value="21,22"><cfreturn 27></cfcase>
                <cfcase value="23,24"><cfreturn 28></cfcase>
                <cfcase value="25,26"><cfreturn 29></cfcase>
                <cfcase value="27,28"><cfreturn 30></cfcase>
                <cfcase value="29,30"><cfreturn 31></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelseif numRounds EQ 3>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1,2"><cfreturn 5></cfcase>
                <cfcase value="3,4"><cfreturn 6></cfcase>
                <cfcase value="5,6"><cfreturn 7></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelse>
            <cfreturn 0>
        </cfif>
            
     </cffunction>

    <cftry>
    <!--- Get the max rounds for current bracket --->
    <cfquery name="getMaxRounds" datasource="roundleague">
        SELECT max(bracketRoundID) as MaxRounds
        FROM playoffs_schedule
        WHERE Playoffs_BracketID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.Playoffs_BracketID#">
    </cfquery>

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
        <cfset nextGameId = getAdvanceToGameId(url.bracketGameID, getMaxRounds.maxRounds)>
        <cfquery name="advanceSchedule" datasource="roundleague">
            SELECT Playoffs_scheduleID, HomeTeamID, AwayTeamID
            FROM Playoffs_Schedule
            WHERE Playoffs_BracketID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.Playoffs_BracketID#">
            AND BracketGameID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#nextGameId#">
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