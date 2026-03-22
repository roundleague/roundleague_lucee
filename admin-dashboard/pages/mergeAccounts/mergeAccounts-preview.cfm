<cfparam name="url.keepPlayerID" default="0">
<cfparam name="url.mergePlayerID" default="0">

<cfif NOT isNumeric(url.keepPlayerID) OR NOT isNumeric(url.mergePlayerID) OR url.keepPlayerID EQ 0 OR url.mergePlayerID EQ 0>
  <cfoutput><div class="alert alert-danger">Invalid player IDs.</div></cfoutput>
  <cfabort>
</cfif>

<!--- Load keep player --->
<cfquery name="keepPlayer" datasource="roundleague">
  SELECT p.playerID, p.firstName, p.lastName, p.email, p.phone, p.birthDate, p.RegisterDate,
         COUNT(DISTINCT r.seasonID) AS seasonsPlayed,
         COUNT(DISTINCT pgl.playerGameLogID) AS gamesPlayed
  FROM players p
  LEFT JOIN roster r ON r.playerID = p.playerID
  LEFT JOIN playergamelog pgl ON pgl.playerID = p.playerID
  WHERE p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.keepPlayerID#">
  GROUP BY p.playerID, p.firstName, p.lastName, p.email, p.phone, p.birthDate, p.RegisterDate
</cfquery>

<!--- Load merge player --->
<cfquery name="mergePlayer" datasource="roundleague">
  SELECT p.playerID, p.firstName, p.lastName, p.email, p.phone, p.birthDate, p.RegisterDate,
         COUNT(DISTINCT r.seasonID) AS seasonsPlayed,
         COUNT(DISTINCT pgl.playerGameLogID) AS gamesPlayed
  FROM players p
  LEFT JOIN roster r ON r.playerID = p.playerID
  LEFT JOIN playergamelog pgl ON pgl.playerID = p.playerID
  WHERE p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.mergePlayerID#">
  GROUP BY p.playerID, p.firstName, p.lastName, p.email, p.phone, p.birthDate, p.RegisterDate
</cfquery>

<cfif keepPlayer.recordCount EQ 0 OR mergePlayer.recordCount EQ 0>
  <cfoutput><div class="alert alert-danger">One or both players not found.</div></cfoutput>
  <cfabort>
</cfif>

<!--- Check for season conflicts (both on roster same season, different teams) --->
<cfquery name="seasonConflicts" datasource="roundleague">
  SELECT r1.seasonID, s.SeasonName,
         t1.teamName AS keepTeamName, t2.teamName AS mergeTeamName
  FROM roster r1
  JOIN roster r2 ON r1.seasonID = r2.seasonID
  JOIN seasons s ON s.seasonID = r1.seasonID
  LEFT JOIN teams t1 ON t1.teamID = r1.teamID
  LEFT JOIN teams t2 ON t2.teamID = r2.teamID
  WHERE r1.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.keepPlayerID#">
  AND r2.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.mergePlayerID#">
  AND r1.teamID != r2.teamID
</cfquery>

<cfoutput>
<div class="merge-preview">
  <div class="row">
    <div class="col-md-6">
      <div class="preview-card keep-card">
        <div class="preview-card-header">
          <span class="badge badge-success">KEEP</span>
          <strong>#keepPlayer.firstName# #keepPlayer.lastName#</strong>
        </div>
        <table class="preview-table">
          <tr><td>Email</td><td>#keepPlayer.email#</td></tr>
          <tr><td>Phone</td><td>#len(keepPlayer.phone) ? keepPlayer.phone : "—"#</td></tr>
          <tr><td>Birth Date</td><td>#isDate(keepPlayer.birthDate) ? dateFormat(keepPlayer.birthDate, "mmm d, yyyy") : "—"#</td></tr>
          <tr><td>Registered</td><td>#isDate(keepPlayer.RegisterDate) ? dateFormat(keepPlayer.RegisterDate, "mmm d, yyyy") : "—"#</td></tr>
          <tr><td>Seasons Played</td><td>#keepPlayer.seasonsPlayed#</td></tr>
          <tr><td>Games Played</td><td>#keepPlayer.gamesPlayed#</td></tr>
          <tr><td>Player ID</td><td>#keepPlayer.playerID#</td></tr>
        </table>
      </div>
    </div>
    <div class="col-md-6">
      <div class="preview-card merge-card">
        <div class="preview-card-header">
          <span class="badge badge-warning">MERGE FROM</span>
          <strong>#mergePlayer.firstName# #mergePlayer.lastName#</strong>
        </div>
        <table class="preview-table">
          <tr><td>Email</td><td>#mergePlayer.email#</td></tr>
          <tr><td>Phone</td><td>#len(mergePlayer.phone) ? mergePlayer.phone : "—"#</td></tr>
          <tr><td>Birth Date</td><td>#isDate(mergePlayer.birthDate) ? dateFormat(mergePlayer.birthDate, "mmm d, yyyy") : "—"#</td></tr>
          <tr><td>Registered</td><td>#isDate(mergePlayer.RegisterDate) ? dateFormat(mergePlayer.RegisterDate, "mmm d, yyyy") : "—"#</td></tr>
          <tr><td>Seasons Played</td><td>#mergePlayer.seasonsPlayed#</td></tr>
          <tr><td>Games Played</td><td>#mergePlayer.gamesPlayed#</td></tr>
          <tr><td>Player ID</td><td>#mergePlayer.playerID#</td></tr>
        </table>
      </div>
    </div>
  </div>

  <cfif seasonConflicts.recordCount GT 0>
  <div class="alert alert-warning mt-3">
    <strong>Season Conflict Detected</strong> — Both players are on the roster for the same season(s) on different teams. The MERGE FROM player's team assignment for those seasons will be removed:
    <ul class="mb-0 mt-1">
      <cfloop query="seasonConflicts">
        <li>#seasonConflicts.SeasonName#: KEEP on <em>#seasonConflicts.keepTeamName#</em>, MERGE FROM on <em>#seasonConflicts.mergeTeamName#</em></li>
      </cfloop>
    </ul>
  </div>
  </cfif>

  <div class="merge-summary">
    The history (game logs, season stats, roster records) from <strong>#mergePlayer.firstName# #mergePlayer.lastName#</strong>
    will be transferred to <strong>#keepPlayer.firstName# #keepPlayer.lastName#</strong>.
    The old account will be deactivated.
  </div>
</div>
</cfoutput>
