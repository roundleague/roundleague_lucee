<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="../mergeAccounts/mergeAccounts.css?v=1.0" rel="stylesheet">
<link href="/admin-dashboard/assets/css/toast.css" rel="stylesheet">

<!--- Merge Preview Modal --->
<div class="modal fade" id="mergeModal" tabindex="-1" role="dialog" aria-labelledby="mergeModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="mergeModalLabel">Review Merge</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div id="previewContent"></div>
        <div id="swapSection" class="swap-section" style="display:none;">
          <strong>Switch which account to keep?</strong>&nbsp;
          <label><input type="radio" name="swapPlayers" id="swapNo" value="no" checked> No, keep as shown</label>
          <label><input type="radio" name="swapPlayers" id="swapYes" value="yes"> Yes, swap KEEP and MERGE FROM</label>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default btn-link" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger" id="confirmMergeBtn" style="display:none;">Confirm Merge</button>
      </div>
    </div>
  </div>
</div>

<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Merge Player Accounts</h3>
      <p class="text-muted">Search for two player accounts and merge their history. All game logs, season stats, and roster records from the <strong>MERGE FROM</strong> account will be transferred to the <strong>KEEP</strong> account.</p>
    </div>
  </div>

  <div class="row">

    <!--- KEEP player search --->
    <div class="col-md-5">
      <div class="player-search-box">
        <label>Player to KEEP <small class="text-muted">(their login survives)</small></label>
        <div class="autocomplete-wrapper">
          <input type="text" id="searchKeep" class="form-control border-input" placeholder="Search by name..." autocomplete="off">
          <div id="dropdownKeep" class="autocomplete-dropdown"></div>
        </div>
        <div id="badgeKeep" class="selected-player-badge">
          <span id="badgeKeepText"></span>
          <span class="clear-player" onclick="clearPlayer('keep')">&times;</span>
        </div>
      </div>
    </div>

    <!--- Arrow separator --->
    <div class="col-md-2 text-center" style="padding-top:55px; font-size:24px; color:#aaa;">
      &larr;
    </div>

    <!--- MERGE FROM player search --->
    <div class="col-md-5">
      <div class="player-search-box">
        <label>Player to MERGE FROM <small class="text-muted">(old/pre-wipe account)</small></label>
        <div class="autocomplete-wrapper">
          <input type="text" id="searchMerge" class="form-control border-input" placeholder="Search by name..." autocomplete="off">
          <div id="dropdownMerge" class="autocomplete-dropdown"></div>
        </div>
        <div id="badgeMerge" class="selected-player-badge">
          <span id="badgeMergeText"></span>
          <span class="clear-player" onclick="clearPlayer('merge')">&times;</span>
        </div>
      </div>
    </div>

  </div>

  <div class="row">
    <div class="col-md-12">
      <button id="previewBtn" class="btn btn-outline-danger btn-round" style="display:none;">
        Preview Merge
      </button>
    </div>
  </div>
</div>

<div id="snackbar"></div>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="../mergeAccounts/mergeAccounts.js?v=1.0"></script>
