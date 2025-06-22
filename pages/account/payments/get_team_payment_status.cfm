<cffunction name="getTeamPaymentStatus" access="public" returntype="struct">
    <cfargument name="teamID" type="numeric" required="true">
    <cfargument name="seasonID" type="string" required="true">
    
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
    <cfset local.teamFee = 1000> <!--- You may want to make this configurable per season --->
    <cfset local.percentPaid = (local.totalPaid / local.teamFee) * 100>
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
