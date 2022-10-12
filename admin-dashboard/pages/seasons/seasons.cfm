
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../seasons/seasons.css?v=1.1" rel="stylesheet">

<cfparam name="toastMsg" default="">

<!--- Save Data --->
<cfif isDefined("form.newSeasonName")>
	<cfinclude template="saveNewSeason.cfm">
<cfelseif isDefined("form.updateSaveBtn")>
  <cfinclude template="updateSeasonStatuses.cfm">
<cfelseif isDefined("form.progressToSeasonId")>
  <cfinclude template="progressSeason.cfm">
</cfif>

<cfquery name="getSeasons" datasource="roundleague">
	SELECT SeasonName, Status, SeasonID
	FROM Seasons
	Order By SeasonID Desc
	LIMIT 5
</cfquery>

<cfoutput>
<!--- Add Season Modal --->
<div class="modal fade" id="addSeasonModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">x</span>
        </button>
      </div>
      <div class="modal-body"> 

        <form id="newSeasonsForm" class="settings-form" method="POST">
        <div class="form-group">
          <label>Add New Season Name</label>
          <input type="text" required class="form-control border-input" placeholder="New Season Name" name="newSeasonName">
          <br>
          <p>Start Date: <input type="date" name="startDate"></p>
          <br>
          <p>End Date: <input type="date" name="endDate"></p>
        </div>
    	</form>

      </div>
      <div class="modal-footer">
        <div class="left-side">
          <button type="button" class="btn btn-default btn-link saveSeasonsBtn" data-dismiss="modal">Save</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!--- Confirm Progression Modal --->
<div class="modal fade" id="confirmProgression" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">x</span>
        </button>
      </div>
      <div class="modal-body"> 
        <p>Progression will set the newest season as active and do the following</p>
        <ul>
          <li>Move all current active teams to new season</li>
          <li>Move all current roster records to new season</li>
          <li>Move all leagues to new season</li>
          <li>Move all current divisions to new season</li>
          <li>Move all scheduled games to new season (to be edited using scheduler)</li>
        </ul>
        <p>Are you sure you wish to proceed and progress to the next season? </p>
      </div>
      <div class="modal-footer">
        <div class="left-side">
          <form id="progressSeasonForm" class="settings-form" method="POST">
            <input type="hidden" name="progressToSeasonId" value="" class="progressToSeasonId" />
          </form>
          <button type="button" class="btn btn-default btn-link progressionBtn" data-dismiss="modal">Yes, progress to next season</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!--- Begin Content --->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Seasons Manager</h3>
      <form id="updateSeasons" method="POST">
        <table>
          <thead>
            <tr>
            	<th>Season Name</th>
            	<th>Status</th>
            	<th>Progression</th>
            </tr>
          </thead>
          <tbody>
          	<cfloop query="getSeasons">
	            <tr>
	            	<td data-label="Season Name">#SeasonName#</td>
	            	<td data-label="Status">
	            		<select name="status_#getSeasons.seasonID#" class="statusSelect">
	            			<option value="Active" <cfif getSeasons.status EQ 'Active'>selected</cfif>>Active</option>
	            			<option value="Inactive" <cfif getSeasons.status EQ 'Inactive'>selected</cfif>>Inactive</option>
	            		</select>
	            	</td>
	            	<td data-label="Progression">
	            		<cfif getSeasons.currentRow EQ 1 AND getSeasons.status EQ 'Inactive'>
  					        <button type="button" class="btn btn-outline-danger btn-round modalBtn progressSeasonBtn" data-value="#getSeasons.seasonID#" data-toggle="modal" data-target="##confirmProgression">
  					          START SEASON
  					        </button>
			    	     </cfif>
	            	</td>
	            </tr>
              <input type="hidden" name="seasonIDList" value="#seasonID#">
        	   </cfloop>
            </tbody>
          </table>
        <input type="submit" class="btn btn-outline-danger btn-round updateSaveBtn" value="Save" name="updateSaveBtn">        <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##addSeasonModal">
          Add New Season
        </button>
        </form>
        <br>
        <h4 class="toastMsg">#toastMsg#</h4>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/seasons/seasons.js?v=1.1"></script>
