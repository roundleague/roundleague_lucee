<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />
<link href="/pages/Register/register.css" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfset basketballExp = "Recreational,High School Varsity,College,D-1 University,Professional">
<cfset bballPosition = "Point Guard,Shooting Guard,Small Forward,Power Forward,Center">
<cfset heightOptions = "5'0,5'1,5'2,5'3,5'4,5'5,5'6,5'7,5'8,5'9,5'10,5'11,6'0,6'1,6'2,6'3,6'4,6'5,6'6,6'7,6'8,6'9,6'10,6'11,7'0">

<cfoutput>

<cfquery name="getPlayerData" datasource="roundleague">    SELECT p.*, t.teamName, t.teamID, u.password, r.jersey
    FROM Players p
    JOIN Roster r on r.playerID = p.playerID
    JOIN Teams t on r.teamID = t.teamID
    JOIN users u on u.playerID = p.playerID
    WHERE p.PlayerID = <cfqueryparam cfsqltype="INTEGER" value="#url.playerID#">
    AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND t.status = 'Active'
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
                <a href="/pages/account/account_settings.cfm?playerID=#url.playerID#" class="nav-button active" style="text-decoration: none; color: inherit;">
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
            
            <!--- Account Settings Form --->
            <div class="profile-content section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-8 ml-auto mr-auto">
                            <form action="account_settings_save.cfm" method="post">
                                <input type="hidden" name="playerID" value="#url.playerID#">
                                <div class="form-group">
                                    <label>Gender</label><br>
                                    <select class="gender form-control" name="gender" style="padding: 7px;">
                                        <option value="Male" <cfif getPlayerData.gender EQ "Male">selected</cfif>>Male</option>
                                        <option value="Female" <cfif getPlayerData.gender EQ "Female">selected</cfif>>Female</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" required class="form-control border-input" placeholder="Email" name="email" value="#getPlayerData.email#">
                                </div>
                                <div class="form-group">
                                    <label>Password (leave blank to keep current)</label>
                                    <input type="password" class="form-control border-input" placeholder="New Password" name="password">
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>First Name</label>
                                            <input type="text" required class="form-control border-input" placeholder="First Name" name="firstName" value="#getPlayerData.firstName#">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Last Name</label>
                                            <input type="text" required class="form-control border-input" placeholder="Last Name" name="lastName" value="#getPlayerData.lastName#">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Birth Date</label>
                                            <input type="date" required class="form-control border-input" name="birthDate" value="#dateFormat(getPlayerData.birthDate, "yyyy-mm-dd")#">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Phone Number</label>
                                            <input type="tel" required id="phoneField" class="form-control border-input" name="phone" value="#getPlayerData.phone#">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Zip Code</label>
                                    <input type="text" required class="form-control border-input" placeholder="Zip Code" name="zipCode" maxlength="5" value="#getPlayerData.zipCode#">
                                </div>
                                <div class="form-group">
                                    <label>Instagram Handle (No @ Needed)</label>
                                    <input type="text" class="form-control border-input" placeholder="IG Handle" name="instagram" value="#getPlayerData.instagram#">
                                </div>
                                <div class="form-group">
                                    <label>Jersey Number</label>
                                    <input type="number" class="form-control border-input" name="currentJersey" value="#getPlayerData.jersey#">
                                </div>
                                <div class="form-group">
                                    <label class="biggerLabel">Basketball Experience</label>
                                    <cfloop list="#basketballExp#" index="i" item="x">
                                        <div class="form-check-radio">
                                            <label class="form-check-label">
                                                <input class="form-check-input" type="radio" name="highestLevel" value="#x#" <cfif getPlayerData.highestLevel EQ x>checked</cfif>> #x#
                                                <span class="form-check-sign"></span>
                                            </label>
                                        </div>
                                    </cfloop>
                                </div>
                                <div class="form-group">
                                    <label class="biggerLabel">Position</label>
                                    <cfloop list="#bballPosition#" index="i" item="x">
                                        <div class="form-check-radio">
                                            <label class="form-check-label">
                                                <input class="form-check-input" type="radio" name="position" value="#x#" <cfif getPlayerData.position EQ x>checked</cfif>> #x#
                                                <span class="form-check-sign"></span>
                                            </label>
                                        </div>
                                    </cfloop>
                                </div>
                                <div class="form-group">
                                    <label>Height</label><br>
                                    <select name="height" class="form-control" style="padding: 7px;">
                                        <cfloop list="#heightOptions#" index="i" item="x">
                                            <option value="#x#" <cfif getPlayerData.height EQ x>selected</cfif>>#x#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Weight</label>
                                            <input type="number" class="form-control border-input" placeholder="Weight" name="weight" value="#getPlayerData.weight#">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Hometown</label>
                                            <input type="text" class="form-control border-input" placeholder="Hometown" name="hometown" value="#getPlayerData.hometown#">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Last School Attended</label>
                                            <input type="text" class="form-control border-input" placeholder="Last School Attended" name="school" value="#getPlayerData.school#">
                                        </div>
                                    </div>
                                </div>
                                <div class="text-center">
                                    <button type="submit" class="btn btn-info btn-fill btn-wd">Update Profile</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

