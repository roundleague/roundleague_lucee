
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../seasons/seasons.css?v=1.1" rel="stylesheet">

<cfparam name="toastMsg" default="">

<!--- Save Data --->
<cfif isDefined("form.newSeasonName")>
	<cfinclude template="saveNewSeason.cfm">
</cfif>

<cfquery name="getSeasons" datasource="roundleague">
	SELECT SeasonName, Status, SeasonID
	FROM Seasons
	Order By SeasonID Desc
	LIMIT 5
</cfquery>

<cfoutput>

      	<!--- Add Season Modal --->
            <div class="modal fade" id="waiverModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
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

<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Seasons Manager</h3>
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
	            		<select name="status" class="statusSelect">
	            			<option value="Active" <cfif getSeasons.status EQ 'Active'>selected</cfif>>Active</option>
	            			<option value="Inactive" <cfif getSeasons.status EQ 'Inactive'>selected</cfif>>Inactive</option>
	            		</select>
	            	</td>
	            	<td data-label="Progression">
	            		<cfif getSeasons.currentRow EQ 1 AND getSeasons.status EQ 'Inactive'>
					        <button type="button" class="btn btn-outline-danger btn-round">
					          START SEASON (Not Implemented)
					        </button>
				    	</cfif>
	            	</td>
	            </tr>
        	</cfloop>
          </tbody>
        </table>
        <button type="button" class="btn btn-outline-danger btn-round">
          Save (Not Implemented)
        </button>
        <button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="##waiverModal">
          Add New Season
        </button>
        <br>
        <h4 class="toastMsg">#toastMsg#</h4>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/seasons/seasons.js"></script>
