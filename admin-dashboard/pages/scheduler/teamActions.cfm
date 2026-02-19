<cfsilent>
<!--- AJAX handler for team actions from Schedule Import ---
     Actions: addTeam, markInactive
--->
<cfparam name="form.action" default="">
<cfparam name="form.teamName" default="">
<cfparam name="form.newTeamName" default="">
<cfparam name="form.divisionID" default="0">
<cfparam name="form.teamID" default="0">

<cfset response = {"success": false, "message": "", "teamID": 0, "teamName": ""}>

<cfcontent type="application/json">

<cftry>
    <cfswitch expression="#form.action#">
        
        <!--- Add new team --->
        <cfcase value="addTeam">
            <cfif NOT len(trim(form.teamName))>
                <cfthrow message="Team name is required.">
            </cfif>
            <cfif NOT isNumeric(form.divisionID) OR form.divisionID EQ 0>
                <cfthrow message="Division ID is required.">
            </cfif>
            
            <!--- Check if team already exists --->
            <cfquery name="checkExists" datasource="roundleague">
                SELECT teamID FROM teams
                WHERE LOWER(teamName) = LOWER(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(form.teamName)#">)
                AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
            </cfquery>
            
            <cfif checkExists.recordCount GT 0>
                <cfthrow message="A team with this name already exists.">
            </cfif>
            
            <!--- Insert new team --->
            <cfquery name="insertTeam" datasource="roundleague">
                INSERT INTO teams (Status, teamName, DivisionID, SeasonID, RegisterDate)
                VALUES (
                    'Active',
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(form.teamName)#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">,
                    <cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">
                )
            </cfquery>
            
            <cfquery name="getNewID" datasource="roundleague">
                SELECT LAST_INSERT_ID() AS newTeamID
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Team added successfully.">
            <cfset response.teamID = getNewID.newTeamID>
            <cfset response.teamName = trim(form.teamName)>
        </cfcase>
        
        <!--- Rename a team --->
        <cfcase value="renameTeam">
            <cfif NOT isNumeric(form.teamID) OR form.teamID EQ 0>
                <cfthrow message="Team ID is required.">
            </cfif>
            <cfif NOT len(trim(form.newTeamName))>
                <cfthrow message="New team name is required.">
            </cfif>
            
            <!--- Verify the team exists --->
            <cfquery name="getTeam" datasource="roundleague">
                SELECT teamName FROM teams
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
            </cfquery>
            
            <cfif getTeam.recordCount EQ 0>
                <cfthrow message="Team not found.">
            </cfif>
            
            <!--- Update the team name --->
            <cfquery name="renameTeam" datasource="roundleague">
                UPDATE teams
                SET teamName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(form.newTeamName)#">
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Team renamed successfully.">
            <cfset response.teamID = form.teamID>
            <cfset response.teamName = trim(form.newTeamName)>
        </cfcase>
        
        <!--- Activate an inactive team --->
        <cfcase value="activateTeam">
            <cfif NOT isNumeric(form.teamID) OR form.teamID EQ 0>
                <cfthrow message="Team ID is required.">
            </cfif>
            <cfif NOT isNumeric(form.divisionID) OR form.divisionID EQ 0>
                <cfthrow message="Division ID is required.">
            </cfif>
            
            <!--- Get team name before updating --->
            <cfquery name="getTeam" datasource="roundleague">
                SELECT teamName FROM teams
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
            </cfquery>
            
            <cfif getTeam.recordCount EQ 0>
                <cfthrow message="Team not found.">
            </cfif>
            
            <!--- Update team: set Active, assign division and current season --->
            <cfquery name="activateTeam" datasource="roundleague">
                UPDATE teams
                SET Status = 'Active',
                    DivisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">,
                    SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Team activated successfully.">
            <cfset response.teamID = form.teamID>
            <cfset response.teamName = getTeam.teamName>
        </cfcase>
        
        <!--- Move team to different division --->
        <cfcase value="moveDivision">
            <cfif NOT isNumeric(form.teamID) OR form.teamID EQ 0>
                <cfthrow message="Team ID is required.">
            </cfif>
            <cfif NOT isNumeric(form.divisionID) OR form.divisionID EQ 0>
                <cfthrow message="Division ID is required.">
            </cfif>
            
            <cfquery name="moveTeam" datasource="roundleague">
                UPDATE teams
                SET DivisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.divisionID#">
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
                AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Team moved to new division.">
            <cfset response.teamID = form.teamID>
        </cfcase>
        
        <!--- Mark team as inactive --->
        <cfcase value="markInactive">
            <cfif NOT isNumeric(form.teamID) OR form.teamID EQ 0>
                <cfthrow message="Team ID is required.">
            </cfif>
            
            <cfquery name="updateTeam" datasource="roundleague">
                UPDATE teams
                SET Status = 'Inactive'
                WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
                AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Team marked as inactive.">
            <cfset response.teamID = form.teamID>
        </cfcase>
        
        <cfdefaultcase>
            <cfthrow message="Invalid action.">
        </cfdefaultcase>
        
    </cfswitch>
    
    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfoutput>#serializeJSON(response)#</cfoutput>
