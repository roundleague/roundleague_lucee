
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/admin-dashboard/pages/playerOfTheGame/playerOfTheGame.css?v=1.0" rel="stylesheet">
<!--- Modern sports fonts for canvas rendering --->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;500;600;700&family=Bebas+Neue&family=Barlow+Condensed:wght@600;700;800&display=swap" rel="stylesheet">

<!--- TODO: Change back to session.currentSeasonID before push --->
<cfset seasonID = 20>

<!--- Get all divisions for the current season --->
<cfquery name="getDivisions" datasource="roundleague">
  SELECT DivisionID, DivisionName
  FROM Divisions
  WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#seasonID#">
  ORDER BY DivisionName
</cfquery>

<!--- Get completed games (where scores exist) grouped by division --->
<cfquery name="getCompletedGames" datasource="roundleague">
  SELECT s.ScheduleID, s.Week, s.Date, s.StartTime,
         s.HomeTeamID, s.AwayTeamID, s.HomeScore, s.AwayScore,
         s.DivisionID,
         ht.teamName AS HomeTeamName,
         at.teamName AS AwayTeamName,
         d.DivisionName
  FROM Schedule s
  JOIN Teams ht ON s.HomeTeamID = ht.teamID
  JOIN Teams at ON s.AwayTeamID = at.teamID
  JOIN Divisions d ON s.DivisionID = d.DivisionID
  WHERE s.SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#seasonID#"> <!--- TODO: Change back to session.currentSeasonID before push --->
    AND s.HomeScore IS NOT NULL
    AND s.AwayScore IS NOT NULL
  ORDER BY d.DivisionName, s.Week DESC, s.Date DESC, s.StartTime DESC
</cfquery>

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <h4 class="card-title"><i class="nc-icon nc-image"></i> Player of the Game Generator</h4>
          <p class="card-category">Select a completed game to generate a Player of the Game graphic</p>
        </div>
        <div class="card-body">

          <!--- Division Filter --->
          <div class="form-group">
            <label for="divisionFilter"><strong>Filter by Division:</strong></label>
            <select id="divisionFilter" class="form-control" style="max-width: 300px;" onchange="filterByDivision(this.value)">
              <option value="all">All Divisions</option>
              <cfloop query="getDivisions">
                <option value="#getDivisions.DivisionID#">#getDivisions.DivisionName#</option>
              </cfloop>
            </select>
          </div>

          <!--- Games Table --->
          <div class="table-responsive">
            <table class="table table-striped" id="gamesTable">
              <thead>
                <tr>
                  <th>Division</th>
                  <th>Week</th>
                  <th>Date</th>
                  <th>Matchup</th>
                  <th>Score</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <cfloop query="getCompletedGames">
                  <cfset winnerTeamID = (getCompletedGames.HomeScore GT getCompletedGames.AwayScore) ? getCompletedGames.HomeTeamID : getCompletedGames.AwayTeamID>
                  <cfset winnerName = (getCompletedGames.HomeScore GT getCompletedGames.AwayScore) ? getCompletedGames.HomeTeamName : getCompletedGames.AwayTeamName>
                  <cfset homeBold = (getCompletedGames.HomeScore GT getCompletedGames.AwayScore) ? 'font-weight: bold;' : ''>
                  <cfset awayBold = (getCompletedGames.AwayScore GT getCompletedGames.HomeScore) ? 'font-weight: bold;' : ''>
                  <tr data-division="#getCompletedGames.DivisionID#">
                    <td>#getCompletedGames.DivisionName#</td>
                    <td>Week #getCompletedGames.Week#</td>
                    <td>#dateFormat(getCompletedGames.Date, "mmm d, yyyy")#</td>
                    <td>
                      <span style="#homeBold#">#getCompletedGames.HomeTeamName#</span>
                      vs
                      <span style="#awayBold#">#getCompletedGames.AwayTeamName#</span>
                    </td>
                    <td>
                      <span style="#homeBold#">#getCompletedGames.HomeScore#</span> -
                      <span style="#awayBold#">#getCompletedGames.AwayScore#</span>
                    </td>
                    <td>
                      <button type="button" class="btn btn-primary btn-sm generateBtn"
                        data-scheduleid="#getCompletedGames.ScheduleID#"
                        data-hometeam="#getCompletedGames.HomeTeamName#"
                        data-awayteam="#getCompletedGames.AwayTeamName#"
                        data-homescore="#getCompletedGames.HomeScore#"
                        data-awayscore="#getCompletedGames.AwayScore#"
                        data-hometeamid="#getCompletedGames.HomeTeamID#"
                        data-awayteamid="#getCompletedGames.AwayTeamID#"
                        data-winnerteamid="#winnerTeamID#"
                        data-winnername="#winnerName#"
                        onclick="generatePlayerOfTheGame(this)">
                        <i class="fa fa-magic"></i> Generate
                      </button>
                    </td>
                  </tr>
                </cfloop>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!--- Generated Image Preview Section --->
  <div class="row" id="previewSection" style="display: none;">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <h4 class="card-title"><i class="nc-icon nc-trophy"></i> Player of the Game</h4>
        </div>
        <div class="card-body text-center">
          <div id="loadingSpinner" style="display: none;">
            <i class="fa fa-spinner fa-spin fa-3x"></i>
            <p>Generating Player of the Game...</p>
          </div>
          <div id="canvasContainer">
            <canvas id="pogCanvas" width="540" height="680"></canvas>
          </div>
          <br>
          <button class="btn btn-success" onclick="downloadImage()">
            <i class="fa fa-download"></i> Download Image
          </button>
        </div>
      </div>
    </div>
  </div>
</div>
</cfoutput>

<script src="/admin-dashboard/pages/playerOfTheGame/playerOfTheGame.js?v=1.0"></script>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
