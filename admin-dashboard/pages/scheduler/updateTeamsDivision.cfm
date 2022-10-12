<!--- Page Specific CSS/JS Here --->

<cfoutput>
	<!--- Swaps divisions for selected teams --->
	<cfset teamIDList = form.teamID>
	<cfloop list="#teamIDList#" index="count" item="i">
		<cfset outgoingTeamID = form["teamID_" & count]>
		<cfset incomingTeamID = i>
		<cfquery name="getDivisionForTeamSwap" datasource="roundleague">
			SELECT divisionID
			FROM teams
			WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
		</cfquery>
		<cfif outgoingTeamID NEQ incomingTeamID>
		    <cfquery name="swapTeamDivisions" datasource="roundleague">
		    	<!--- Set incoming team to current division --->
		    	UPDATE teams
		    	SET divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.updateDivisionID#">
		    	WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#incomingTeamID#">;

		    	<!--- Send outgoing team to incoming team's division --->
		    	UPDATE teams
		    	SET divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getDivisionForTeamSwap.divisionID#">
		    	WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#outgoingTeamID#">;
		    </cfquery>
		</cfif>
	</cfloop>
</cfoutput>

