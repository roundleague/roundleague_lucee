<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Teams/Player_Profiles/player-profile-2.css" rel="stylesheet" />

<cfquery name="getPlayerData" datasource="roundleague">
	SELECT lastName, firstName, position, height, weight, hometown, school, t.teamName
	FROM Players p
	JOIN Roster r on r.playerID = p.playerID
	JOIN Teams t on r.teamID = t.teamID
	WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerStats" datasource="roundleague">
	SELECT *
	FROM playerstats p
	JOIN seasons s ON p.SeasonID = s.seasonID
	WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<cfquery name="getPlayerAwards" datasource="roundleague">
	SELECT AwardName
	FROM Awards
	WHERE PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<!--- Career Totals --->
<cfinvoke component="player-profile"
	method="getCareerStats"
	returnvariable="careerStats">
    <cfinvokeargument name="playerID" value="#url.playerID#">
</cfinvoke>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<section class="section about-section" id="about">
            <div class="container">
                <div class="row align-items-center flex-row-reverse">
                    <div class="col-lg-6">
                        <div class="about-avatar">
					      <cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
					      <cfset altPath = "/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG"> <!--- Alt Path so we don't have to reorder pictures for now lol --->
					      <cfif FileExists(imgPath)>
					      	<img src="/assets/img/PlayerProfiles/#url.playerID#.JPG" alt="Player Photo" style="width:100%">
					      <cfelseif FileExists(altPath)>
					      	<img src="/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG" alt="Player Photo" style="width:100%">
					      <cfelse>
							<img src="/assets/img/PlayerProfiles/default.JPG" alt="Player Photo" style="width:100%">
					      </cfif>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="about-text go-to">
                            <h3 class="dark-color">#getPlayerData.firstName# #getPlayerData.LastName#</h3>
                            <h6 class="theme-color lead">#getPlayerData.position#</h6>
                            <p>Career Awards Section</p>
                            <div class="row about-list">
                                <div class="col-md-6">
                                    <div class="media">
                                        <label>Height</label>
                                        <p>#getPlayerData.height#</p>
                                    </div>
                                    <div class="media">
                                        <label>Weight</label>
                                        <p>#getPlayerData.weight#</p>
                                    </div>
                                    <div class="media">
                                        <label>Hometown</label>
                                        <p>#getPlayerData.hometown#</p>
                                    </div>
                                    <div class="media">
                                        <label>School</label>
                                        <p>#getPlayerData.school#</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="media">
                                        <label>Seasons</label>
                                        <p>#getPlayerStats.recordCount#</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="counter" style="margin-top: 25px;">
                    <div class="row">
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="500" data-speed="500">#val(getPlayerStats.Points)#</h6>
                                <p class="m-0px font-w-600">Points</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="150" data-speed="150">#val(getPlayerStats.Rebounds)#</h6>
                                <p class="m-0px font-w-600">Rebounds</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="850" data-speed="850">#val(getPlayerStats.Assists)#</h6>
                                <p class="m-0px font-w-600">Assists</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#val(getPlayerStats.Steals)#</h6>
                                <p class="m-0px font-w-600">Steals</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#val(getPlayerStats.Blocks)#</h6>
                                <p class="m-0px font-w-600">Blocks</p>
                            </div>
                        </div>
                        <div class="col-6 col-lg-3">
                            <div class="count-data text-center">
                                <h6 class="count h2" data-to="190" data-speed="190">#val(getPlayerStats.Turnovers)#</h6>
                                <p class="m-0px font-w-600">Turnovers</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

	        <table>
	          <caption>Career Stats</caption>
	          <thead>
	            <tr class="headers">
	            	<th>Season</th>
	            	<th>Points</th>
	            	<th>Rebounds</th>
	            	<th>Assists</th>
	            	<th>Steals</th>
	            	<th>Blocks</th>
	            	<th>Turnovers</th>
	            </tr>
	          </thead>
	          <tbody>
	          	<cfloop query="getPlayerStats">
		            <tr>
		            	<td data-label="Season">#getPlayerStats.SeasonName#</td>
		            	<td data-label="Points">#val(getPlayerStats.Points)#</td>
		            	<td data-label="Rebounds">#val(getPlayerStats.Rebounds)#</td>
		            	<td data-label="Assists">#val(getPlayerStats.Assists)#</td>
		            	<td data-label="Steals">#val(getPlayerStats.Steals)#</td>
		            	<td data-label="Blocks">#val(getPlayerStats.Blocks)#</td>
		            	<td data-label="Turnovers">#val(getPlayerStats.Turnovers)#</td>
		            </tr>
	        	</cfloop>
	            <tr class="headers">
	            	<td data-label="Career">Career</td>
	            	<td data-label="Points">#val(careerStats.Points)#</td>
	            	<td data-label="Rebounds">#val(careerStats.Rebounds)#</td>
	            	<td data-label="Assists">#val(careerStats.Assists)#</td>
	            	<td data-label="Steals">#val(careerStats.Steals)#</td>
	            	<td data-label="Blocks">#val(careerStats.Blocks)#</td>
	            	<td data-label="Turnovers">#val(careerStats.Turnovers)#</td>
	            </tr>
	          </tbody>
	        </table>        

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
