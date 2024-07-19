<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/admin-dashboard/pages/powerrankings/powerrankings.css?v=1.2" rel="stylesheet">

<cfquery name="getLeagues" datasource="roundleague">
    SELECT LeagueID, LeagueName
    FROM leagues
    WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfparam name="form.leagueSelect" default="#getLeagues.leagueID#">

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      
    	<div class="selectLeagueBox">
            <label for="seasonID">Select League</label>
            <select name="leagueSelect" id="Seasons" onchange="this.form.submit()">
                <cfloop query="getLeagues">
                    <option value="#getLeagues.leagueID#" <cfif form.leagueSelect EQ getLeagues.leagueID>selected</cfif>>#getLeagues.leagueName#</option>
                </cfloop>
            </select>
        </div>

        <div class="team-bank">
            <h2>Team Bank</h2>
            <div draggable="true" id="team-1" class="54 team-bank">Taste Ticklers</div>
            <div draggable="true" id="team-2" class="40 team-bank">Let's Go Tao</div>
            <div draggable="true" id="team-3" class="2 team-bank">Goodfellas</div>
        </div>
        
        <div class="power-rankings">
            <h2>Power Rankings Drag N Drop</h2>
            <div draggable="true" id="rank-1" class="rank">1.</div>
            <div draggable="true" id="rank-2" class="rank">2.</div>
            <div draggable="true" id="rank-3" class="rank">3.</div>
            <div draggable="true" id="rank-4" class="rank">4.</div>
            <div draggable="true" id="rank-5" class="rank">5.</div>
        </div>

    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="/admin-dashboard/pages/powerrankings/powerrankings.js?v=1.5"></script>
