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
        <!--- The client only knows its own team's score for certain (read live from the
              DOM); the opponent's score depends on a socket push that can be stale or
              missed entirely (late join, reload, dropped connection). Override whichever
              side isn't this play's team with the authoritative, synchronously-updated
              value from the schedule row rather than trusting the client for it. --->
        <cfset homeScoreToSave = val(form.home_score)>
        <cfset awayScoreToSave = val(form.away_score)>
        <cfquery name="getCurrentScore" datasource="roundleague">
            SELECT HomeTeamID, AwayTeamID, HomeScore, AwayScore
            FROM schedule
            WHERE ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form.scheduleID)#">
        </cfquery>
        <cfif getCurrentScore.recordCount>
            <cfif val(form.teamID) EQ val(getCurrentScore.HomeTeamID)>
                <cfset awayScoreToSave = val(getCurrentScore.AwayScore)>
            <cfelseif val(form.teamID) EQ val(getCurrentScore.AwayTeamID)>
                <cfset homeScoreToSave = val(getCurrentScore.HomeScore)>
            </cfif>
        </cfif>
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
                <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#homeScoreToSave#">,
                <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#awayScoreToSave#">,
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
