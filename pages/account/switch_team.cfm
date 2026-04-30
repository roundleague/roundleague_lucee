<cfinclude template="/header.cfm">
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet">

<cfparam name="url.playerID" default="0">

<cfoutput>
<cfset local.hideAccountNav = true>
<cfinclude template="account_header.cfm">

<cfquery name="getActiveTeams" datasource="roundleague">
    SELECT t.teamID, t.teamName, d.divisionName
    FROM teams t
    JOIN divisions d ON t.divisionID = d.divisionID
    WHERE t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND t.status = 'Active'
    ORDER BY d.divisionName, t.teamName
</cfquery>

<div class="section">
    <div class="container">
        <div class="card" style="max-width: 540px; margin: 30px auto; padding: 30px;">
            <h3 style="margin-bottom: 6px;">Change Team</h3>
            <p style="color: ##666; margin-bottom: 24px;">
                Select the team you want to join, or choose Free Agent to remove yourself from your current team.
            </p>

            <form method="post" action="switch_team_confirm.cfm?playerID=#url.playerID#">
                <div style="margin-bottom: 20px;">
                    <label for="newTeamID" style="display:block; font-weight:600; margin-bottom:8px;">Select Team</label>
                    <select name="newTeamID" id="newTeamID" class="form-control" required>
                        <option value="0">-- Free Agent (no team) --</option>
                        <cfloop query="getActiveTeams">
                            <option value="#teamID#"
                                <cfif isDefined("getPlayerData") AND getPlayerData.recordCount GT 0 AND getPlayerData.teamID EQ teamID>selected</cfif>
                            >#divisionName# - #teamName#</option>
                        </cfloop>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;">Continue</button>
                <a href="account_home.cfm?playerID=#url.playerID#" class="btn btn-link" style="width:100%; text-align:center; margin-top:8px; display:block;">Cancel</a>
            </form>
        </div>
    </div>
</div>
</cfoutput>

<cfinclude template="/footer.cfm">
