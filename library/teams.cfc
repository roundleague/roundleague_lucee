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
	hint="Get current session team based on logged in sessionID" returntype="string">
	<cfargument name="playerID" default="" required="yes" type="numeric">

		<cfquery name="getTeam" datasource="roundleague">
		    SELECT t.teamName
		    FROM players p
		    JOIN roster r on r.playerID = p.playerID
		    JOIN teams t on t.teamID = r.teamID 
		    WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
		    AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#playerID#">
		</cfquery>

		<cfreturn getTeam.teamName>
		
 </cffunction> 
</cfcomponent>