<cfsilent>
<!--- Process Schedule Import --->
<cfparam name="form.divisionID" default="0">
<cfparam name="form.scheduleData" default="">
<cfparam name="form.clearExisting" default="0">

<cfset importCount = 0>
<cfset errorCount = 0>

<cftry>
    <!--- Validate division ID --->
    <cfif NOT isNumeric(form.divisionID) OR form.divisionID EQ 0>
        <cfthrow message="Invalid division selected.">
    </cfif>
    
    <!--- Parse the JSON data --->
    <cfif NOT isJSON(form.scheduleData)>
        <cfthrow message="Invalid schedule data format.">
    </cfif>
    
    <cfset games = deserializeJSON(form.scheduleData)>
    
    <cfif NOT isArray(games) OR arrayLen(games) EQ 0>
        <cfthrow message="No valid games to import.">
    </cfif>
    
    <!--- Clear existing schedule if requested --->
    <cfif form.clearExisting EQ 1>
        <cfquery name="clearSchedule" datasource="roundleague">
            DELETE FROM schedule
            WHERE divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
            AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        </cfquery>
    </cfif>
    
    <!--- Insert each game --->
    <cfloop array="#games#" index="game">
        <cftry>
            <cfquery name="insertGame" datasource="roundleague">
                INSERT INTO schedule (HomeTeamID, AwayTeamID, Week, StartTime, Date, DivisionID, SeasonID)
                VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.homeTeamID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.awayTeamID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#game.week#">,
                    <cfqueryparam cfsqltype="CF_SQL_TIME" value="#game.time#">,
                    <cfqueryparam cfsqltype="CF_SQL_DATE" value="#game.date#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
                )
            </cfquery>
            <cfset importCount++>
        <cfcatch>
            <cfset errorCount++>
        </cfcatch>
        </cftry>
    </cfloop>
    
    <cfset toastMsg = "Successfully imported #importCount# games!">
    <cfif errorCount GT 0>
        <cfset toastMsg &= " (#errorCount# failed)">
    </cfif>
    <cfset toastClass = "alert-success">

<cfcatch type="any">
    <cfset toastMsg = "Error: " & cfcatch.message>
    <cfset toastClass = "alert-danger">
</cfcatch>
</cftry>
</cfsilent>
