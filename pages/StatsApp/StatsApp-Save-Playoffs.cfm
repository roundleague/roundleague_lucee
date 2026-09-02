<cfoutput>

     <cffunction name="getAdvanceToGameId"
        hint="Get the next bracketGameId to advance to for playoffs" returntype="number">
        <cfargument name="fromGameId" default="" required="yes" type="number">
        <cfargument name="numTeams" default="" required="yes" type="number">

        <cfif numTeams EQ 32>
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
        <cfelseif numTeams EQ 22>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1"><cfreturn 12></cfcase>
                <cfcase value="2"><cfreturn 11></cfcase>
                <cfcase value="3"><cfreturn 10></cfcase>
                <cfcase value="4"><cfreturn 9></cfcase>
                <cfcase value="5"><cfreturn 8></cfcase>
                <cfcase value="6"><cfreturn 14></cfcase>
                <cfcase value="7,14"><cfreturn 15></cfcase>
                <cfcase value="8,13"><cfreturn 16></cfcase>
                <cfcase value="9,12"><cfreturn 17></cfcase>
                <cfcase value="10,11"><cfreturn 18></cfcase>
                <cfcase value="15,18"><cfreturn 19></cfcase>
                <cfcase value="16,17"><cfreturn 20></cfcase>
                <cfcase value="19,20"><cfreturn 21></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch> 
        <cfelseif numTeams EQ 20>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1"><cfreturn 8></cfcase>
                <cfcase value="2"><cfreturn 7></cfcase>
                <cfcase value="3"><cfreturn 6></cfcase>
                <cfcase value="4"><cfreturn 5></cfcase>
                <cfcase value="5,12"><cfreturn 13></cfcase>
                <cfcase value="6,11"><cfreturn 14></cfcase>
                <cfcase value="7,10"><cfreturn 15></cfcase>
                <cfcase value="8,9"><cfreturn 16></cfcase>
                <cfcase value="13,16"><cfreturn 17></cfcase>
                <cfcase value="14,15"><cfreturn 18></cfcase>
                <cfcase value="17,18"><cfreturn 19></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch> 
        <cfelseif numTeams EQ 16>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1,2"><cfreturn 9></cfcase>
                <cfcase value="3,4"><cfreturn 12></cfcase>
                <cfcase value="5,6"><cfreturn 10></cfcase>
                <cfcase value="7,8"><cfreturn 11></cfcase>
                <cfcase value="9,10"><cfreturn 13></cfcase>
                <cfcase value="11,12"><cfreturn 14></cfcase>
                <cfcase value="13,14"><cfreturn 15></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelseif numTeams EQ 11>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1"><cfreturn 6></cfcase>
                <cfcase value="2"><cfreturn 5></cfcase>
                <cfcase value="3"><cfreturn 4></cfcase>
                <cfcase value="4,5"><cfreturn 8></cfcase>
                <cfcase value="6,7"><cfreturn 9></cfcase>
                <cfcase value="8,9"><cfreturn 10></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelseif numTeams EQ 8>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1,2"><cfreturn 5></cfcase>
                <cfcase value="3,4"><cfreturn 6></cfcase>
                <cfcase value="5,6"><cfreturn 7></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelseif numTeams EQ 7>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="2,3"><cfreturn 6></cfcase> <!-- 2/7 and 3/6 advance to 6 -->
                <cfcase value="4"><cfreturn 5></cfcase>    <!-- 4/5 advances to 5 (vs seed 1) -->
                <cfcase value="5,6"><cfreturn 7></cfcase>  <!-- Winners of 5 and 6 go to Championship -->
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelseif numTeams EQ 6>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1"><cfreturn 3></cfcase>
                <cfcase value="2"><cfreturn 4></cfcase>
                <cfcase value="3,4"><cfreturn 5></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>    
        <cfelseif numTeams EQ 4>
            <cfswitch expression="#fromGameId#"> 
                <cfcase value="1,2"><cfreturn 3></cfcase>
                <cfdefaultcase><cfreturn 0></cfdefaultcase> 
            </cfswitch>
        <cfelse>
            <cfreturn 0>
        </cfif>

     </cffunction>

     <cffunction name="fillDoubleElimSlot"
        hint="Double-elim only: find the destination playoffs_schedule row by BracketGameID and fill whichever team slot (Home/Away) is empty" returntype="void">
        <cfargument name="bracketID" default="" required="yes" type="numeric">
        <cfargument name="destGameID" default="" required="yes" type="numeric">
        <cfargument name="teamID" default="" required="yes" type="numeric">

        <cfquery name="destRow" datasource="roundleague">
            SELECT Playoffs_scheduleID, HomeTeamID, AwayTeamID
            FROM Playoffs_Schedule
            WHERE Playoffs_BracketID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bracketID#">
            AND BracketGameID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.destGameID#">
        </cfquery>

        <cfif destRow.recordCount NEQ 0>
            <cfset destUpdateCol = (destRow.homeTeamID EQ '') ? 'HomeTeamID' : 'AwayTeamID'>
            <cfquery name="fillSlot" datasource="roundleague">
                UPDATE Playoffs_Schedule
                SET #destUpdateCol# = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.teamID#">
                WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#destRow.Playoffs_scheduleID#">
            </cfquery>
        </cfif>
     </cffunction>

    <cftry>
    <!--- Get the max rounds for current bracket --->
    <cfquery name="getMaxTeams" datasource="roundleague">
        SELECT MaxTeamSize, BracketFormat
        FROM playoffs_bracket
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
        SELECT status
        From Playoffs_Schedule
        WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>

    <!--- Guard against double-submission by finalized status, not by homeScore being
          non-empty — live-score sync now writes homeScore/awayScore continuously
          during play, well before this Save button is ever clicked. --->
    <cfif scoresExist.status NEQ 'final'>

        <cfquery name="updateScheduleScore" datasource="roundleague">
            UPDATE Playoffs_Schedule
            SET
                    homeScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.homeScore#">,
                    awayScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.awayScore#">,
                    status = 'final'
            WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
        </cfquery>

        <!--- Notify live scoreboard that game is final --->
        <cfhttp method="PATCH"
                url="#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#/api/playoffs/schedule/#url.scheduleID#/score"
                result="patchFinalResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="header" name="x-admin-key" value="#application.adminApiKey#">
            <cfhttpparam type="body" value='{"status":"final"}'>
        </cfhttp>

        <!--- Advance Winning Team --->
        <cfif getMaxTeams.BracketFormat EQ 'double_elim_7'>
            <!--- Double-Elim (7-Team) advancement — reads WinnerAdvancesTo/LoserAdvancesTo off this game's own row --->
            <cfset winnerTeamID = (form.homeScore GT form.awayScore) ? getTeamsPlaying.homeTeamID : getTeamsPlaying.awayTeamID>
            <cfset loserTeamID = (form.homeScore GT form.awayScore) ? getTeamsPlaying.awayTeamID : getTeamsPlaying.homeTeamID>

            <cfquery name="getCurrentGameAdvancement" datasource="roundleague">
                SELECT WinnerAdvancesTo, LoserAdvancesTo
                FROM Playoffs_Schedule
                WHERE Playoffs_scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
            </cfquery>

            <cfif getCurrentGameAdvancement.WinnerAdvancesTo EQ '' OR getCurrentGameAdvancement.WinnerAdvancesTo EQ 0>
                <!--- Championship Game - insert winner into champions table --->
                <cfquery name="dupChampionCheck" datasource="roundleague">
                    SELECT championsID FROM champions
                    WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#winnerTeamID#">
                    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                </cfquery>
                <cfif dupChampionCheck.recordCount EQ 0>
                    <cfquery name="insertChampion" datasource="roundleague">
                        INSERT INTO champions (teamID, seasonID)
                        VALUES (
                            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#winnerTeamID#">,
                            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                        )
                    </cfquery>
                </cfif>
            <cfelse>
                <cfset fillDoubleElimSlot(url.Playoffs_BracketID, getCurrentGameAdvancement.WinnerAdvancesTo, winnerTeamID)>
            </cfif>

            <cfif getCurrentGameAdvancement.LoserAdvancesTo NEQ '' AND getCurrentGameAdvancement.LoserAdvancesTo NEQ 0>
                <cfset fillDoubleElimSlot(url.Playoffs_BracketID, getCurrentGameAdvancement.LoserAdvancesTo, loserTeamID)>
            </cfif>
            <!--- else: loser is eliminated, no further write --->

        <cfelse>
        <cfset nextGameId = getAdvanceToGameId(url.bracketGameID, getMaxTeams.MaxTeamSize)>
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
            <!--- Championship Game - insert winner into champions table --->
            <cfset winnerTeamID = (form.homeScore GT form.awayScore) ? getTeamsPlaying.homeTeamID : getTeamsPlaying.awayTeamID>
            <cfquery name="dupChampionCheck" datasource="roundleague">
                SELECT championsID FROM champions
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#winnerTeamID#">
                AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
            </cfquery>
            <cfif dupChampionCheck.recordCount EQ 0>
                <cfquery name="insertChampion" datasource="roundleague">
                    INSERT INTO champions (teamID, seasonID)
                    VALUES (
                        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#winnerTeamID#">,
                        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActiveSeasonID.seasonID#">
                    )
                </cfquery>
            </cfif>
        </cfif>
        </cfif>
    </cfif>

    <!--- Generate recap once both teams have submitted stats (runs regardless of prior finalization) --->
    <cfquery name="checkExistingRecap" datasource="roundleague">
        SELECT recapText FROM recaps
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
        AND isPlayoff = 1
    </cfquery>

    <cfif NOT checkExistingRecap.recordCount>
        <cfquery name="teamsWithStats" datasource="roundleague">
            SELECT COUNT(DISTINCT teamID) AS teamCount
            FROM Playoffs_PlayerGameLog
            WHERE Playoffs_ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
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
                FROM Playoffs_PlayerGameLog pgl
                JOIN Players p ON p.playerID = pgl.playerID
                JOIN Teams t ON t.teamID = pgl.teamID
                WHERE pgl.Playoffs_ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
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
            <cfthread action="run" name="recapPlayoffs_#url.scheduleID#_#getTickCount()#"
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
                            INSERT INTO recaps (scheduleID, recapText, isPlayoff)
                            VALUES (
                                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.scheduleID#">,
                                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#tRecapParsed.choices[1].message.content#">,
                                1
                            )
                        </cfquery>
                    </cfif>
                <cfcatch></cfcatch>
                </cftry>
            </cfthread>
            <!--- No cfthread join — redirect happens while recap generates in background --->
        </cfif>
    </cfif>

        <cflocation url="StatsApp-Select.cfm?saved=true">

    <cfcatch><cfdump var="#cfcatch#" /></cfcatch>
    </cftry>
</cfoutput>
