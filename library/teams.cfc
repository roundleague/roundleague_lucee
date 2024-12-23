<!--- Teams Component --->
<cfcomponent displayname="Teams" hint="ColdFusion Component for Teams">
 <cffunction name="getOpponent"
	hint="Get opponent based on 3 teams" returntype="string">
	<cfargument name="homeTeam" default="" required="yes" type="string">
	<cfargument name="awayTeam" default="" required="yes" type="string">
	<cfargument name="userTeam" default="" required="yes" type="string">

		<cfif homeTeam EQ userTeam>
			<cfreturn awayTeam>
		<cfelseif awayTeam EQ userTeam>
			<cfreturn homeTeam>
		<cfelse>
			<cfreturn ''>
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
		    AND t.status = 'Active'
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

  <cffunction name="getTeamNameByTeamID"
	hint="Get team name by teamID" returntype="string">
	<cfargument name="teamID" default="" required="yes" type="numeric">

		<cfquery name="getTeam" datasource="roundleague">
		    SELECT teamName
		    FROM teams
		    WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamID#">
		</cfquery>

		<cfreturn getTeam.teamName>
		
 </cffunction>

 <cffunction name="addTeam" access="remote" returntype="struct" hint="Add a new team to the database">
        <cfargument name="teamName" required="yes" type="string">
        <cfargument name="division" required="yes" type="string">
        <cfargument name="level" required="yes" type="string">
        <cfargument name="dayPreference" required="yes" type="string">
        <cfargument name="primaryTime" required="yes" type="string">
        <cfargument name="secondaryTime" required="yes" type="string">

        <cfset var result = {}>

        <cftry>
            <cfquery name="insertTeam" datasource="roundleague">
                INSERT INTO teams (teamName, registerDate, status, dayPreference, primaryTimePreference, secondaryTimePreference)
                VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.teamName#">,
                    <cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Active">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.dayPreference#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.primaryTime#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.secondaryTime#">
                )
            </cfquery>

			<cfquery name="updatePendingStatusToActive" datasource="roundleague">
				UPDATE pending_teams
				SET status = 'Active'
				WHERE teamName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.teamName#">
			</cfquery>

			<!--- Do we need insert for division, level, day preference --->

            <cfset result.success = true>
            <cfset result.message = "Team added successfully">
        <cfcatch>
            <cfset result.success = false>
            <cfset result.message = "Error adding team: " & cfcatch.message>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>
</cfcomponent>