<!--- update_team_fee.cfm - Updates the team fee for a season --->
<cfparam name="form.teamFee" default="0">
<cfparam name="form.seasonID" default="#session.currentSeasonID#">

<cfset response = {success: false, message: ""}>

<cftry>
    <cfif NOT isNumeric(form.teamFee) OR form.teamFee LT 0>
        <cfthrow message="Invalid team fee amount">
    </cfif>
    
    <!--- Update the season's team fee --->
    <cfquery datasource="roundleague">
        UPDATE seasons 
        SET team_fee = <cfqueryparam cfsqltype="cf_sql_decimal" value="#form.teamFee#">
        WHERE seasonID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.seasonID#">
    </cfquery>
    
    <cfset response.success = true>
    <cfset response.message = "Team fee updated successfully">
    
<cfcatch>
    <cfset response.success = false>
    <cfset response.message = cfcatch.message>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
