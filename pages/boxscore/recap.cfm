<link href="../boxscore/recap.css?v=1.0" rel="stylesheet">

<cfparam name="isPlayoffRecap" default="false">

<cfquery name="getExistingRecap" datasource="roundleague">
	SELECT recapText
	FROM recaps
	WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.scheduleID#">
	AND isPlayoff = <cfqueryparam cfsqltype="CF_SQL_TINYINT" value="#isPlayoffRecap ? 1 : 0#">
</cfquery>

<cfif getExistingRecap.recordCount>
	<cfset recapMessageText = getExistingRecap.recapText>

	<!--- Modal Section --->
	<div class="modal fade" id="recapModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                  <div class="modal-content">
                    <div class="modal-header">
                      <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">x</span>
                      </button>
                      <h5 class="modal-title text-center" id="exampleModalLabel">Recap</h5>
                    </div>
                    <div class="modal-body">
                    	<cfoutput><p id="recapText">#recapMessageText#</p></cfoutput>
                    </div>
                    <div class="modal-footer">
                      <div class="left-side">
                        <button type="button" class="btn btn-default btn-link" data-dismiss="modal">Done</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
	<!--- End Modal Section --->

	<button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="#recapModal">
	  Show Recap
	</button>
</cfif>