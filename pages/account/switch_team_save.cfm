<cfparam name="url.playerID" default="0">
<cfparam name="form.newTeamID" default="">

<cfinclude template="account_security_check.cfm">

<cfoutput>
<!--- Validate input --->
<cfif NOT isNumeric(form.newTeamID)>
    <cflocation url="account_home.cfm?playerID=#url.playerID#" addtoken="false">
</cfif>

<cfset newTeamID = int(form.newTeamID)>

<!--- If not free agent, verify the team is valid for this season --->
<cfset teamDisplayName = "Free Agent">
<cfif newTeamID GT 0>
    <cfquery name="validateTeam" datasource="roundleague">
        SELECT teamID, teamName FROM teams
        WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newTeamID#">
        AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND status = 'Active'
    </cfquery>
    <cfif validateTeam.recordCount EQ 0>
        <cflocation url="switch_team.cfm?playerID=#url.playerID#" addtoken="false">
    </cfif>
    <cfset teamDisplayName = validateTeam.teamName>
</cfif>

<!--- Get current teamID for transaction log --->
<cfquery name="getCurrentTeam" datasource="roundleague">
    SELECT teamID FROM roster
    WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.playerID#">
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<cfset fromTeamID = 0>
<cfif getCurrentTeam.recordCount GT 0>
    <cfset fromTeamID = getCurrentTeam.teamID>
</cfif>

<!--- Update roster --->
<cfquery datasource="roundleague">
    UPDATE roster
    SET teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newTeamID#">
    WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.playerID#">
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<!--- Log transaction (captainModifiedBy = 0 = self-service) --->
<cfquery datasource="roundleague">
    INSERT INTO transactions (playerID, fromTeamID, toTeamID, seasonID, captainModifiedBy, dateModified)
    VALUES (
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.playerID#">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#fromTeamID#">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#newTeamID#">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
        0,
        NOW()
    )
</cfquery>

<cflocation url="account_home.cfm?playerID=#url.playerID#&switched=1&teamName=#urlEncodedFormat(teamDisplayName)#" addtoken="false">
</cfoutput>
