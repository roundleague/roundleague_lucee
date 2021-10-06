<cfquery name="getPlayers" datasource="roundleague">
	SELECT firstName, lastName, playerID, team
	FROM players p
	WHERE p.playerID NOT IN 
	(SELECT playerID FROM roster)
	AND p.team IS NOT NULL
	AND p.team NOT LIKE '%N/A%'
	AND p.team NOT LIKE '%na%'
</cfquery>

<cfdump var="#getPlayers#" />

<cfquery name="insertRoster" datasource="roundleague" result="insertResult">
		INSERT INTO Roster (PlayerID, TeamID, SeasonID, DivisionID)
		VALUES 
			<cfloop query="getPlayers">
				<cfset teamString = getPlayers.team>
				<cfif findNoCase("eddie", teamString)>
					<cfset teamString = "eddie">
				<cfelseif findNoCase("murray", teamString)>
					<cfset teamString = "murray">
				<cfelseif findNoCase("crossin", teamString)>
					<cfset teamString = "crossin">
				<cfelseif findNoCase("kareem", teamString)>
					<cfset teamString = "kareem">
				</cfif>
			(
				#getPlayers.playerID#,
				(SELECT teamID FROM teams WHERE teamName LIKE '%#teamString#%'),
				3,
				(SELECT divisionID FROM teams WHERE teamName LIKE '%#teamString#%')
			)<cfif getPlayers.currentRow NEQ getPlayers.recordCount>,</cfif>
			</cfloop>
</cfquery>

<cfdump var="#insertResult#" />