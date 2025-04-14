
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../addToRoster/addToRoster.css?v=1.6" rel="stylesheet">
<link href="/admin-dashboard/assets/css/toast.css" rel="stylesheet">


<cfoutput>

<!--- Confirm stat swap clicked, now do the update to swap the stats --->
<cfif isDefined("form.newTeamID")>
  <cfinclude template="addToRoster-save.cfm">
</cfif>

<cfquery name="playerQuery" datasource="roundleague">
  WITH ranked_players AS (
    SELECT 
      CONCAT(p.firstName, ' ', p.lastName) AS playerName,
      p.playerID,
      COALESCE(t.teamName, 'Free Agent') AS teamName,
      ROW_NUMBER() OVER (
        PARTITION BY CONCAT(p.firstName, ' ', p.lastName)
        ORDER BY 
          CASE 
            WHEN t.teamName IS NULL THEN 1  -- 'Free Agent'
            ELSE 0                          -- real team
          END
      ) AS rn
    FROM players p
    JOIN roster r ON r.playerID = p.playerID
    LEFT JOIN teams t ON t.teamId = r.teamID AND t.status = 'Active'
    WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  )
  
  SELECT playerName, playerID, teamName
  FROM ranked_players
  WHERE rn = 1
  ORDER BY playerName
</cfquery>


<script>
  var playerList = [
        <cfoutput query="playerQuery">
      { playerName: "#JSStringFormat(playerName)#", playerID: "#playerID#", playerTeam: "#teamName#" },
    </cfoutput>
  ];
</script>

<!--- Waiver Modal --->
    <div class="modal fade" id="confirmStatModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title text-center" id="exampleModalLabel">Confirm Roster Addition</h5>
          </div>
          <div class="modal-body"> 
            <div class="playerToConfirm"><b>Player: </b><span class="playerFromConfirmText"></span></div>
            <div class="playerFromConfirm"><b>New Team: </b><span class="teamToConfirm"></span></div>
            <br>
            <div class="errorMsg">Please provide a player and to team for the roster transaction.</div>
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
      <h3 class="description">Add Player to Roster</h3>
      <form method="POST" class="addToRosterForm">
        <p>Free agents and current players are included in this list.</p>
      <div class="row">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <label>Player to add</label>
            <input type="text" id="searchBox" onkeyup="fetchResults()" autocomplete="off" required class="form-control border-input" placeholder="Start typing player name..." name="playerFrom" required>
        <div id="autocompleteResults"></div>
          </div>
        </div>
      </div>

      <div class="row selectGame">
        <div class="col-md-6 col-sm-6">
          <div class="form-group">
            <label>Select Team</label>
            <select id="teamSelector"></select>
          </div>
        </div>
      </div>

      <input type="hidden" name="playerID" class="playerID" value="">
      <input type="hidden" name="newTeamID" class="newTeamID" value="">
      <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##confirmStatModal">
        Submit
      </button>
    </form>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="../addToRoster/addToRoster.js?v=1.0.0"></script>