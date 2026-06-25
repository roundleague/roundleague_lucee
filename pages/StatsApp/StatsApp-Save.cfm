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

    <!--- Store sub events for the historical record --->
    <cfif structKeyExists(form, "subEvents") AND len(trim(form.subEvents)) GT 2>
        <cfset subArray = DeserializeJSON(form.subEvents)>
        <cfloop array="#subArray#" index="sub">
            <cfquery datasource="roundleague">
                INSERT INTO game_subs (scheduleID, teamID, playerOutID, playerInID, homeScore, awayScore, seq)
                VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sub.playerOutID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sub.playerInID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sub.homeScore#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sub.awayScore#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sub.seq#">
                )
            </cfquery>
        </cfloop>
    </cfif>

    <!--- Save +/- values directly from the live display on the StatsApp screen --->
    <cfif structKeyExists(form, "plusMinusValues") AND len(trim(form.plusMinusValues)) GT 2>
        <cfset pmData = DeserializeJSON(form.plusMinusValues)>
        <cfloop list="#playerIDList#" index="i">
            <cfif NOT (form["FGA_" & i] EQ 0 AND form["PTS_" & i] EQ 0 AND form["REBS_" & i] EQ 0 AND form["ASTS_" & i] EQ 0 AND form["STLS_" & i] EQ 0 AND form["BLKS_" & i] EQ 0 AND form["FOULS_" & i] EQ 0)>
                <cfif structKeyExists(pmData, i)>
                    <cfquery datasource="roundleague">
                        UPDATE playergamelog SET plusMinus = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(pmData[i])#">
                        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
                        AND playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
                    </cfquery>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>

    <cfquery name="scoresExist" datasource="roundleague">
        SELECT homeTeamID, awayTeamID, seasonID, divisionID, homeScore, awayScore, status
        From Schedule
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>

    <!--- Update scores/status if game hasn't been finalized yet --->
    <cfif scoresExist.status NEQ 'final'>

        <cfquery name="updateScheduleScore" datasource="roundleague">
            UPDATE schedule
            SET
                    homeScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.homeScore#">,
                    awayScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.awayScore#">,
                    status = 'final'
            WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
        </cfquery>

        <!--- Notify live scoreboard that game is final --->
        <cfhttp method="PATCH"
                url="#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#/api/schedule/#url.scheduleID#/score"
                result="patchFinalResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="header" name="x-admin-key" value="#application.adminApiKey#">
            <cfhttpparam type="body" value='{"status":"final"}'>
        </cfhttp>

    </cfif>

    <!--- Recalculate standings from scratch for both teams — idempotent, safe to run on every save --->
    <cfloop list="#scoresExist.homeTeamID#,#scoresExist.awayTeamID#" index="teamToRecalc">
        <cfquery name="recalcStandings" datasource="roundleague">
            SELECT
                SUM(CASE WHEN (HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#"> AND HomeScore > AwayScore)
                           OR (AwayTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#"> AND AwayScore > HomeScore)
                         THEN 1 ELSE 0 END) AS calcWins,
                SUM(CASE WHEN (HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#"> AND HomeScore < AwayScore)
                           OR (AwayTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#"> AND AwayScore < HomeScore)
                         THEN 1 ELSE 0 END) AS calcLosses,
                SUM(CASE WHEN HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">
                         THEN HomeScore - AwayScore
                         ELSE AwayScore - HomeScore END) AS calcPointDiff
            FROM schedule
            WHERE status = 'final'
            AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#scoresExist.seasonID#">
            AND (HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">
                 OR AwayTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">)
        </cfquery>

        <cfquery name="checkTeamStandings" datasource="roundleague">
            SELECT StandingsID FROM standings
            WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">
            AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#scoresExist.seasonID#">
        </cfquery>

        <cfif checkTeamStandings.recordCount>
            <cfquery datasource="roundleague">
                UPDATE standings
                SET Wins = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcWins#">,
                    Losses = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcLosses#">,
                    PointDifferential = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcPointDiff#">
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">
                AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#scoresExist.seasonID#">
            </cfquery>
        <cfelse>
            <cfquery datasource="roundleague">
                INSERT INTO standings (TeamID, Wins, Losses, SeasonID, DivisionID, PointDifferential)
                VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamToRecalc#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcWins#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcLosses#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#scoresExist.seasonID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#scoresExist.divisionID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#recalcStandings.calcPointDiff#">
                )
            </cfquery>
        </cfif>
    </cfloop>

    <!--- Generate recap once both teams have submitted stats (runs regardless of prior finalization) --->
    <cfquery name="checkExistingRecap" datasource="roundleague">
        SELECT recapText FROM recaps
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>

    <cfif NOT checkExistingRecap.recordCount>
        <cfquery name="teamsWithStats" datasource="roundleague">
            SELECT COUNT(DISTINCT teamID) AS teamCount
            FROM PlayerGameLog
            WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
            AND teamID IN (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">
            )
        </cfquery>

        <cfif teamsWithStats.teamCount EQ 2>
            <cfquery name="allPlayerLogs" datasource="roundleague">
                SELECT pgl.playerID, p.firstName, p.lastName, FGM, FGA, 3FGM, 3FGA,
                       FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers,
                       pgl.teamID, t.teamName, pgl.Fouls
                FROM PlayerGameLog pgl
                JOIN Players p ON p.playerID = pgl.playerID
                JOIN Teams t ON t.teamID = pgl.teamID
                WHERE pgl.scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
                ORDER BY pgl.teamID
            </cfquery>

            <cfset boxscoreCfc = createObject("component", "pages.boxscore.boxscore")>
            <cfset recapPlayerPrompts = "">
            <cfset recapFirstTeamTotals = "">
            <cfset recapCurrentTeamID = "">
            <cfset recapCurrentTeamName = "">
            <cfset rFGM=0><cfset rFGA=0><cfset r3FGM=0><cfset r3FGA=0>
            <cfset rFTM=0><cfset rFTA=0><cfset rREB=0><cfset rAST=0>
            <cfset rSTL=0><cfset rBLK=0><cfset rTO=0><cfset rFLS=0><cfset rPTS=0>

            <cfloop query="allPlayerLogs">
                <cfif allPlayerLogs.teamID NEQ recapCurrentTeamID AND recapCurrentTeamID NEQ "">
                    <cfset firstTeamStruct = {TotalFGM:rFGM,TotalFGA:rFGA,Total3FGM:r3FGM,Total3FGA:r3FGA,TotalFTM:rFTM,TotalFTA:rFTA,TotalREB:rREB,TotalAST:rAST,TotalSTL:rSTL,TotalBLK:rBLK,TotalTO:rTO,TotalFLS:rFLS,TotalPTS:rPTS}>
                    <cfset recapFirstTeamTotals = boxscoreCfc.generateTeamStatsPrompt(recapCurrentTeamName, firstTeamStruct)>
                    <cfset rFGM=0><cfset rFGA=0><cfset r3FGM=0><cfset r3FGA=0>
                    <cfset rFTM=0><cfset rFTA=0><cfset rREB=0><cfset rAST=0>
                    <cfset rSTL=0><cfset rBLK=0><cfset rTO=0><cfset rFLS=0><cfset rPTS=0>
                </cfif>
                <cfset recapCurrentTeamID = allPlayerLogs.teamID>
                <cfset recapCurrentTeamName = allPlayerLogs.teamName>
                <cfset rFGM += allPlayerLogs.FGM><cfset rFGA += allPlayerLogs.FGA>
                <cfset r3FGM += allPlayerLogs.3FGM><cfset r3FGA += allPlayerLogs.3FGA>
                <cfset rFTM += allPlayerLogs.FTM><cfset rFTA += allPlayerLogs.FTA>
                <cfset rREB += allPlayerLogs.Rebounds><cfset rAST += allPlayerLogs.Assists>
                <cfset rSTL += allPlayerLogs.Steals><cfset rBLK += allPlayerLogs.Blocks>
                <cfset rTO += allPlayerLogs.Turnovers><cfset rFLS += val(allPlayerLogs.Fouls)>
                <cfset rPTS += allPlayerLogs.Points>
                <cfset recapPlayerPrompts &= boxscoreCfc.generatePlayerStatsPrompt(allPlayerLogs, allPlayerLogs.teamID)>
            </cfloop>

            <cfset secondTeamStruct = {TotalFGM:rFGM,TotalFGA:rFGA,Total3FGM:r3FGM,Total3FGA:r3FGA,TotalFTM:rFTM,TotalFTA:rFTA,TotalREB:rREB,TotalAST:rAST,TotalSTL:rSTL,TotalBLK:rBLK,TotalTO:rTO,TotalFLS:rFLS,TotalPTS:rPTS}>
            <cfset recapSecondTeamTotals = boxscoreCfc.generateTeamStatsPrompt(recapCurrentTeamName, secondTeamStruct)>

            <cfset recapTeamScores = "#getTeamsPlaying.Home# #form.homeScore# | #getTeamsPlaying.Away# #form.awayScore#">
            <cfset recapTotalMessage = recapFirstTeamTotals & recapSecondTeamTotals & recapTeamScores & recapPlayerPrompts>

            <cfinclude template="/pages/boxscore/config.cfm">

            <!--- Fire recap generation in background — main request redirects immediately --->
            <cfthread action="run" name="recap_#url.scheduleID#_#getTickCount()#"
                      scheduleID="#url.scheduleID#"
                      totalMessage="#recapTotalMessage#"
                      openAiKey="#apiKey#">
                <cftry>
                    <cfhttp url="https://api.openai.com/v1/chat/completions" method="POST" result="tRecapResult">
                        <cfhttpparam type="header" name="Content-Type" value="application/json">
                        <cfhttpparam type="header" name="Authorization" value="Bearer #attributes.openAiKey#">
                        <cfhttpparam type="body" value='{
                          "model": "gpt-3.5-turbo",
                          "messages": [
                            {"role":"system","content":"Recap this basketball game like ESPN would based on the following stats in less than 1000 characters. Majority sentences should highlight individual performances but make sure one sentence compares team totals."},
                            {"role":"user","content":"#JSStringFormat(attributes.totalMessage)#"}
                          ],
                          "temperature": 1.0,
                          "top_p": 1
                        }'>
                    </cfhttp>
                    <cfif tRecapResult.statusCode NEQ "200 OK">
                        <cfthrow message="OpenAI returned #tRecapResult.statusCode#">
                    </cfif>
                    <cfset tRecapParsed = DeserializeJSON(tRecapResult.fileContent)>
                    <cfif structKeyExists(tRecapParsed, "choices") AND arrayLen(tRecapParsed.choices)>
                        <cfquery datasource="roundleague">
                            INSERT INTO recaps (scheduleID, recapText)
                            VALUES (
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.scheduleID#">,
                                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#tRecapParsed.choices[1].message.content#">
                            )
                        </cfquery>
                    </cfif>
                <cfcatch></cfcatch>
                </cftry>
            </cfthread>
            <!--- No cfthread join — redirect happens while recap generates in background --->
        </cfif>
    </cfif>

    <!--- Auto-seed HS Division championship — SeasonID 21 / DivisionID 110 only --->
    <cfif scoresExist.divisionID EQ 110 AND getActiveSeasonID.seasonID EQ 21>
        <cfquery name="getChampionshipSlot" datasource="roundleague">
            SELECT scheduleID FROM schedule
            WHERE divisionID = 110 AND seasonID = 21
            AND homeTeamID IS NULL AND awayTeamID IS NULL
            LIMIT 1
        </cfquery>

        <cfif getChampionshipSlot.recordCount GT 0>
            <cfquery name="getPendingGames" datasource="roundleague">
                SELECT COUNT(*) AS pendingCount FROM schedule
                WHERE divisionID = 110 AND seasonID = 21
                AND homeTeamID IS NOT NULL AND awayTeamID IS NOT NULL
                AND (homeScore IS NULL OR awayScore IS NULL OR status != 'final')
            </cfquery>

            <cfif getPendingGames.pendingCount EQ 0>
                <cfquery name="getTop2Seeds" datasource="roundleague">
                    SELECT teamID FROM standings
                    WHERE divisionID = 110 AND seasonID = 21
                    ORDER BY wins DESC, PointDifferential DESC
                    LIMIT 2
                </cfquery>

                <cfif getTop2Seeds.recordCount EQ 2>
                    <cfquery name="seedChampionship" datasource="roundleague">
                        UPDATE schedule
                        SET homeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTop2Seeds.teamID[1]#">,
                            awayTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTop2Seeds.teamID[2]#">
                        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getChampionshipSlot.scheduleID#">
                    </cfquery>
                </cfif>
            </cfif>
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
                    <cfquery name="updateStats" datasource="roundleague" result="updateResult">
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
                    </cfquery>
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

        <cflocation url="StatsApp-Select.cfm?saved=true">

    <cfcatch><cfdump var="#cfcatch#" /></cfcatch>
    </cftry>
</cfoutput>