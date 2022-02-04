<cfinclude template="/header.cfm">
<cfinclude template="captain_security_check.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfoutput>

<cfquery name="getPlayerData" datasource="roundleague">
	SELECT p.playerID, lastName, firstName, position, height, weight, hometown, school, t.teamName, t.teamID
	FROM Players p
	JOIN Roster r on r.playerID = p.playerID
	JOIN Teams t on r.teamID = t.teamID
	WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerSchedule" datasource="roundleague">
	SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.homeScore, s.awayScore, s.StartTime, s.date
	FROM schedule s
	LEFT JOIN teams as a ON s.hometeamID = a.teamID
	LEFT JOIN teams as b ON s.awayTeamID = b.teamID
	WHERE (
		a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID# ">
		OR 
		b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">)
	AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND homeScore IS null
</cfquery>

<cfquery name="getPrevPlayerSchedule" datasource="roundleague">
	SELECT scheduleID, hometeamID, awayteamID, WEEK, a.teamName AS Home, b.teamName AS Away, s.homeScore, s.awayScore, s.StartTime, s.date
	FROM schedule s
	LEFT JOIN teams as a ON s.hometeamID = a.teamID
	LEFT JOIN teams as b ON s.awayTeamID = b.teamID
	WHERE (
		a.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID# ">
		OR 
		b.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getPlayerData.teamID#">)
	AND s.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	AND homeScore IS NOT null
</cfquery>

<!--- Photo logic --->
<cfset playerPhoto = ''>
<cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
<cfset altPath = "/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG">
<cfset defaultPath = "/assets/img/PlayerProfiles/default.JPG">

<cfif FileExists(imgPath)>
	<cfset playerPhoto = imgPath>
<cfelseif FileExists(altPath)>
	<cfset playerPhoto = altPath>
<cfelse>
	<cfset playerPhoto = defaultPath>
</cfif>

<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		  <div class="section profile-content">
		    <div class="container profileHome">
		        <div class="owner">
		          <div class="avatar">
		            <img src="#playerPhoto#" alt="Circle Image" class="img-circle img-no-padding img-responsive">
		          </div>
		          <div class="name">
		            <h4 class="title">#GetPlayerData.FirstName# #GetPlayerData.LastName#
		              <br />
		            </h4>
		            <h6 class="description">#GetPlayerData.Position#</h6>
		          </div>
		        </div>
		        <div class="row bottomProfile">
		          <div class="col-md-6 ml-auto mr-auto text-center">
		            <p>#GetPlayerData.TeamName#</p>
		            <br />
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-cog"></i> Account Settings</btn>
		            <a href="https://tinyurl.com/44348r29" target="_blank"><btn class="btn btn-outline-default btn-round"><i class="fa fa-credit-card-alt"></i> Payments</btn></a>
		            <a href="/pages/captain/captain.cfm?playerID=#getPlayerData.playerID#"><btn class="btn btn-outline-default btn-round"><i class="fa fa-list"></i> Edit Team</btn></a>
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-pencil-square-o"></i> Sign Free Agent</btn>
		          </div>
		        </div>
		        <br/>
		      <div class="nav-tabs-navigation">
		        <div class="nav-tabs-wrapper">
		          <ul class="nav nav-tabs" role="tablist">
		            <li class="nav-item">
		              <a class="nav-link active" data-toggle="tab" href="##follows" role="tab">Upcoming Schedule</a>
		            </li>
		            <li class="nav-item">
		              <a class="nav-link" data-toggle="tab" href="##following" role="tab">Previous</a>
		            </li>
		          </ul>
		        </div>
		      </div>
		      <!-- Tab panes -->
		      <div class="tab-content following">
		        <div class="tab-pane active" id="follows" role="tabpanel">
		          <div class="row">
		            <div class="col-md-6 ml-auto mr-auto">

		            <cfloop query="getPlayerSchedule">

	                  <cfif getPlayerData.teamID EQ getPlayerSchedule.hometeamID>
	                    <cfset opponentTeam = getPlayerSchedule.away>
	                  <cfelse>
	                    <cfset opponentTeam = getPlayerSchedule.home>
	                  </cfif>

		              <ul class="list-unstyled follows">
		                <li>
		                  <div class="row">
		                    <div class="col-lg-2 col-md-4 col-4 ml-auto mr-auto">
		                      <!--- <img src="../../assets/img/PlayerProfiles/79.JPG" alt="Circle Image" class="img-circle img-no-padding img-responsive"> --->
		                    </div>
		                    <div class="col-lg-7 col-md-4 col-4  ml-auto mr-auto">
		                      <h6>#opponentTeam#
		                        <br/>
		                        <b>#DateFormat(date, "mmm d, yyyy")# | #DateTimeFormat(StartTime, "h:nn ")# PM</b>
		                      </h6>
		                    </div>
		                    <div class="col-lg-3 col-md-4 col-4  ml-auto mr-auto">
		                      <!--- <div class="form-check">
		                        <label class="form-check-label">
		                          <input class="form-check-input" type="checkbox" value="" checked>
		                          <span class="form-check-sign"></span>
		                        </label>
		                      </div> --->
		                    </div>
		                  </div>
		                </li>
		                <hr />
		              </ul>
		          </cfloop>

		            </div>
		          </div>
		        </div>
		        <div class="tab-pane text-center" id="following" role="tabpanel">
		            <cfloop query="getPrevPlayerSchedule">

	                  <cfif getPlayerData.teamID EQ getPrevPlayerSchedule.hometeamID>
	                    <cfset opponentTeam = getPrevPlayerSchedule.away>
	                  <cfelse>
	                    <cfset opponentTeam = getPrevPlayerSchedule.home>
	                  </cfif>

		              <ul class="list-unstyled follows">
		                <li>
		                  <div class="row">
		                    <div class="col-lg-2 col-md-4 col-4 ml-auto mr-auto">
		                      <!--- <img src="../../assets/img/PlayerProfiles/79.JPG" alt="Circle Image" class="img-circle img-no-padding img-responsive"> --->
		                    </div>
		                    <div class="col-lg-7 col-md-4 col-4  ml-auto mr-auto">
		                      <h6>#opponentTeam#
		                        <br/>
		                        <b>#DateFormat(date, "mmm d, yyyy")# | #DateTimeFormat(StartTime, "h:nn ")# PM</b>
		                      </h6>
		                    </div>
		                    <div class="col-lg-3 col-md-4 col-4  ml-auto mr-auto">
		                      <!--- <div class="form-check">
		                        <label class="form-check-label">
		                          <input class="form-check-input" type="checkbox" value="" checked>
		                          <span class="form-check-sign"></span>
		                        </label>
		                      </div> --->
		                    </div>
		                  </div>
		                </li>
		                <hr />
		              </ul>
		          </cfloop>
		        </div>
		      </div>
		    </div>
		  </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

