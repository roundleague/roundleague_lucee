<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/teamPhotos/teamPhotos.css?v=1.2" rel="stylesheet">

<cfquery name="getTeams" datasource="roundleague">
  SELECT DISTINCT t.teamID, t.teamName
  FROM teams t
  JOIN roster r ON r.teamID = t.teamID
  WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  AND t.Status = 'Active'
  ORDER BY t.teamName
</cfquery>

<cfoutput>
<script>
  var API_BASE = '#application.apiBase#';
  var ADMIN_KEY = '#application.adminApiKey#';
  var SEASON_ID = #session.currentSeasonID#;
</script>

<div class="content">

  <!--- Upload Card --->
  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header">
          <h4 class="card-title"><i class="fa fa-camera"></i> Team Photo Upload</h4>
          <p class="card-category">Upload action photos for a team. Photos are stored per season.</p>
        </div>
        <div class="card-body">

          <div class="form-group">
            <label><strong>Select Team</strong></label>
            <select id="teamSelect" class="form-control" style="max-width: 400px;" onchange="onTeamChange(this.value)">
              <option value="">-- Select a team --</option>
              <cfloop query="getTeams">
                <option value="#getTeams.teamID#">#getTeams.teamName#</option>
              </cfloop>
            </select>
          </div>

          <input type="file" id="photoFiles" multiple accept="image/*" style="display:none;" onchange="onFilesSelected(this)">

          <div style="margin-top: 16px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
            <button class="btn btn-default btn-round" onclick="document.getElementById('photoFiles').click(); return false;">
              <i class="fa fa-images"></i> Select Photos
            </button>
            <button id="uploadBtn" class="btn btn-primary btn-round" disabled onclick="startUpload()">
              <i class="fa fa-upload"></i> Upload
            </button>
          </div>

          <div id="progressArea" style="display:none; margin-top: 20px;">
            <p id="progressText" class="text-muted"></p>
          </div>

          <div id="successMsg" style="display:none; margin-top: 20px;" class="alert alert-success">
            <i class="fa fa-check"></i> <span id="successText"></span>
          </div>

          <div id="errorMsg" style="display:none; margin-top: 20px;" class="alert alert-danger">
            <i class="fa fa-exclamation-triangle"></i> <span id="errorText"></span>
          </div>

          <!--- Pre-upload preview grid --->
          <div id="previewSection" style="display:none; margin-top: 24px;">
            <p class="text-muted" id="previewLabel"></p>
            <div id="previewGrid" class="photo-grid"></div>
          </div>

        </div>
      </div>
    </div>
  </div>

  <!--- Existing Photos Card --->
  <div id="galleryCard" class="row" style="display:none;">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;">
          <div>
            <h4 class="card-title" style="margin-bottom: 2px;"><i class="fa fa-th"></i> Current Photos</h4>
            <p class="card-category" id="galleryCount"></p>
          </div>
          <button id="deleteAllBtn" class="btn btn-danger btn-sm btn-round" onclick="deleteAll()">
            <i class="fa fa-trash"></i> Delete All
          </button>
        </div>
        <div class="card-body">
          <div id="galleryGrid" class="photo-grid"></div>
        </div>
      </div>
    </div>
  </div>

</div>
</cfoutput>

<script src="/admin-dashboard/pages/teamPhotos/teamPhotos.js?v=1.2"></script>
<cfinclude template="/admin-dashboard/admin_footer.cfm">
