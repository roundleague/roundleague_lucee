<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Standings/purekitpro.css" rel="stylesheet" />
<link href="/pages/Standings/standings_divisions.css?v=1.0" rel="stylesheet" />

<cfquery name="getActive" datasource="roundleague">
	SELECT SeasonID 
	From Seasons 
	Where Status = 'Active'
</cfquery>

<cfquery name="getDivisions" datasource="roundleague">
	SELECT DivisionID, DivisionName
	FROM Divisions
	Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActive.SeasonID#">
</cfquery>

<cfparam name="form.seasonID" default="#getActive.seasonID#">
<cfparam name="form.divisionID" default="#getDivisions.divisionID#">

<cfquery name="getStandings" datasource="roundleague">
	SELECT teamName, t.TeamID, Wins, Losses, t.DivisionID, sea.SeasonName, s.PointDifferential, d.divisionName
	FROM teams t
	JOIN standings s ON t.teamId = s.teamID
	JOIN seasons sea on sea.seasonID = s.seasonID
	JOIN divisions d ON d.divisionID = t.divisionID
	WHERE s.SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getActive.seasonID#">
	AND s.divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
	ORDER BY wins desc, PointDifferential desc
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
<form method="POST">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<label for="DivisionID">Division</label>
		<select name="DivisionID" id="Divisions" onchange="this.form.submit()">
			<cfloop query="getDivisions">
				<option value="#getDivisions.DivisionID#"<cfif getDivisions.DivisionID EQ form.DivisionID> selected</cfif>>#getDivisions.DivisionName#</option>
			</cfloop>
		</select>

        <h1>#getStandings.DivisionName#</h1> <!--- Should show latest Season name --->

        <table class="bolder">
          <caption>Standings</caption>
          <thead>
            <tr>
            	<th>Rank</th>
            	<th>Team</th>
            	<th>Wins</th>
            	<th>Losses</th>
            	<th>Point Differential</th>
            </tr>
          </thead>
          <tbody>
          	<cfloop query="getStandings">
	            <tr>
	            	<td data-label="Rank">#getStandings.currentRow#</td>
	            	<td data-label="Team"><a class="boldClass" href="/pages/teams/team-profile-page.cfm?teamID=#getStandings.teamID#">#TeamName#</a></td>
	            	<td data-label="Wins">#Wins#</td>
	            	<td data-label="Losses">#Losses#</td>
	            	<td data-label="PointDiff">#PointDifferential#</td>
	            </tr>
        	</cfloop>
          </tbody>
        </table>

      </div>
    </div>
</form>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

