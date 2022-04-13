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
		SELECT r.playerID, 
		points, 
		rebounds,
		assists,
		steals,
		blocks,
		turnovers,
		s.seasonName,
		t.teamName
		FROM playerstats ps
		JOIN seasons s on ps.seasonID = s.seasonID
		JOIN roster r ON r.playerID = ps.playerID AND r.seasonID = s.seasonID
		JOIN teams t on t.teamID = r.teamID
		WHERE r.playerID = <cfqueryparam cfsqltype="INTEGER" value="#playerID#">
   </cfquery>
   <cfreturn careerStats>
 </cffunction>
</cfcomponent>