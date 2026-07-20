
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/admin-dashboard/pages/playerOfTheGame/playerOfTheGame.css?v=2.0" rel="stylesheet">
<!--- Modern sports fonts for canvas rendering --->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Oswald:wght@400;500;600;700&family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700;800;900&family=Montserrat:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

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

<!--- Get distinct weeks for filter --->
<cfquery name="getWeeks" dbtype="query">
  SELECT DISTINCT Week
  FROM getCompletedGames
  ORDER BY Week DESC
</cfquery>

<cfoutput>
<!-- End Navbar -->
<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>
  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <h4 class="card-title"><i class="nc-icon nc-image"></i> Player of the Game Generator</h4>
          <p class="card-category">Select a completed game to generate a Player of the Game graphic</p>
        </div>
        <div class="card-body">

          <!--- Division Filter --->
          <div class="form-group" style="display: inline-block; margin-right: 20px;">
            <label for="divisionFilter"><strong>Filter by Division:</strong></label>
            <select id="divisionFilter" class="form-control" style="max-width: 300px;" onchange="filterGames()">
              <option value="all">All Divisions</option>
              <cfloop query="getDivisions">
                <option value="#getDivisions.DivisionID#">#getDivisions.DivisionName#</option>
              </cfloop>
            </select>
          </div>

          <!--- Week Filter --->
          <div class="form-group" style="display: inline-block;">
            <label for="weekFilter"><strong>Filter by Week:</strong></label>
            <select id="weekFilter" class="form-control" style="max-width: 200px;" onchange="filterGames()">
              <option value="all">All Weeks</option>
              <cfloop query="getWeeks">
                <option value="#getWeeks.Week#">Week #getWeeks.Week#</option>
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
                  <tr data-division="#getCompletedGames.DivisionID#" data-week="#getCompletedGames.Week#">
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
            <canvas id="pogCanvas" width="1080" height="1350"></canvas>
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

<script src="/admin-dashboard/pages/playerOfTheGame/playerOfTheGame.js?v=2.0"></script>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
