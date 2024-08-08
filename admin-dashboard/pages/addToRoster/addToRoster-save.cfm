<cfoutput>

<cfquery name="updateRosterRecord" datasource="roundleague">
    UPDATE roster
    SET teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.newTeamID#">
    WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.playerID#">
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>


<!-- The actual snackbar -->
<div id="snackbar">Player has been added to roster.</div>

</cfoutput>
