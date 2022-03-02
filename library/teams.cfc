<!--- Teams Component --->
<cfcomponent displayname="Teams" hint="ColdFusion Component for Teams">
 <cffunction name="getOpponent"
	hint="Get opponent based on 3 teams" returntype="string">
	<cfargument name="homeTeam" default="" required="yes" type="string">
	<cfargument name="awayTeam" default="" required="yes" type="string">
	<cfargument name="userTeam" default="" required="yes" type="string">

		<cfif homeTeam EQ userTeam>
			<cfreturn awayTeam>
		<cfelse>
			<cfreturn homeTeam>
		</cfif>
		
 </cffunction>

 <cffunction name="getCurrentSessionTeam"
	hint="Get current session team based on logged in sessionID" returntype="struct">
	<cfargument name="playerID" default="" required="yes" type="numeric">

		<cfquery name="getTeam" datasource="roundleague">
		    SELECT t.teamName, t.teamID
		    FROM players p
		    JOIN roster r on r.playerID = p.playerID
		    JOIN teams t on t.teamID = r.teamID 
		    WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
		    AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#playerID#">
		</cfquery>

		<cfset teamObject = {
		  teamName = getTeam.teamName,
		  teamID = getTeam.teamID
		}>

		<cfreturn teamObject>
		
 </cffunction>

 <cffunction name="updateTeamStatus" returntype="any" access="remote">
 	<cfargument name="status" default="" required="yes" type="string">
 	<cfargument name="teamID" default="" required="yes" type="numeric">

 		<!--- <cftry>
 			<cfquery name="updateStatus" datasource="roundleague">
 				UPDATE Teams
 				SET status = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#status#">
 				WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamID#">
 			</cfquery>

 			<cfcatch>
 				<cfreturn cfcatch.message>
 			</cfcatch>
 		</cftry> --->

 		<cfreturn 'Success'>
 </cffunction> 
</cfcomponent>