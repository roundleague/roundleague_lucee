<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>

<cfquery name="getEastDivisionTeams" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID IN (4,6)
  ORDER BY divisionName
</cfquery>

<cfquery name="getWestDivisionTeams" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID IN (3,5)
  ORDER BY divisionName
</cfquery>

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <table>
          <caption>South / East Divisions</caption>
          <tbody>
            <tr>
              <cfloop query="getEastDivisionTeams">
                <td data-label="Team"><a href="team-profile-page.cfm?teamID=#getEastDivisionTeams.teamID#">#getEastDivisionTeams.teamName#</a></td>
              </cfloop>
            </tr>
          </tbody>
        </table>

        <table>
          <caption>North / West Divisions</caption>
          <tbody>
            <tr>
              <cfloop query="getWestDivisionTeams">
                <td data-label="Team"><a href="team-profile-page.cfm?teamID=#getWestDivisionTeams.teamID#">#getWestDivisionTeams.teamName#</a></td>
              </cfloop>
            </tr>
          </tbody>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

