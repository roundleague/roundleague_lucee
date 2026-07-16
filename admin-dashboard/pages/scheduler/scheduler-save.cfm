<cfsilent>
<!--- Process inline game edit (swap teams / date / time) from scheduler.cfm --->
<cfparam name="form.editScheduleID" default="0">
<cfparam name="form.editHomeTeamID" default="0">
<cfparam name="form.editAwayTeamID" default="0">
<cfparam name="form.editDate" default="">
<cfparam name="form.editTime" default="">
<cfparam name="form.swapScheduleID" default="0">
<cfparam name="form.swapSide" default="">
<cfparam name="form.swapOriginalTeamID" default="0">

<cftry>
    <cfif NOT isNumeric(form.editScheduleID) OR form.editScheduleID EQ 0>
        <cfthrow message="Invalid game selected.">
    </cfif>

    <cfif NOT isNumeric(form.editHomeTeamID) OR NOT isNumeric(form.editAwayTeamID) OR form.editHomeTeamID EQ 0 OR form.editAwayTeamID EQ 0>
        <cfthrow message="Please select both a home and away team.">
    </cfif>

    <cfif form.editHomeTeamID EQ form.editAwayTeamID>
        <cfthrow message="Home and away team cannot be the same.">
    </cfif>

    <cfif NOT isDate(form.editDate) OR NOT len(form.editTime)>
        <cfthrow message="Please provide a valid date and time.">
    </cfif>

    <cfset doSwap = isNumeric(form.swapScheduleID) AND form.swapScheduleID GT 0>
    <cfif doSwap AND form.swapSide NEQ "home" AND form.swapSide NEQ "away">
        <cfthrow message="Invalid swap request.">
    </cfif>

    <cftransaction>
        <cfquery name="updateGame" datasource="roundleague">
            UPDATE schedule
            SET HomeTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.editHomeTeamID#">,
                AwayTeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.editAwayTeamID#">,
                Date = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#form.editDate#">,
                StartTime = <cfqueryparam cfsqltype="CF_SQL_TIME" value="#form.editTime#">
            WHERE ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.editScheduleID#">
            AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        </cfquery>

        <cfif doSwap>
            <cfset swapColumn = (form.swapSide EQ "home") ? "HomeTeamID" : "AwayTeamID">
            <cfquery datasource="roundleague">
                UPDATE schedule
                SET #swapColumn# = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.swapOriginalTeamID#">
                WHERE ScheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.swapScheduleID#">
                AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
            </cfquery>
        </cfif>
    </cftransaction>

    <cfset toastMsg = doSwap ? "Game updated and teams swapped successfully." : "Game updated successfully.">
    <cfset toastClass = "alert-success">

<cfcatch type="any">
    <cfset toastMsg = "Error: " & cfcatch.message>
    <cfset toastClass = "alert-danger">
</cfcatch>
</cftry>
</cfsilent>
