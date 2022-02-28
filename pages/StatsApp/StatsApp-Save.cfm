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
                FROM PlayerGameLog
                Where ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
                AND playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
            </cfquery>
            <cfif dupGameLogCheck.recordCount EQ 0>
                <cfquery name="savePlayerLogs" datasource="roundleague">
                        INSERT INTO PlayerGameLog (
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
                            ScheduleID,
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
        From Schedule
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#"> 
    </cfquery>

    <!--- Scores / Standings have already been updated --->
    <cfif scoresExist.homeScore EQ ''>

        <cfquery name="updateScheduleScore" datasource="roundleague">
            UPDATE schedule 
            SET 
                    homeScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.homeScore#">, 
                    awayScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.awayScore#">
            WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
        </cfquery>

        <!--- Point Differential --->
        <cfset HomeDifference = homeScore - awayScore>
        <cfset AwayDifference = awayScore - homeScore>

        <!--- home team section --->
        <cfquery name="checkHomeStandings" datasource="roundleague">
            SELECT teamID
            FROM standings
            WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">
            AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.seasonID#">
        </cfquery>
        <cfif checkHomeStandings.recordCount>
            <cfquery name="updateStandings" datasource="roundleague">
                UPDATE Standings
                SET <cfif form.homeScore GT form.awayScore>WINS<cfelse>LOSSES</cfif> = <cfif form.homeScore GT form.awayScore>WINS<cfelse>LOSSES</cfif> + 1,
                    PointDifferential = PointDifferential + #HomeDifference#
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">
            </cfquery>
        <cfelse>
            <cfquery name="insertStandings" datasource="roundleague">
                INSERT INTO Standings (TeamID, Wins, Losses, SeasonID, DivisionID, PointDifferential)
                VALUES 
                (
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">,
                    <cfif form.homeScore GT form.awayScore>1<cfelse>0</cfif>,
                    <cfif form.homeScore LT form.awayScore>1<cfelse>0</cfif>,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.SeasonID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.DivisionID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HomeDifference#">
                )
            </cfquery>
        </cfif>

        <!--- away team section --->
        <cfquery name="checkAwayStandings" datasource="roundleague">
            SELECT teamID
            FROM standings
            WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.AwayTeamID#">
            AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.seasonID#">
        </cfquery>
        <cfif checkAwayStandings.recordCount>
            <cfquery name="updateStandings" datasource="roundleague">
                UPDATE Standings
                SET <cfif form.awayScore GT form.homeScore>WINS<cfelse>LOSSES</cfif> = <cfif form.awayScore GT form.homeScore>WINS<cfelse>LOSSES</cfif> + 1,
                    PointDifferential = PointDifferential + #AwayDifference#
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">
            </cfquery>
        <cfelse>
            <cfquery name="insertStandings" datasource="roundleague">
                INSERT INTO Standings (TeamID, Wins, Losses, SeasonID, DivisionID, PointDifferential)
                VALUES 
                (
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">,
                    <cfif form.awayScore GT form.homeScore>1<cfelse>0</cfif>,
                    <cfif form.awayScore LT form.homeScore>1<cfelse>0</cfif>,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.SeasonID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.DivisionID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#AwayDifference#">
                )
            </cfquery>
        </cfif>

    </cfif>

        <cfloop list="#playerIDList#" index="i">
            <cfif form["FGA_" & i] EQ 0 AND form["PTS_" & i] EQ 0 AND form["REBS_" & i] EQ 0 AND form["ASTS_" & i] EQ 0 AND form["STLS_" & i] EQ 0 AND form["BLKS_" & i] EQ 0 AND form["FOULS_" & i] EQ 0>
                <!--- Do not insert/update into player stats - DNP --->
            <cfelse>
                <cfquery name="checkExistingPlayerStats" datasource="roundleague">
                    SELECT playerID
                    FROM PlayerStats
                    Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                    AND PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
                </cfquery>
                <cfif checkExistingPlayerStats.recordCount>
                    <!--- <cfquery name="updateStats" datasource="roundleague" result="updateResult">
                        UPDATE playerStats
                        SET 
                            Points = (SELECT CAST(AVG(POINTS) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            Rebounds = (SELECT CAST(AVG(Rebounds) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            Assists = (SELECT CAST(AVG(Assists) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            Steals = (SELECT CAST(AVG(Steals) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            Blocks = (SELECT CAST(AVG(Blocks) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            Turnovers = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            FGM = (SELECT CAST(AVG(FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            FGA = (SELECT CAST(AVG(FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            3FGM = (SELECT CAST(AVG(3FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            3FGA = (SELECT CAST(AVG(3FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            FTM = (SELECT CAST(AVG(FTM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            FTA = (SELECT CAST(AVG(FTA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #getActiveSeasonID.seasonID#),
                            GamesPlayed = GamesPlayed + 1
                        WHERE playerID = #i#
                        AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                    </cfquery> --->
                <cfelse>
                    <cfquery name="savePlayerLogs" datasource="roundleague">
                            INSERT INTO PlayerStats (
                                PlayerID,
                                Points,
                                Rebounds,
                                Assists,
                                Steals,
                                Blocks,
                                Turnovers,
                                SeasonID,
                                TeamID,
                                FGM,
                                FGA,
                                3FGM,
                                3FGA,
                                FTM,
                                FTA,
                                GamesPlayed
                                )
                            VALUES
                                 (
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">, 
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["PTS_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["REBS_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["ASTS_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["STLS_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["BLKS_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["TO_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FGM_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FGA_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["3FGM_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["3FGA_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FTM_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["FTA_" & i]#">,
                                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">
                                )
                    </cfquery>
                    </cfif>

                </cfif>
                <!--- Update jerseys each time (we could optimize later on and check) --->
                <cfquery name="jerseyUpdates" datasource="roundleague">
                    UPDATE ROSTER
                    SET Jersey = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["Jersey_" & i]#">
                    WHERE playerID = #i#
                    AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                </cfquery>
        </cfloop>

        <!--- 2/24/2022 Update for Mens's Playoffs; remove this later --->
        <!--- 3's to the Dome vs HiiPower Plays Cartel --->
        <cfif url.scheduleID EQ 256>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>20<cfelse>27</cfif>
                WHERE scheduleID = 267
            </cfquery>
        </cfif>
        <!--- Rose City Kings vs Gots to See It Thru Plays Oregon ABC --->
        <cfif url.scheduleID EQ 257>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>23<cfelse>41</cfif>
                WHERE scheduleID = 266
            </cfquery>
        </cfif>
        <!--- Local Grown vs Smokin' 3's Plays Goodfellas --->
        <cfif url.scheduleID EQ 258>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>15<cfelse>10</cfif>
                WHERE scheduleID = 269
            </cfquery>
        </cfif>
        <!--- Mobb Deep vs Jayhawks Plays PDX Ballerz --->
        <cfif url.scheduleID EQ 259>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>2<cfelse>28</cfif>
                WHERE scheduleID = 268
            </cfquery>
        </cfif>
        <!--- Aces vs Kareem Cheese Plays CrossinOver Toddlers --->
        <cfif url.scheduleID EQ 253>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>37<cfelse>32</cfif>
                WHERE scheduleID = 270
            </cfquery>
        </cfif>
        <!--- Minx vs KeKembas Plays Shooting Blanks --->
        <cfif url.scheduleID EQ 252>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>33<cfelse>45</cfif>
                WHERE scheduleID = 271
            </cfquery>
        </cfif>
        <!--- From No Where Close vs Tripp City Plays The Dream Team --->
        <cfif url.scheduleID EQ 254>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>47<cfelse>54</cfif>
                WHERE scheduleID = 273
            </cfquery>
        </cfif>
        <!--- OPM vs Coastbusterz Plays The Murray's --->
        <cfif url.scheduleID EQ 255>
            <cfquery name="updateMensBracket" datasource="roundleague">
                UPDATE Schedule
                SET awayTeamID = <cfif form.homeScore GT form.awayScore>12<cfelse>48</cfif>
                WHERE scheduleID = 272
            </cfquery>
        </cfif>

        <cflocation url="StatsApp-Select.cfm?saved=true">

    <cfcatch><cfdump var="#cfcatch#" /></cfcatch>
    </cftry>
</cfoutput>