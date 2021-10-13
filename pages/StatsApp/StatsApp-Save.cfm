<cfoutput>
<!---     <cfset playerIDList = ValueList(getPlayers.playerID)>
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
                Turnovers
                )
            VALUES
            <cfloop list="#playerIDList#" index="count" item="i">
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
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["TO_" & i]#">
                )<cfif count NEQ ListLen(playerIDList)>,</cfif>
            </cfloop>

    </cfquery> --->

    <cfquery name="updateScheduleScore" datasource="roundleague">
        UPDATE schedule 
        SET 
                homeScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.homeScore#">, 
                awayScore = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.awayScore#">
        WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
    </cfquery>

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
            SET <cfif form.homeScore GT form.awayScore>WINS<cfelse>LOSSES</cfif> = <cfif form.homeScore GT form.awayScore>WINS<cfelse>LOSSES</cfif> + 1
            WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">
        </cfquery>
    <cfelse>
        <cfquery name="insertStandings" datasource="roundleague">
            INSERT INTO Standings (TeamID, Wins, Losses, SeasonID, DivisionID)
            VALUES 
            (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.homeTeamID#">,
                <cfif form.homeScore GT form.awayScore>1<cfelse>0</cfif>,
                <cfif form.homeScore LT form.awayScore>1<cfelse>0</cfif>,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.SeasonID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.DivisionID#">
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
            SET <cfif form.awayScore GT form.homeScore>WINS<cfelse>LOSSES</cfif> = <cfif form.awayScore GT form.homeScore>WINS<cfelse>LOSSES</cfif> + 1
            WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">
        </cfquery>
    <cfelse>
        <cfquery name="insertStandings" datasource="roundleague">
            INSERT INTO Standings (TeamID, Wins, Losses, SeasonID, DivisionID)
            VALUES 
            (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.awayTeamID#">,
                <cfif form.awayScore GT form.homeScore>1<cfelse>0</cfif>,
                <cfif form.awayScore LT form.homeScore>1<cfelse>0</cfif>,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.SeasonID#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.DivisionID#">
            )
        </cfquery>
    </cfif>

    <!--- Player Stats Update Section --->
    <cfquery name="team" datasource="roundleague">
        
    </cfquery>

    Saved.
</cfoutput>