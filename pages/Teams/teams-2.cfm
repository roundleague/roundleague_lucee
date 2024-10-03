<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link rel="stylesheet" href="../Teams/teams-2.css">

<cfoutput>

<cfquery name="getActiveDivisions" datasource="roundleague">
  SELECT d.DivisionName, t.teamName, t.teamID
  FROM teams t
  JOIN divisions d ON t.DivisionID = d.DivisionID
  WHERE t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND t.status = 'Active'
  ORDER BY d.DivisionName, t.teamName
</cfquery>

<cfset divisionArray = ListToArray(ValueList(getActiveDivisions.DivisionName)) />

<!-- Create a new array to hold unique divisions -->
<cfset uniqueDivisions = ArrayNew(1) />

<!-- Loop through divisionArray and add unique items to uniqueDivisions -->
<cfloop index="i" from="1" to="#ArrayLen(divisionArray)#">
  <cfif ArrayContains(uniqueDivisions, divisionArray[i]) EQ false>
    <cfset ArrayAppend(uniqueDivisions, divisionArray[i]) />
  </cfif>
</cfloop>

<!-- Now we calculate the total number of unique divisions -->
<cfset totalDivisions = ArrayLen(uniqueDivisions) />

<!-- Safely get the first 1 to 4 divisions -->
<cfset firstFourDivisions = ArraySlice(uniqueDivisions, 1, Min(4, totalDivisions)) />

<!-- Safely get the next 5 to 8 divisions only if they exist -->
<cfif totalDivisions GT 4>
  <cfset startPosition = 5 />
  <cfset lastFourDivisions = ArraySlice(uniqueDivisions, startPosition, Min(4, totalDivisions - 4)) />
<cfelse>
  <cfset lastFourDivisions = [] /> <!-- If no last divisions exist -->
</cfif>

<cfquery name="first4Divisions" dbtype="query">
  SELECT *
  FROM getActiveDivisions
  WHERE DivisionName IN (<cfqueryparam value="#firstFourDivisions#" cfsqltype="CF_SQL_VARCHAR" list="true">)
</cfquery>

<cfquery name="last4Divisions" dbtype="query">
  SELECT *
  FROM getActiveDivisions
  WHERE DivisionName IN (<cfqueryparam value="#lastFourDivisions#" cfsqltype="CF_SQL_VARCHAR" list="true">)
</cfquery>


<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

      <!--- Loop through divisions and output 4 divisions at a time --->
      <div class="standingsContainer topBlock">
        <cfif first4Divisions.recordCount>
          <cfset currentDivision = "">
          <cfoutput query="first4Divisions">
            <!-- Check if the division has changed -->
            <cfif currentDivision neq first4Divisions.DivisionName>
              <!-- Close previous division's UL if it's not the first division -->
              <cfif currentDivision neq "">
                </ul>
              </div>
              </cfif>

              <!-- Start a new division block -->
              <div class="standingsDiv flex-item">
                <h4 class="standingsh4">#first4Divisions.DivisionName#</h4>
                <ul class="standingsUl">
              <!-- Update the current division -->
              <cfset currentDivision = first4Divisions.DivisionName>
            </cfif>

            <!-- List the team under the current division -->
            <li>
              <a href="team-profile-page.cfm?teamID=#first4Divisions.teamID#">#first4Divisions.teamName#</a>
            </li>

          </cfoutput>

          <!-- Close the last division's UL -->
          </ul>
          </div>
        </cfif>
      </div>

      <div class="standingsContainer bottomblock">
        <cfif last4Divisions.recordCount>
          <cfset currentDivision = "">
          <cfoutput query="last4Divisions">
            <!-- Check if the division has changed -->
            <cfif currentDivision neq last4Divisions.DivisionName>
              <!-- Close previous division's UL if it's not the first division -->
              <cfif currentDivision neq "">
                </ul>
              </div>
              </cfif>

              <!-- Start a new division block -->
              <div class="standingsDiv flex-item">
                <h4 class="standingsh4">#last4Divisions.DivisionName#</h4>
                <ul class="standingsUl">
              <!-- Update the current division -->
              <cfset currentDivision = last4Divisions.DivisionName>
            </cfif>

            <!-- List the team under the current division -->
            <li>
              <a href="team-profile-page.cfm?teamID=#last4Divisions.teamID#">#last4Divisions.teamName#</a>
            </li>

          </cfoutput>

          <!-- Close the last division's UL -->
          </ul>
          </div>
        </cfif>
      </div>
      <!--- End looping through divisions --->

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

