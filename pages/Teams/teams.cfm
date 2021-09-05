<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/teams.css" rel="stylesheet" />

<cfoutput>

<cfquery name="getEastDivisionTeams" datasource="roundleague">
  SELECT teamName, DivisionName
  FROM teams t
  JOIN divisions d ON t.CurrentDivisionID = d.DivisionID
  WHERE DIVISIONNAME = 'Eastern Conference'
  ORDER BY divisionName
</cfquery>

<cfquery name="getWestDivisionTeams" datasource="roundleague">
  SELECT teamName, DivisionName
  FROM teams t
  JOIN divisions d ON t.CurrentDivisionID = d.DivisionID
  WHERE DIVISIONNAME = 'Western Conference'
  ORDER BY divisionName
</cfquery>

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <table>
          <caption>Eastern Conference</caption>
          <tbody>
            <tr>
              <cfloop query="getEastDivisionTeams">
                <td data-label="Team">#getEastDivisionTeams.teamName#</td>
              </cfloop>
            </tr>
          </tbody>
        </table>

        <table>
          <caption>Western Conference</caption>
          <tbody>
            <tr>
              <cfloop query="getWestDivisionTeams">
                <td data-label="Team">#getWestDivisionTeams.teamName#</td>
              </cfloop>
            </tr>
          </tbody>
        </table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

