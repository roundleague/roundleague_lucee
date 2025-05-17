<cfoutput>
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

<div class="main" style="background-color: var(--background-light);">
    <div class="section">
        <div class="container">
            <div class="account-header">
                <div class="profile-image">
                    <img src="#playerPhoto#" alt="#GetPlayerData.FirstName# #GetPlayerData.LastName#">
                </div>
                <div class="account-info">
                    <h1>My Account</h1>
                    <p>#GetPlayerData.FirstName# #GetPlayerData.LastName#</p>
                    <p class="position">#GetPlayerData.Position#</p>
                    <p class="team">#GetPlayerData.TeamName#</p>
                </div>
            </div>            
            <div class="navigation">
                <a href="/pages/account/account_home.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;">
                    <i class="fa fa-home"></i> Account Home
                </a>
                <a href="/pages/account/account_settings.cfm?playerID=#url.playerID#" class="nav-button" style="text-decoration: none; color: inherit;">
                    <i class="fa fa-cog"></i> Account Settings
                </a>
                <a class="nav-button disabled" data-toggle="tooltip" data-trigger="click hover" data-placement="top" title="Coming Soon">
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
            </div>
</cfoutput>