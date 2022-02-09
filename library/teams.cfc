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
</cfcomponent>