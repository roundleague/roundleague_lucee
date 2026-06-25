<cfsetting showdebugoutput="false">
<cfcontent type="application/json">

<cfparam name="form.action"                  default="">
<cfparam name="form.scheduleID"              default="0">
<cfparam name="form.playerID"               default="0">
<cfparam name="form.teamID"                 default="0">
<cfparam name="form.stat_type"              default="">
<cfparam name="form.points_scored"          default="0">
<cfparam name="form.home_score"             default="0">
<cfparam name="form.away_score"             default="0">
<cfparam name="form.period"                 default="1">
<cfparam name="form.clock_remaining_seconds" default="">
<cfparam name="form.local_play_id"          default="">

<cftry>
    <cfif form.action EQ "add" AND len(trim(form.local_play_id)) AND val(form.scheduleID) GT 0>
        <cfquery datasource="roundleague">
            INSERT IGNORE INTO game_plays
                (scheduleID, playerID, teamID, stat_type, points_scored,
                 home_score, away_score, period, clock_remaining_seconds, local_play_id)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.scheduleID)#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.playerID)#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.teamID)#">,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#left(trim(form.stat_type), 20)#">,
                <cfqueryparam cfsqltype="CF_SQL_TINYINT" value="#val(form.points_scored)#">,
                <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#val(form.home_score)#">,
                <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#val(form.away_score)#">,
                <cfqueryparam cfsqltype="CF_SQL_TINYINT" value="#val(form.period)#">,
                <cfif len(trim(form.clock_remaining_seconds)) AND isNumeric(form.clock_remaining_seconds)>
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.clock_remaining_seconds)#">
                <cfelse>
                    NULL
                </cfif>,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#left(trim(form.local_play_id), 60)#">
            )
        </cfquery>

    <cfelseif form.action EQ "remove" AND len(trim(form.local_play_id)) AND val(form.scheduleID) GT 0>
        <cfquery datasource="roundleague">
            UPDATE game_plays
            SET is_removed = 1
            WHERE scheduleID  = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.scheduleID)#">
              AND local_play_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#left(trim(form.local_play_id), 60)#">
        </cfquery>
    </cfif>

    <cfoutput>{"ok":true}</cfoutput>
<cfcatch>
    <cfoutput>{"ok":false}</cfoutput>
</cfcatch>
</cftry>
