<!--- Player-Profile Component --->
<cfcomponent displayname="Player-Profile" hint="ColdFusion Component for Player-Profile">
 <!--- This function retrieves all customers from the database --->
 <cffunction name="getCareerStats"
	hint="Get Career Stats" returntype="query">
	<cfargument 
	name="playerID" 
	default="0" 
	required="yes" 
	type="string">
   <cfquery name="careerStats" datasource="roundleague">
		SELECT playerID, 
		Truncate(AVG(points), 1) AS points, 
		Truncate(AVG(rebounds), 1) AS rebounds,
		Truncate(AVG(assists), 1) AS assists,
		Truncate(AVG(steals), 1) AS steals,
		Truncate(AVG(blocks), 1) AS blocks,
		Truncate(AVG(turnovers), 1) AS turnovers
		FROM playerstats 
		WHERE playerID = <cfqueryparam cfsqltype="INTEGER" value="#playerID#">
		GROUP BY playerID;
   </cfquery>
   <cfreturn careerStats>
 </cffunction>
</cfcomponent>