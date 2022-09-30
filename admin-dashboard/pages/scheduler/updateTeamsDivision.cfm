<!--- Page Specific CSS/JS Here --->

<cfoutput>
    <!--- Right now it is only updating the one team, not swapping divisions like it should --->
	<cfset teamIDList = form.teamID>
	<cfloop list="#teamIDList#" index="count" item="i">
	    <cfquery name="updatePlayerData" datasource="roundleague">
	    	UPDATE teams
	    	SET divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.updateDivisionID#">
	    	WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">;
	    </cfquery>
	</cfloop>
</cfoutput>

