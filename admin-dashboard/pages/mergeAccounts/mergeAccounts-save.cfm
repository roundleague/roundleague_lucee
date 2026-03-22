<cfcontent type="application/json">

<cfparam name="form.keepPlayerID" default="0">
<cfparam name="form.mergePlayerID" default="0">

<!--- Basic validation --->
<cfif NOT isNumeric(form.keepPlayerID) OR NOT isNumeric(form.mergePlayerID)
      OR form.keepPlayerID EQ 0 OR form.mergePlayerID EQ 0>
  <cfoutput>#serializeJSON({"success": false, "message": "Invalid player IDs."})#</cfoutput>
  <cfabort>
</cfif>

<cfif form.keepPlayerID EQ form.mergePlayerID>
  <cfoutput>#serializeJSON({"success": false, "message": "Cannot merge a player into themselves."})#</cfoutput>
  <cfabort>
</cfif>

<!--- Guard: verify both players exist and are not already merged --->
<cfquery name="checkKeep" datasource="roundleague">
  SELECT playerID, mergedIntoPlayerID FROM players
  WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
</cfquery>
<cfquery name="checkMerge" datasource="roundleague">
  SELECT playerID, mergedIntoPlayerID FROM players
  WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
</cfquery>

<cfif checkKeep.recordCount EQ 0>
  <cfoutput>#serializeJSON({"success": false, "message": "KEEP player not found."})#</cfoutput>
  <cfabort>
</cfif>
<cfif checkMerge.recordCount EQ 0>
  <cfoutput>#serializeJSON({"success": false, "message": "MERGE FROM player not found."})#</cfoutput>
  <cfabort>
</cfif>
<cfif checkKeep.mergedIntoPlayerID NEQ "">
  <cfoutput>#serializeJSON({"success": false, "message": "The KEEP player has already been merged into another account."})#</cfoutput>
  <cfabort>
</cfif>
<cfif checkMerge.mergedIntoPlayerID NEQ "">
  <cfoutput>#serializeJSON({"success": false, "message": "The MERGE FROM player has already been merged into another account."})#</cfoutput>
  <cfabort>
</cfif>

<cftry>
  <cftransaction>

    <!--- Step 2: Roster conflicts — delete merge player rows where both exist in same season --->
    <cfquery name="rosterConflicts" datasource="roundleague">
      SELECT r2.rosterID
      FROM roster r1
      JOIN roster r2 ON r1.seasonID = r2.seasonID
      WHERE r1.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      AND r2.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <cfif rosterConflicts.recordCount GT 0>
      <cfset conflictIDs = valueList(rosterConflicts.rosterID)>
      <cfquery datasource="roundleague">
        DELETE FROM roster
        WHERE rosterID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#conflictIDs#" list="true">)
      </cfquery>
    </cfif>

    <!--- Move remaining roster rows to keep player --->
    <cfquery datasource="roundleague">
      UPDATE roster
      SET playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 3: Move all game log rows --->
    <cfquery datasource="roundleague">
      UPDATE playergamelog
      SET playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 4: Recalculate playerstats for each season merge player had stats --->
    <cfquery name="mergeSeasonStats" datasource="roundleague">
      SELECT playerStatsID, seasonID
      FROM playerstats
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <cfloop query="mergeSeasonStats">
      <cfset thisSeason = mergeSeasonStats.seasonID>
      <cfset thisStatsID = mergeSeasonStats.playerStatsID>

      <!--- Check if keep player already has stats for this season --->
      <cfquery name="keepHasSeason" datasource="roundleague">
        SELECT playerStatsID FROM playerstats
        WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
        AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">
      </cfquery>

      <cfif keepHasSeason.recordCount GT 0>
        <!--- Delete merge player's row for this season --->
        <cfquery datasource="roundleague">
          DELETE FROM playerstats
          WHERE playerStatsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisStatsID#">
        </cfquery>

        <!--- Recalculate keep player's row using AVG from combined game logs --->
        <cfquery datasource="roundleague">
          UPDATE playerstats
          SET
            Points      = (SELECT CAST(AVG(Points)    AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            Rebounds    = (SELECT CAST(AVG(Rebounds)  AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            Assists     = (SELECT CAST(AVG(Assists)   AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            Steals      = (SELECT CAST(AVG(Steals)    AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            Blocks      = (SELECT CAST(AVG(Blocks)    AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            Turnovers   = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            FGM         = (SELECT CAST(AVG(FGM)       AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            FGA         = (SELECT CAST(AVG(FGA)       AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            3FGM        = (SELECT CAST(AVG(3FGM)      AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            3FGA        = (SELECT CAST(AVG(3FGA)      AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            FTM         = (SELECT CAST(AVG(FTM)       AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            FTA         = (SELECT CAST(AVG(FTA)       AS DECIMAL(10,1)) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">),
            GamesPlayed = (SELECT COUNT(*) FROM playergamelog WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#"> AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">)
          WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
          AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisSeason#">
        </cfquery>
      <cfelse>
        <!--- No conflict: just reassign the stats row to the keep player --->
        <cfquery datasource="roundleague">
          UPDATE playerstats
          SET playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
          WHERE playerStatsID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisStatsID#">
        </cfquery>
      </cfif>
    </cfloop>

    <!--- Step 5: Update captain references in teams --->
    <cfquery datasource="roundleague">
      UPDATE teams
      SET captainPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      WHERE captainPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 6: Update transactions --->
    <cfquery datasource="roundleague">
      UPDATE transactions
      SET playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 7: Deactivate old user account --->
    <cfquery datasource="roundleague">
      UPDATE users
      SET status = 'Merged'
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 8: Mark old player record as merged --->
    <cfquery datasource="roundleague">
      UPDATE players
      SET mergedIntoPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">
      WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">
    </cfquery>

    <!--- Step 9: Write audit log --->
    <cfquery datasource="roundleague">
      INSERT INTO merge_audit_log (keptPlayerID, mergedPlayerID, mergedByUser, mergeDate)
      VALUES (
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.keepPlayerID#">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.mergePlayerID#">,
        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.userName ?: 'Admin'#">,
        NOW()
      )
    </cfquery>

  </cftransaction>

  <cfoutput>#serializeJSON({"success": true})#</cfoutput>

  <cfcatch type="any">
    <cfoutput>#serializeJSON({"success": false, "message": "Merge failed: #JSStringFormat(cfcatch.message)#"})#</cfoutput>
  </cfcatch>
</cftry>
