
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

<!--- Get divisions from the current active season for mapping UI --->
<cfquery name="getCurrentDivisions" datasource="roundleague">
	SELECT d.DivisionID, d.DivisionName
	FROM Divisions d
	JOIN Seasons s ON d.SeasonID = s.SeasonID
	WHERE s.Status = 'Active'
	ORDER BY d.DivisionName
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
        <p>Progression will set the selected season as active and do the following:</p>
        <ul>
          <li>Deactivate the previous season</li>
          <li>Move all current active teams to the new season</li>
          <li>Copy all current roster records to the new season</li>
          <li>Copy all leagues to the new season</li>
        </ul>
        
        <div class="progression-options" style="background: ##f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0;">
          <p style="margin-bottom: 10px;"><strong>Division Options:</strong></p>
          <label style="display: block; cursor: pointer; margin-bottom: 10px;">
            <input type="checkbox" id="copyDivisions" name="copyDivisions" value="1" checked> 
            Copy divisions to new season
          </label>
          
          <div id="divisionMappingSection" style="margin-top: 15px; padding-top: 15px; border-top: 1px solid ##ddd;">
            <p style="margin-bottom: 10px; font-size: 13px; color: ##666;">Configure divisions for the new season:</p>
            
            <!--- Existing divisions table --->
            <table class="division-mapping-table" style="width: 100%; font-size: 14px;">
              <thead>
                <tr>
                  <th style="text-align: center; padding: 5px; width: 60px;">Copy</th>
                  <th style="text-align: left; padding: 5px;">Current Name</th>
                  <th style="text-align: left; padding: 5px;">New Name</th>
                </tr>
              </thead>
              <tbody>
                <cfloop query="getCurrentDivisions">
                  <tr class="division-row">
                    <td style="padding: 5px; text-align: center;">
                      <input type="checkbox" 
                             class="division-copy-checkbox" 
                             data-division-id="#getCurrentDivisions.DivisionID#"
                             checked>
                    </td>
                    <td style="padding: 5px;">#getCurrentDivisions.DivisionName#</td>
                    <td style="padding: 5px;">
                      <input type="text" 
                             class="form-control division-new-name" 
                             data-division-id="#getCurrentDivisions.DivisionID#"
                             data-original-name="#getCurrentDivisions.DivisionName#"
                             value="#getCurrentDivisions.DivisionName#"
                             style="font-size: 14px; padding: 5px;">
                    </td>
                  </tr>
                </cfloop>
                <cfif getCurrentDivisions.recordCount EQ 0>
                  <tr>
                    <td colspan="3" style="padding: 10px; color: ##999; font-style: italic;">No divisions in current season</td>
                  </tr>
                </cfif>
              </tbody>
            </table>
            
            <!--- Add new divisions section --->
            <div id="newDivisionsSection" style="margin-top: 15px; padding-top: 15px; border-top: 1px dashed ##ccc;">
              <p style="margin-bottom: 10px; font-size: 13px; color: ##666;">Add new divisions:</p>
              <div id="newDivisionsList"></div>
              <button type="button" class="btn btn-sm btn-outline-secondary" id="addNewDivisionBtn" style="margin-top: 5px;">
                + Add Division
              </button>
            </div>
            
            <p style="margin-top: 15px; font-size: 12px; color: ##888;">
              <em>Unchecked divisions will not be copied. Teams in those divisions will need to be reassigned after progression.</em>
            </p>
          </div>
        </div>
        
        <p><strong>Note:</strong> Scheduled games will <em>not</em> be carried over. Use the Schedule Import tool after progression.</p>
        <p>Are you sure you wish to proceed and progress to the next season?</p>
      </div>

      <div class="modal-footer">
        <div class="left-side">
          <form id="progressSeasonForm" class="settings-form" method="POST">
            <input type="hidden" name="progressToSeasonId" value="" class="progressToSeasonId" />
            <input type="hidden" name="copyDivisions" value="0" class="copyDivisionsField" />
            <input type="hidden" name="divisionMappings" value="" id="divisionMappingsField" />
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
<script src="/admin-dashboard/pages/seasons/seasons.js?v=1.3"></script>
