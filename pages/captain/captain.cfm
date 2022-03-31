<cfinclude template="/header.cfm">
<cfinclude template="captain_security_check.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="captain.css" rel="stylesheet">

<cfif isDefined("form.updateBtn")>
	<cfinclude template="saveRosterData.cfm">
  	<!-- The actual snackbar -->
  	<div id="snackbar">Roster has been updated.</div>
</cfif>

<cfif isDefined("form.removePlayer")>
	<cfquery name="removePlayer" datasource="roundleague">
		UPDATE roster
		SET teamID = 0
		WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.removePlayer#">
		AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	</cfquery>

  <!--- Insert Transaction History Record --->
  <cfquery name="checkDup" datasource="roundleague">
  	SELECT playerID
  	FROM transactions
  	WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.removePlayer#">
  	AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  </cfquery>

	<cfset teamObject = createObject("component", "library.teams") />
	<cfset teamStruct = teamObject.getCurrentSessionTeam(session.captainID)>

  <cfif checkDup.recordCount EQ 0>
	  <cfquery name="transactionRecord" datasource="roundleague">
	  	INSERT INTO transactions (PlayerID, FromTeamID, ToTeamID, SeasonID, CaptainModifiedBy, DateModified)
	  	VALUES 
	  	(
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.removePlayer#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamStruct.teamID#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.captainID#">,
	  		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
		)	
	  </cfquery>
  </cfif>

  	<!-- The actual snackbar -->
  	<div id="snackbar">Player has been removed.</div>
</cfif>

<cfquery name="getTeamData" datasource="roundleague">
	SELECT 
    p.playerID, 
    lastName, 
    firstName, 
    teamName, 
    position, 
    height, 
    weight, 
    hometown, 
    school, 
    s.seasonName, 
    d.divisionName,
    t.captainPlayerID,
    r.jersey,
    p.PermissionToShare,
    p.instagram
	FROM players p
	JOIN roster r ON r.PlayerID = p.playerID
	JOIN teams t ON t.teamId = r.teamID
	JOIN divisions d ON d.divisionID = r.DivisionID
	JOIN seasons s ON s.seasonID = t.seasonID
	WHERE r.seasonID = s.seasonID
	AND t.captainPlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
  GROUP BY lastName, firstName
</cfquery>

<cfset bballPosition = 'Point Guard,Shooting Guard,Small Forward,Power Forward,Center'>
<cfset heightOptions = "4'11,5'1,5'2,5'3,5'4',5'5,5'6,5'7,5'8,5'9,5'10,5'11,6'0,6'1,6'2,6'3,6'4,6'5,6'6,6'7,6'8,6'9,6'10,6'11,7'0,7'1,7'2,7'3,7'4,7'5">

<cfoutput>

      	<!--- Waiver Modal --->
            <div class="modal fade" id="removePlayerModal" tabindex="-1" role="dialog" aria-labelledby="removeModal" aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">x</span>
                    </button>
                    <h5 class="modal-title text-center" id="removeModal">Remove Player From Roster</h5>
                  </div>
                  <div class="modal-body"> 
                  	Are you sure you want to remove <span class="playerName"></span> from this roster?
                  </div>
                  <div class="modal-footer">
                    <div class="left-side">
                      <button type="button" class="btn btn-default btn-link confirmRemoveBtn" data-dismiss="modal">Yes, Remove this player from the roster</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <h1>#getTeamData.teamName#</h1>
        <form name="editRosterForm" class="editRosterForm" method="POST">
	        <table>
	          <caption>#getTeamData.seasonName# Roster</caption>
	          <thead>
	            <tr>
	            	<td>Name</td>
	              	<td>Jersey</td>
	            	<td>Position</td>
	            	<td>Height</td>
	            	<td>Weight</td>
	            	<td>Hometown</td>
	            	<td>School</td>
	            	<td>Instagram</td>
	            	<td>Remove</td>
	            </tr>
	          </thead>
	          <tbody>
	          	<cfloop query="getTeamData">
		            <tr>
		            	<td data-label="Player">
	                    	#firstName# #lastName# <cfif getTeamData.captainPlayerID EQ getTeamData.playerID>(C)</cfif>
	                	</td>
	                <td data-label="Jersey">
	                	<!--- <input type="number" class="form-control border-input" value="#jersey#" name="jersey_#playerID#"> --->
	                	<cfif jersey EQ ''>
	                		N/A
	                	<cfelse>
	                		#jersey#
	                	</cfif>
	            	</td>
		            	<td data-label="Position">
		            		<select name="position_#playerID#">
		            			<cfloop list="#bballPosition#" item="i">
		            				<option value="#i#" <cfif i EQ position>selected</cfif>>#i#</option>
		            			</cfloop>
		            		</select>
		            	</td>
		            	<td data-label="Height">
		            		<input type="text" class="form-control border-input smallerField" value="#height#" name="height_#playerID#">
		            	</td>
		            	<td data-label="Weight">
		            		<input type="number" class="form-control border-input smallerField" value="#weight#" name="weight_#playerID#">
		            	</td>
		            	<td data-label="Hometown">
		            		<input type="text" class="form-control border-input" value="#hometown#" name="hometown_#playerID#">
		            	</td>
		            	<td data-label="School">
		            		<input type="text" class="form-control border-input" value="#school#" name="school_#playerID#">
		            	</td>
		            	<td data-label="Instagram">
		            		<input type="text" class="form-control border-input" value="#instagram#" name="instagram_#playerID#">
		            	</td>
		            	<td data-label="Remove Player">
		            		<button type="button" class="btn btn-outline-danger btn-round removeBtn" data-toggle="modal" data-target="##removePlayerModal" data-name="#firstName# #lastName#" data-playerid="#playerID#">
		              Remove
		            </button>
		            	</td>
		            </tr>
		            <input type="hidden" name="playerIDList" value="#playerID#">
	        	</cfloop>
	          </tbody>
	        </table>
	        <button type="submit" class="btn btn-wd btn-info btn-round updateBtn" name="updateBtn">Update</button>
    	</form>
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../captain/captain.js"></script>

