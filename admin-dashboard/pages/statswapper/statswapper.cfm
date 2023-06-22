
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../statswapper/statswapper.css?v=1.5" rel="stylesheet">
<link href="/admin-dashboard/assets/css/toast.css" rel="stylesheet">

<cfquery name="playerQuery" datasource="roundleague">
  SELECT CONCAT(firstName, ' ', lastName) AS playerName, p.playerID, t.teamName
  FROM players p
  JOIN roster r ON r.playerID = p.playerID
  JOIN teams t ON t.teamId = r.teamID
  WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND r.teamID != 0
  AND t.status = 'Active'
  ORDER BY lastName
</cfquery>

<script>
  var playerList = [
        <cfoutput query="playerQuery">
      { playerName: "#JSStringFormat(playerName)#", playerID: "#playerID#", playerTeam: "#teamName#" },
    </cfoutput>
  ];
</script>


<cfoutput>

<!--- Confirm stat swap clicked, now do the update to swap the stats --->
<cfif isDefined("form.fromPlayer")>
  <cfinclude template="statswapper-save.cfm">
</cfif>

<!--- Waiver Modal --->
    <div class="modal fade" id="confirmStatModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title text-center" id="exampleModalLabel">Confirm Player Stat Swap</h5>
          </div>
          <div class="modal-body"> 
            <div class="playerToConfirm">Player to remove stats from: <span class="playerFromConfirmText"></span></div>
            <div class="statsConfirm">
                    <table class="statsTableConfirm">
                      <tr>
                        <th>Points</th>
                        <th>Rebounds</th>
                        <th>Assists</th>
                      </tr>
                      <tr>
                        <td><span class="points"></span></td>
                        <td><span class="rebounds"></span></td>
                        <td><span class="assists"></span></td>
                      </tr>
                   </table>
            </div>
            <div class="playerFromConfirm">Player to move stats to: <span class="playerToConfirmText"></span></div>
          </div>
          <div class="modal-footer">
            <div class="left-side">
              <button type="button" class="btn btn-default btn-link confirmBtn" data-dismiss="modal">Confirm</button>
            </div>
          </div>
        </div>
      </div>
    </div>

<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Stat Swapper 1.0</h3>
      <form method="POST" class="statSwapForm">
      <div class="row">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <label>Player to remove stats from</label>
            <input type="text" id="searchBox" onkeyup="fetchResults()" autocomplete="off" required class="form-control border-input" placeholder="Start typing player name..." name="playerFrom" required>
        <div id="autocompleteResults"></div>
          </div>
        </div>
      </div>

      <div class="row selectGame">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <label>Select Game</label>
            <select id="gameSelector" onchange="populateStatsTable(this.value)"></select>
          </div>
        </div>
      </div>

      <div class="row statsTableWrapper">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <table class="statsTable">
              <tr>
                <th>Points</th>
                <th>Rebounds</th>
                <th>Assists</th>
              </tr>
              <tr>
                <td><span class="points"></span></td>
                <td><span class="rebounds"></span></td>
                <td><span class="assists"></span></td>
              </tr>
           </table>
          </div>
        </div>
      </div>

      <div class="row playerToWrapper">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <label>Player to move stats to</label>
            <input type="text" id="searchBoxTo" onkeyup="fetchResultsTo()" autocomplete="off" required class="form-control border-input" placeholder="Start typing player name..." name="playerTo" required>
        <div id="autocompleteResultsTo"></div>
          </div>
        </div>
      </div>
      <input type="hidden" name="fromPlayer" class="fromPlayer" value="">
      <input type="hidden" name="toPlayer" class="toPlayer" value="">
      <input type="hidden" name="playerGameLogID" class="playerGameLogID" value="">
      <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##confirmStatModal">
        Submit
      </button>
    </form>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="../statswapper/statswapper.js?v=1.0.3"></script>