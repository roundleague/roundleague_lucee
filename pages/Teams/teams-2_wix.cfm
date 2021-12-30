<cfinclude template="/header_wix.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="../Teams/teams-2.css">

<cfoutput>

<cfquery name="getNorthDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID = 5
  ORDER BY divisionName
</cfquery>

<cfquery name="getSouthDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID = 6
  ORDER BY divisionName
</cfquery>

<cfquery name="getEastDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID = 4
  ORDER BY divisionName
</cfquery>

<cfquery name="getWestDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.DivisionID = 3
  ORDER BY divisionName
</cfquery>

<div class="main" style="background-color: white;">
    <div class="section text-center" style="padding-top: 20px">
      <div class="container">

        Check back later for the 2021 Winter Season Teams!

<!---         <div class="standingsContainer">
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">North Division</h4>
              <ul class="standingsUl">
                <cfloop query="getNorthDivision">
                  <li><a href="team-profile-page_wix.cfm?teamID=#getNorthDivision.teamID#">#getNorthDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">South Division</h4>
              <ul class="standingsUl">
                <cfloop query="getSouthDivision">
                  <cfif getSouthDivision.teamID EQ 27>
                    <li>#getSouthDivision.teamName#</li>
                  <cfelse>
                    <li><a href="team-profile-page_wix.cfm?teamID=#getSouthDivision.teamID#">#getSouthDivision.teamName#</a></li>
                  </cfif>
                </cfloop>
              </ul>
            </div>
        </div>

        <div class="standingsContainer">
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">East Division</h4>
              <ul class="standingsUl">
                <cfloop query="getEastDivision">
                  <li><a href="team-profile-page_wix.cfm?teamID=#getEastDivision.teamID#">#getEastDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">West Division</h4>
              <ul class="standingsUl">
                <cfloop query="getWestDivision">
                  <li><a href="team-profile-page_wix.cfm?teamID=#getWestDivision.teamID#">#getWestDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
        </div> --->

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer_wix.cfm">

