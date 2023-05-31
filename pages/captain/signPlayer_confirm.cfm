<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">
<link href="/pages/captain/signPlayer_confirm.css" rel="stylesheet">

<cfquery name="getPlayerInfo" datasource="roundleague">
    SELECT firstName, lastName, t.teamName, t.teamID
    FROM players p
    JOIN roster r on r.playerID = p.playerID
    JOIN teams t on t.teamID = r.teamID 
    WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.signPlayerID#">
</cfquery>

<cfset teamObject = createObject("component", "library.teams") />
<cfset teamStruct = teamObject.getCurrentSessionTeam(session.captainID)>
<!--- If current captain played for a previous team --->
<cfif teamStruct.teamID EQ getPlayerInfo.teamID>
    <cfquery name="getNewTeamPrevCaptain" datasource="roundleague">
        SELECT TeamID, teamName
        FROM teams 
        WHERE CaptainPlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.captainID#">
    </cfquery>
    <cfset teamStruct.teamID = getNewTeamPrevCaptain.teamID>
    <cfset teamStruct.teamName = getNewTeamPrevCaptain.teamName>
</cfif>

<!--- If player is a free agent --->
<cfif getPlayerInfo.recordCount EQ 0>
    <cfquery name="getPlayerInfo" datasource="roundleague">
        SELECT firstName, lastName, 'Free Agents' as teamName, 0 as teamID
        FROM players p
        JOIN roster r on r.playerID = p.playerID
        WHERE r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND p.playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.signPlayerID#">
    </cfquery>
</cfif>

<cfoutput>
<div class="main" style="background-color: white; padding-top: 50px">
    <div class="section text-center">
      <div class="container">
        <!--- Content Here --->
        <form name="confirmSignPlayerForm" method="POST">
            <h3>IMPORTANT: Do not sign players without their permission.</h3>
            <br>
            <p>You are about to transfer <b>#getPlayerInfo.firstName# #getPlayerInfo.lastName#</b> from <b>#getPlayerInfo.teamName#</b> to <b>#teamStruct.teamName#</b>.</p>
            <hr>
            <button type="submit" class="btn btn-outline-success btn-round confirmSignBtn" name="confirmSignPlayer" value="#form.signPlayerID#">Sign</button><br><br>
            <button type="submit" class="btn btn-outline-danger btn-round cancelSignBtn" name="cancelSign">Cancel</button>
            <input type="hidden" name="toTeamID" value="#teamStruct.teamID#">
            <input type="hidden" name="fromTeamID" value="#getPlayerInfo.teamID#">
        </form>
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/pages/captain/signPlayer.js"></script>

