<cfoutput>
    <cfset playerIDList = ValueList(getPlayers.playerID)>
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

    </cfquery>

    Saved.
</cfoutput>