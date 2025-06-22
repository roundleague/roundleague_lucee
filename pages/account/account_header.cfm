<cfoutput>
<cfinclude template="account_security_check.cfm">

<!--- Get player info without team restrictions first (works for free agents) --->
<cfquery name="getPlayerInfo" datasource="roundleague">
    SELECT p.playerID, lastName, firstName, position, height, weight, hometown, school
    FROM Players p
    WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
</cfquery>

<!--- Try to get team data if player is on a team --->
<cfquery name="getPlayerData" datasource="roundleague">
    SELECT p.playerID, lastName, firstName, position, height, weight, hometown, school, t.teamName, t.teamID
    FROM Players p
    JOIN Roster r on r.playerID = p.playerID
    JOIN Teams t on r.teamID = t.teamID
    WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND t.status = 'Active'
</cfquery>

<!--- Photo logic --->
<cfset playerPhoto = ''>
<cfset imgPath = "/assets/img/PlayerProfiles/#url.playerID#.JPG">
<cfset defaultPath = "/assets/img/PlayerProfiles/default.JPG">

<!--- If player is on team, use the team path --->
<cfif getPlayerData.recordCount GT 0>
    <cfset altPath = "/assets/img/PlayerProfiles/#getPlayerData.teamName#/#getPlayerData.FirstName# #getPlayerData.lastName# - 1.JPG">
<cfelse>
    <!--- For free agents, just set altPath to default since we don't have a team name --->
    <cfset altPath = defaultPath>
</cfif>

<cfif FileExists(imgPath)>
    <cfset playerPhoto = imgPath>
<cfelseif FileExists(altPath)>
    <cfset playerPhoto = altPath>
<cfelse>
    <cfset playerPhoto = defaultPath>
</cfif>

<div class="main" style="background-color: var(--background-light);">
    <div class="section">
        <div class="container">            <div class="account-header">
                <div class="profile-image">
                    <img src="#playerPhoto#" alt="#getPlayerInfo.FirstName# #getPlayerInfo.LastName#">
                </div>
                <div class="account-info">
                    <h1>#getPlayerInfo.FirstName# #getPlayerInfo.LastName#</h1>
                    <p class="position">#getPlayerInfo.Position#</p>
                    <cfif getPlayerData.recordCount GT 0>
                        <p class="team">#getPlayerData.TeamName#</p>
                    <cfelse>
                        <p class="team">Free Agent</p>
                    </cfif>
                </div>
            </div>
            <div class="navigation">
                <a href="/pages/account/account_home.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;">
                    <i class="fa fa-home"></i> Account Home
                </a>
                <a href="/pages/account/account_settings.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;">
                    <i class="fa fa-cog"></i> Account Settings
                </a>
                <a class="nav-button disabled" href="/pages/account/payments/payment_status.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;" data-toggle="tooltip" data-trigger="click hover" data-placement="top" title="Coming Soon">
                    <i class="fa fa-credit-card-alt"></i> Payments
                </a>
                <a class="nav-button disabled" data-toggle="tooltip" data-trigger="click hover" data-placement="top" title="Coming Soon">
                    <i class="fa-solid fa-photo-film"></i> My Media
                </a>
                <a class="nav-button disabled" data-toggle="tooltip" data-trigger="click hover" data-placement="top" title="Coming Soon">
                    <i class="fa-solid fa-basketball"></i> My Career
                </a>
                <a class="nav-button disabled" data-toggle="tooltip" data-trigger="click hover" data-placement="top" title="Coming Soon">
                    <i class="fa-solid fa-people-group"></i> Find Players / Team
                </a>
                <cfif isDefined("session.captainLoggedIn")>
                    <hr style="margin: 10px 0;">
                    <a href="/pages/captain/captain.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;">
                        <i class="fa fa-list"></i> Edit Team
                    </a>                    <a href="/pages/captain/signPlayer.cfm" class="nav-button" style="text-decoration: none; color: inherit;">
                        <i class="fa-solid fa-user-plus"></i> Sign Player
                    </a>
                </cfif>
            </div>
</cfoutput>