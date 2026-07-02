
      <cfinclude template="admin_header.cfm">

      <link href="/admin-dashboard/dashboard.css?v=1.0" rel="stylesheet">

      <cfquery name="seasonInfo" datasource="roundleague">
        SELECT SeasonName
        FROM seasons
        WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cfquery name="teamsCount" datasource="roundleague">
        SELECT COUNT(*) AS cnt
        FROM teams
        WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cfquery name="playersCount" datasource="roundleague">
        SELECT COUNT(DISTINCT PlayerID) AS cnt
        FROM roster
        WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cfquery name="divisionsCount" datasource="roundleague">
        SELECT COUNT(*) AS cnt
        FROM divisions
        WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
      </cfquery>

      <!-- End Navbar -->
      <div class="content">

        <div class="row">
          <div class="col-md-12">
            <div class="card">
              <div class="card-body dashboard-welcome">
                <p class="card-category">Here's what's happening this season.</p>
              </div>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
              <div class="card-body">
                <div class="row">
                  <div class="col-5 col-md-4">
                    <div class="icon-big text-center icon-info">
                      <i class="nc-icon nc-bank text-info"></i>
                    </div>
                  </div>
                  <div class="col-7 col-md-8">
                    <div class="numbers">
                      <p class="card-category">Current Season</p>
                      <cfoutput><p class="card-title">#htmlEditFormat(seasonInfo.SeasonName)#</p></cfoutput>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
              <div class="card-body">
                <div class="row">
                  <div class="col-5 col-md-4">
                    <div class="icon-big text-center icon-success">
                      <i class="nc-icon nc-bullet-list-67 text-success"></i>
                    </div>
                  </div>
                  <div class="col-7 col-md-8">
                    <div class="numbers">
                      <p class="card-category">Teams</p>
                      <cfoutput><p class="card-title">#teamsCount.cnt#</p></cfoutput>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
              <div class="card-body">
                <div class="row">
                  <div class="col-5 col-md-4">
                    <div class="icon-big text-center icon-primary">
                      <i class="nc-icon nc-single-02 text-primary"></i>
                    </div>
                  </div>
                  <div class="col-7 col-md-8">
                    <div class="numbers">
                      <p class="card-category">Registered Players</p>
                      <cfoutput><p class="card-title">#playersCount.cnt#</p></cfoutput>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
              <div class="card-body">
                <div class="row">
                  <div class="col-5 col-md-4">
                    <div class="icon-big text-center icon-warning">
                      <i class="nc-icon nc-paper text-warning"></i>
                    </div>
                  </div>
                  <div class="col-7 col-md-8">
                    <div class="numbers">
                      <p class="card-category">Divisions</p>
                      <cfoutput><p class="card-title">#divisionsCount.cnt#</p></cfoutput>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-md-12">
            <div class="card">
              <div class="card-header">
                <h4 class="card-title">Quick Actions</h4>
              </div>
              <div class="card-body">
                <div class="tools-grid">

                  <a href="/admin-dashboard/pages/divisions/divisions.cfm" class="tool-card">
                    <i class="nc-icon nc-bank"></i>
                    <p>Divisions</p>
                  </a>

                  <a href="/admin-dashboard/pages/playerLookup/playerLookup.cfm" class="tool-card">
                    <i class="nc-icon nc-pin-3"></i>
                    <p>Player Info Lookup</p>
                  </a>

                  <a href="/admin-dashboard/pages/teamsOverview/teamsOverview.cfm" class="tool-card">
                    <i class="nc-icon nc-bullet-list-67"></i>
                    <p>Teams Overview</p>
                  </a>

                  <a href="/admin-dashboard/pages/teamFinances/teamFinances.cfm" class="tool-card">
                    <i class="nc-icon nc-money-coins"></i>
                    <p>Team Finances</p>
                  </a>

                  <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="tool-card">
                    <i class="nc-icon nc-grid-45"></i>
                    <p>More Tools</p>
                  </a>

                </div>
              </div>
            </div>
          </div>
        </div>

      </div>

      <cfinclude template="admin_footer.cfm">
