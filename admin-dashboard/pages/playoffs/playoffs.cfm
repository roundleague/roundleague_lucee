
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../playoffs/playoffs.css" rel="stylesheet">

<cfoutput>

<cfif isDefined("form.saveBtn")>
	<cfinclude template="savePlayoffsData.cfm">
</cfif>

<cfquery name="getBrackets" datasource="roundleague">
  SELECT Playoffs_BracketID as BracketID, Name, SeasonID
  FROM Playoffs_Bracket
  Where SeasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  ORDER BY SortOrder
</cfquery>

<cfparam name="form.bracketID" default="#getBrackets.BracketID#">

<cfquery name="getTeams" datasource="roundleague">
  SELECT teamID, teamName
  FROM teams
  Where Status = 'Active'
  AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
  ORDER BY teamName
</cfquery>

<cfquery name="getPlayoffGames" datasource="roundleague">
  SELECT s.Playoffs_ScheduleID, a.teamName AS Home, b.teamName AS Away, 
  s.startTime, s.date, s.homeTeamID, s.awayTeamID, s.seasonID, s.homeScore, s.awayScore, s.BracketGameID, s.BracketRoundID, pb.Name, s.HomeSeed, s.AwaySeed
  FROM playoffs_schedule s
  JOIN playoffs_bracket pb ON pb.Playoffs_bracketID = s.Playoffs_BracketID
  LEFT JOIN teams as a ON s.hometeamID = a.teamID
  LEFT JOIN teams as b ON s.awayTeamID = b.teamID
  WHERE pb.seasonID = (SELECT seasonID From seasons WHERE status = 'Active')
  AND pb.Playoffs_BracketID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.bracketID#">
  ORDER BY S.BracketGameID, WEEK, date, startTime
</cfquery>

<cfquery name="getMaxRounds" dbtype="query">
	SELECT MAX(BracketRoundID) as MaxRounds
	FROM getPlayoffGames
</cfquery>

<div class="content">
  <div class="row">
    <div class="col-md-12">
      <form name="playoffsForm" method="POST">	
	      <div class="playoffBracket">
	        <!--- Select for Bracket Type --->
	        <label for="BracketID">Bracket</label>
	        <select name="BracketID" id="Brackets" onchange="this.form.submit()">
	          <cfloop query="getBrackets">
	            <option value="#getBrackets.BracketID#"<cfif getBrackets.BracketID EQ form.BracketID> selected</cfif>>#getBrackets.Name#</option>
	          </cfloop>
	        </select>

	        <h1>#getPlayoffGames.Name#</h1>
			<main id="tournament">
			  <ul class="round round-1">
			  	<cfquery name="gamesRound1" dbtype="query">
			  		SELECT *
			  		FROM getPlayoffGames
			  		WHERE getPlayoffGames.BracketRoundID = 1
			  	</cfquery>
			  	<cfloop query="gamesRound1">
				    <li class="spacer">&nbsp;</li>
				    <li class="game game-top round1">
				    	###HomeSeed#
				        <select name="Game_#gamesRound1.BracketGameID#_HomeTeamID" id="Team" class="teamSelect">
				            <option value=""></option>
				            <cfloop query="getTeams">
				                <option value="#getTeams.teamID#" <cfif gamesRound1.homeTeamID EQ getTeams.TeamID>selected</cfif>>#getTeams.teamName#</option>
				            </cfloop>
				        </select>
				    </li>
				    <li class="game game-spacer">Game #gamesRound1.BracketGameID#</li>
				    <li class="game game-bottom round1">
				    	###AwaySeed#
				        <select name="Game_#gamesRound1.BracketGameID#_AwayTeamID" id="Team" class="teamSelect">
				            <option value=""></option>
				            <cfloop query="getTeams">
				                <option value="#getTeams.teamID#" <cfif gamesRound1.awayTeamID EQ getTeams.TeamID>selected</cfif>>#getTeams.teamName#</option>
				            </cfloop>
				        </select>
				    </li>
			  	</cfloop>

			    <!--- <li class="spacer">&nbsp;</li>
			    
			    <li class="game game-top winner">
					<input type="text" required class="form-control border-input" placeholder="Seed 4" name="seed_4">
			    </li>
			    <li class="game game-spacer">Game 2</li>
			    <li class="game game-bottom ">
					<input type="text" required class="form-control border-input" placeholder="Seed 5" name="seed_5">
			    </li>

			    <li class="spacer">&nbsp;</li>
			    
			    <li class="game game-top winner">
					<input type="text" required class="form-control border-input" placeholder="Seed 3" name="seed_3">
			    </li>
			    <li class="game game-spacer">Game 3</li>
			    <li class="game game-bottom ">
					<input type="text" required class="form-control border-input" placeholder="Seed 6" name="seed_6">
			    </li>

			    <li class="spacer">&nbsp;</li>
			    
			    <li class="game game-top winner">
					<input type="text" required class="form-control border-input" placeholder="Seed 2" name="seed_2">
			    </li>
			    <li class="game game-spacer">Game 4</li>
			    <li class="game game-bottom ">
					<input type="text" required class="form-control border-input" placeholder="Seed 7" name="seed_7">
			    </li> --->

			    <li class="spacer">&nbsp;</li>
			  </ul>
			  <ul class="round round-2">
			  	<cfquery name="gamesRound2" dbtype="query">
			  		SELECT *
			  		FROM getPlayoffGames
			  		WHERE getPlayoffGames.BracketRoundID = 2
			  	</cfquery>
			  	<cfloop query="gamesRound2">
				    <li class="spacer">&nbsp;</li>
				    
				    <li class="game game-top round2">
				        #gamesRound2.Home#
				    </li>
				    <li class="game game-spacer">Game #gamesRound2.BracketGameID#</li>
				    <li class="game game-bottom round2">
				        #gamesRound2.Away#
				    </li>
			  	</cfloop>

			    <li class="spacer">&nbsp;</li>

			  </ul>
			  <ul class="round round-3">
			  	<cfquery name="gamesRound3" dbtype="query">
			  		SELECT *
			  		FROM getPlayoffGames
			  		WHERE getPlayoffGames.BracketRoundID = 3
			  	</cfquery>
			  	<cfloop query="gamesRound3">
				    <li class="spacer">&nbsp;</li>
				    
				    <li class="game game-top round3">
				        #gamesRound3.Home#
				    </li>
				    <li class="game game-spacer">Game #gamesRound3.BracketGameID#</li>
				    <li class="game game-bottom round3">
				        #gamesRound3.Away#
				    </li>
			  	</cfloop>

			    <li class="spacer">&nbsp;</li>
			  </ul>
			  <cfif getMaxRounds.maxRounds EQ 3>
			  	<!--- 8 Team Bracket --->
				<ul class="round round-4">
					<li class="spacer">&nbsp;</li>
					<li class="game game-top">Champion</li>
					<li class="spacer">&nbsp;</li>
			  	</ul>
			  <cfelse>
			  	<!--- 32 Team Bracket --->
				  <ul class="round round-4">
				  	<cfquery name="gamesRound4" dbtype="query">
				  		SELECT *
				  		FROM getPlayoffGames
				  		WHERE getPlayoffGames.BracketRoundID = 4
				  	</cfquery>
				  	<cfloop query="gamesRound4">
					    <li class="spacer">&nbsp;</li>
					    
					    <li class="game game-top round4">
					        #gamesRound4.Home#
					    </li>
					    <li class="game game-spacer">Game #gamesRound4.BracketGameID#</li>
					    <li class="game game-bottom round4">
					        #gamesRound4.Away#
					    </li>
				  	</cfloop>

				    <li class="spacer">&nbsp;</li>
				  </ul>
				  <ul class="round round-5">
				  	<cfquery name="gamesRound5" dbtype="query">
				  		SELECT *
				  		FROM getPlayoffGames
				  		WHERE getPlayoffGames.BracketRoundID = 5
				  	</cfquery>
				  	<cfloop query="gamesRound5">
					    <li class="spacer">&nbsp;</li>
					    
					    <li class="game game-top round5">
					        #gamesRound5.Home#
					    </li>
					    <li class="game game-spacer">Game #gamesRound5.BracketGameID#</li>
					    <li class="game game-bottom round5">
					        #gamesRound5.Away#
					    </li>
				  	</cfloop>

				    <li class="spacer">&nbsp;</li>
				  </ul>
				<ul class="round round-6">
					<li class="spacer">&nbsp;</li>
					<li class="game game-top">Champion</li>
					<li class="spacer">&nbsp;</li>
			  	</ul>
			  </cfif>  
			</main>
	      </div>
	      <button name="saveBtn" type="submit" class="btn btn-wd btn-info btn-round saveBtn">Save</button>
	  </form>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
