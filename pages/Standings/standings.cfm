<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Standings/purekitpro.css" rel="stylesheet" />

<cfquery name="getSeasons" datasource="roundleague">
	SELECT SeasonID, SeasonName
	FROM Seasons
	ORDER BY SeasonID desc
</cfquery>

<cfparam name="form.seasonID" default="#session.currentSeasonID#">

<cfquery name="getStandings" datasource="roundleague">
	SELECT teamName, t.TeamID, Wins, Losses, t.DivisionID, sea.SeasonName, s.PointDifferential
	FROM teams t
	JOIN standings s ON t.teamId = s.teamID
	JOIN seasons sea on sea.seasonID = s.seasonID
	WHERE s.SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.seasonID#">
	ORDER BY wins desc, PointDifferential
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
<form method="POST">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<label for="seasonID">Season</label>
		<select name="seasonID" id="Seasons" onchange="this.form.submit()">
			<cfloop query="getSeasons">
				<option value="#getSeasons.SeasonID#"<cfif getSeasons.SeasonID EQ form.seasonID> selected</cfif>>#getSeasons.SeasonName#</option>
			</cfloop>
		</select>

        <h1>#getStandings.SeasonName#</h1> <!--- Should show latest Season name --->

        <table>
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
	            	<td data-label="Team">#TeamName#</td>
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

