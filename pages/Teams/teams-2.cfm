<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="../Teams/teams-2.css">

<cfoutput>

<cfquery name="getNorthDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%North%'
  AND t.status = 'Active'
  ORDER BY divisionName
</cfquery>

<cfquery name="getSouthDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%South%'
  AND t.status = 'Active'
  ORDER BY divisionName
</cfquery>

<cfquery name="getEastDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%East%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<cfquery name="getWestDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%West%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<cfquery name="getPacificDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%Pacific%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<cfquery name="getWomensDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%Women%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<cfquery name="getPremierDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%Premier%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<cfquery name="getAsianDivision" datasource="roundleague">
  SELECT teamName, DivisionName, teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  Where t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND DivisionName LIKE '%Asian%'
  AND t.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">
  ORDER BY divisionName
</cfquery>

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <div class="standingsContainer">
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">North Division</h4>
              <ul class="standingsUl">
                <cfloop query="getNorthDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getNorthDivision.teamID#">#getNorthDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">South Division</h4>
              <ul class="standingsUl">
                <cfloop query="getSouthDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getSouthDivision.teamID#">#getSouthDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <!--- <div class="standingsDiv flex-item">
              <h4 class="standingsh4">Pacific Division</h4>
              <ul class="standingsUl">
                <cfloop query="getPacificDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getPacificDivision.teamID#">#getPacificDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div> --->
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">Premier Division</h4>
              <ul class="standingsUl">
                <cfloop query="getPremierDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getPremierDivision.teamID#">#getPremierDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
        </div>

        <div class="standingsContainer">
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">East Division</h4>
              <ul class="standingsUl">
                <cfloop query="getEastDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getEastDivision.teamID#">#getEastDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">West Division</h4>
              <ul class="standingsUl">
                <cfloop query="getWestDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getWestDivision.teamID#">#getWestDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">Asian Division</h4>
              <ul class="standingsUl">
                <cfloop query="getAsianDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getAsianDivision.teamID#">#getAsianDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
            <div class="standingsDiv flex-item">
              <h4 class="standingsh4">Women's Division</h4>
              <ul class="standingsUl">
                <cfloop query="getWomensDivision">
                  <li><a href="team-profile-page.cfm?teamID=#getWomensDivision.teamID#">#getWomensDivision.teamName#</a></li>
                </cfloop>
              </ul>
            </div>
        </div>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

