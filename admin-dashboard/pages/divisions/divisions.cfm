<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="divisions.css?v=1.1" rel="stylesheet">

<cfoutput>

<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Divisions</h3>
      <!--- Content goes here --->
      <div class="container">
        <div class="button-container">
            <button onclick="createNewTeam()">Create New Team</button>
            <button onclick="createNewDivision()">Create New Division</button>
        </div>
        <div class="teams-container">
            <div id="teams-no-divisions">
                <h3>Teams with no divisions</h3>

                <cfquery name="getTeamsNoDivision" datasource="roundleague">
                    SELECT teamId, teamName
                    FROM teams
                    WHERE STATUS = 'Active'
                    AND divisionID = 0
                </cfquery>

                <ul id="teams-list" class="teams-list">
                  <cfloop query="getTeamsNoDivision">
                      <li draggable="true" id="#teamId#" class="team-block teamNoDivision" ondragstart="drag(event)">#teamName#</li>
                  </cfloop>
				        </ul>
            </div>
        </div>
        
        <div class="divisions-container">
            <cfloop query="getDivisions">
                <!--- Get teams within division --->
                <cfquery name="getTeamsInDivision" datasource="roundleague">
                    SELECT teamName, DivisionName, teamID
                    FROM teams t
                    JOIN divisions d ON t.DivisionID = d.DivisionID
                    WHERE t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
                    AND DivisionName = <cfqueryparam cfsqltype="cf_sql_char" value="#getDivisions.DivisionName#">
                    AND t.status = 'Active'
                    ORDER BY divisionName
                </cfquery>

                <div id="#getDivisions.divisionID#" class="highlight-on-hover division" ondrop="drop(event)" ondragover="allowDrop(event)">
                    <h3>#getDivisions.divisionName#</h3>
                    <ul id="teams-list" class="teams-list">
                        <cfloop query="getTeamsInDivision">
                            <li draggable="true" id="#getTeamsInDivision.teamID#" class="team-block" ondragstart="drag(event)">#getTeamsInDivision.teamName#</li>
                        </cfloop>
                    </ul>
                </div>
            </cfloop>
        </div>

      </div>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/divisions/divisions.js"></script>
