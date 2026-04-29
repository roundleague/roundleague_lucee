<cfinclude template="/header.cfm">
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet">

<cfparam name="url.playerID" default="0">
<cfparam name="form.newTeamID" default="">

<cfoutput>
<cfinclude template="account_header.cfm">

<!--- Validate input --->
<cfif NOT isNumeric(form.newTeamID)>
    <cflocation url="switch_team.cfm?playerID=#url.playerID#" addtoken="false">
</cfif>

<cfset newTeamID = int(form.newTeamID)>

<!--- Look up team name if not free agent --->
<cfif newTeamID GT 0>
    <cfquery name="getNewTeam" datasource="roundleague">
        SELECT teamID, teamName FROM teams
        WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newTeamID#">
        AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND status = 'Active'
    </cfquery>
    <cfif getNewTeam.recordCount EQ 0>
        <cflocation url="switch_team.cfm?playerID=#url.playerID#" addtoken="false">
    </cfif>
    <cfset displayName = getNewTeam.teamName>
<cfelse>
    <cfset displayName = "Free Agent">
</cfif>

<div class="section">
    <div class="container">
        <div class="card" style="max-width: 540px; margin: 30px auto; padding: 30px;">

            <div style="background:##fffbeb; border: 2px solid ##f59e0b; border-radius: 10px; padding: 24px; margin-bottom: 28px; text-align:center;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size:28px; color:##b45309; margin-bottom:12px; display:block;"></i>
                <h4 style="color:##92400e; margin-bottom:12px;">Before you continue</h4>
                <p style="color:##78350f; line-height:1.6; margin-bottom:10px;">
                    By joining <strong>#displayName#</strong>, you confirm that you have received approval from that team's captain.
                </p>
                <p style="color:##78350f; line-height:1.6; margin:0;">
                    Switching teams without captain approval, or abusing this feature, may result in a <strong style="color:##dc2626;">ban from the league</strong>.
                </p>
            </div>

            <form method="post" action="switch_team_save.cfm?playerID=#url.playerID#">
                <input type="hidden" name="newTeamID" value="#newTeamID#">
                <button type="submit" class="btn btn-primary" style="width:100%; margin-bottom:10px;">
                    Confirm - Join #displayName#
                </button>
            </form>
            <a href="switch_team.cfm?playerID=#url.playerID#" class="btn btn-link" style="width:100%; text-align:center; display:block;">Go Back</a>
        </div>
    </div>
</div>
</cfoutput>

<cfinclude template="/footer.cfm">
