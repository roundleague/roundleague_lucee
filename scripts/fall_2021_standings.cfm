<cfquery name="getTeams" datasource="roundleague">
	SELECT teamID, teamName, divisionID
	FROM teams
	WHERE seasonID = 3
</cfquery>

<cfdump var="#getTeams#" />

<cfquery name="insertStandings" datasource="roundleague" result="insertResult">
		INSERT INTO Standings (TeamID, SeasonID, DivisionID)
		VALUES 
			<cfloop query="getTeams">
			(
				#getTeams.teamID#,
				3,
				#getTeams.divisionID#
			)<cfif getTeams.currentRow NEQ getTeams.recordCount>,</cfif>
			</cfloop>
</cfquery>

<cfdump var="#insertResult#" />