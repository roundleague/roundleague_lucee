<cffunction name="getTeamPaymentStatus" access="public" returntype="struct">
    <cfargument name="teamID" type="numeric" required="true">
    <cfargument name="seasonID" type="string" required="true">
    
    <!--- Get the team fee for this season from the database --->
    <cfquery name="qrySeasonFee" datasource="roundleague">
        SELECT COALESCE(team_fee, 1000) as team_fee
        FROM seasons
        WHERE seasonID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.seasonID#">
    </cfquery>
    <cfset local.teamFee = qrySeasonFee.recordCount GT 0 ? qrySeasonFee.team_fee : 1000>
    
    <cfquery name="qryTeamPayments" datasource="roundleague">
        SELECT 
            COALESCE(SUM(tp.amount_paid), 0) as team_payment_total
        FROM 
            team_payments tp
        WHERE 
            tp.team_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.teamID#">
            AND tp.season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.seasonID#">
    </cfquery>
    
    <cfquery name="qryPlayerContributions" datasource="roundleague">
        SELECT 
            COALESCE(SUM(ppc.amount), 0) as player_contribution_total
        FROM 
            player_payment_contributions ppc
        WHERE 
            ppc.team_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.teamID#">
            AND ppc.season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.seasonID#">
    </cfquery>
    
    <cfset local.totalPaid = qryTeamPayments.team_payment_total + qryPlayerContributions.player_contribution_total>
    <cfset local.percentPaid = local.teamFee GT 0 ? (local.totalPaid / local.teamFee) * 100 : 0>
    <cfset local.isFullyPaid = local.totalPaid GTE local.teamFee>
    
    <cfreturn {
        teamID: arguments.teamID,
        seasonID: arguments.seasonID,
        teamPayments: qryTeamPayments.team_payment_total,
        playerContributions: qryPlayerContributions.player_contribution_total,
        totalPaid: local.totalPaid,
        teamFee: local.teamFee,
        percentPaid: local.percentPaid,
        remainingBalance: local.teamFee - local.totalPaid,
        isFullyPaid: local.isFullyPaid
    }>
</cffunction>

<!--- Usage example: 
<cfset teamPaymentStatus = getTeamPaymentStatus(teamID=1, seasonID="Spring 2023")>
<cfdump var="#teamPaymentStatus#">
--->
