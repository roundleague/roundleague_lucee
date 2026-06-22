<cfif NOT isDefined("form.rulesContent")>
    <cflocation url="/admin-dashboard/pages/leagueRules/leagueRules.cfm?error=1" addtoken="false">
    <cfabort>
</cfif>

<cftry>
    <cfquery datasource="roundleague">
        INSERT INTO site_content (pageKey, contentHTML)
        VALUES (
            'league-rules',
            <cfqueryparam cfsqltype="cf_sql_clob" value="#form.rulesContent#">
        )
        ON DUPLICATE KEY UPDATE
            contentHTML = VALUES(contentHTML),
            updatedAt   = NOW()
    </cfquery>

    <cflocation url="/admin-dashboard/pages/leagueRules/leagueRules.cfm?saved=1" addtoken="false">

    <cfcatch type="any">
        <cflocation url="/admin-dashboard/pages/leagueRules/leagueRules.cfm?error=1" addtoken="false">
    </cfcatch>
</cftry>
