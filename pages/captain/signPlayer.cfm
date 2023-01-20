<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">
<link href="/pages/captain/signPlayer.css?v=1.1" rel="stylesheet">

<cfif isDefined("form.signPlayerID")>
	<cfinclude template="signPlayer_confirm.cfm">
	<cfexit>
</cfif>

<cfif isDefined("form.confirmSignPlayer")>
  <cfquery name="transferPlayer" datasource="roundleague">
  	UPDATE roster
  	SET teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.toTeamID#">
  	WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.confirmSignPlayer#">
  	AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  </cfquery>

  <!--- Insert Transaction History Record --->
  <cfquery name="checkDup" datasource="roundleague">
  	SELECT playerID
  	FROM transactions
  	WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.confirmSignPlayer#">
  	AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  </cfquery>
  <cfif checkDup.recordCount EQ 0>
	  <cfquery name="transactionRecord" datasource="roundleague">
	  	INSERT INTO transactions (PlayerID, FromTeamID, ToTeamID, SeasonID, CaptainModifiedBy, DateModified)
	  	VALUES 
	  	(
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.confirmSignPlayer#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.fromTeamID#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.toTeamID#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
	  		<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.captainID#">,
	  		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
		)	
	  </cfquery>
  </cfif>

  <!-- The actual snackbar -->
  <div id="snackbar">Player has been successfully added!</div>
</cfif>

<cfquery name="getLatestSeasons" datasource="roundleague">
	SELECT seasonID, previousSeasonID
	FROM seasons
	ORDER BY seasonID DESC
	LIMIT 2
</cfquery>

<cfquery name="getPlayerStats" datasource="roundleague">
	SELECT p.firstName, p.lastName, ps.FGM, ps.FGA, ps.3FGM, ps.3FGA, ps.points, ps.rebounds, ps.assists, ps.steals, ps.blocks, ps.turnovers, ps.gamesplayed, r.jersey, t.teamName, p.height, p.playerID
	FROM players p
	LEFT OUTER JOIN playerstats ps ON p.playerID = ps.playerID AND ps.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getLatestSeasons.previousSeasonID#">
	JOIN roster r on r.playerID = p.playerID AND r.SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getLatestSeasons.seasonID#">
	LEFT OUTER JOIN teams t on r.teamID = t.teamID
	WHERE r.seasonID IN (#getLatestSeasons.seasonID#, #getLatestSeasons.previousSeasonID#)
	AND r.teamID != 0
	ORDER BY points desc
</cfquery>

<cfquery name="freeAgentPool" datasource="roundleague">
	SELECT firstName, lastName, HighestLevel, height, position, weight, instagram, phone, p.playerID, p.PermissionToShare
	FROM players p 
	JOIN roster r on r.playerID = p.playerID
	WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
	and r.teamID = 0
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; padding-top: 50px">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <form method="POST" class="signPlayerForm">
        	<captain><h2>Active Players</h2></captain>
			<table id="signPlayerTable" class="display bolder" style="width:100%">
			        <thead>
			            <tr>
			                <th>Name</th>
			                <th>Team</th>
			                <th>Height</th>
			                <th>FGM</th>
			                <th>3FGM</th>
			                <!--- <th>FG%</th> --->
			                <th>PTS</th>
			                <th>REBS</th>
			                <th>ASTS</th>
			                <th>STLS</th>
			                <th>BLKS</th>
			                <th>TO</th>
			                <th>Sign</th>
			            </tr>
			        </thead>
			        <tbody>
			        	<cfloop query="getPlayerStats">
			        		<tr>
				        		<td data-label="Name">#getPlayerStats.firstName# #getPlayerStats.lastName# ###jersey#</td>
				        		<td data-label="Team">#getPlayerStats.teamname#</td>
				        		<td data-label="Height">#getPlayerStats.Height#</td>
				        		<td data-label="FGM">#getPlayerStats.FGM#</td>
				        		<td data-label="3FGM">#getPlayerStats.3FGM#</td>
				        		<!--- <td data-label="FG%">
				        			<cftry>#NumberFormat(evaluate(getPlayerStats.FGM / getPlayerStats.FGA * 100), '__.0')#%
				        				<cfcatch>0%</cfcatch>
				        			</cftry>
				        		</td> --->
				        		<td data-label="Points">#getPlayerStats.Points#</td>
				        		<td data-label="Rebounds">#getPlayerStats.Rebounds#</td>
				        		<td data-label="Assists">#getPlayerStats.Assists#</td>
				        		<td data-label="Steals">#getPlayerStats.Steals#</td>
				        		<td data-label="Blocks">#getPlayerStats.Blocks#</td>
				        		<td data-label="TO">#getPlayerStats.Turnovers#</td>
				        		<td data-label="Sign">
			            		<button type="submit" class="btn btn-outline-success btn-round removeBtn" name="signPlayerID"value="#playerID#">Sign</button>
				        		</td>
			        		</tr>
			        	</cfloop>
			        </tbody>
			</table>

			<captain><h2>Free Agents</h2></captain>
			<table id="signPlayerTableFreeAgent" class="display bolder" style="width:100%">
			        <thead>
			            <tr>
			                <th>Name</th>
			                <th>Highest Level</th>
			                <th>Position</th>
			                <th>Height</th>
			                <th>Weight</th>
			                <th>Instagram</th>
			                <!--- <th>Phone</th> --->
			                <th>Sign</th>
			            </tr>
			        </thead>
			        <tbody>
			        	<cfloop query="freeAgentPool">
			        		<tr>
				        		<td data-label="Name">#freeAgentPool.firstName# #freeAgentPool.lastName#</td>
				        		<td data-label="Highest Level"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.highestLevel#</cfif></td>
				        		<td data-label="Position"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.Position#</cfif></td>
				        		<td data-label="Height"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.Height#</cfif></td>
				        		<td data-label="Weight"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.Weight#</cfif></td>
				        		<td data-label="Instagram"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.Instagram#</cfif></td>
				        		<!--- <td data-label="Phone"><cfif PermissionToShare EQ 'YES'>#freeAgentPool.Phone#</cfif></td> --->
				        		<td data-label="Sign">
			            		<button type="submit" class="btn btn-outline-success btn-round removeBtn" name="signPlayerID"value="#playerID#">Sign</button>
				        		</td>
			        		</tr>
			        	</cfloop>
			        </tbody>
			</table>
		</form>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/pages/captain/signPlayer.js"></script>

