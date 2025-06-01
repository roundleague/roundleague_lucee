<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfinclude template="get_team_payment_status.cfm">

<cfoutput>
<!--- Get player data with team information --->
<cfquery name="playerTeamInfo" datasource="roundleague">
    SELECT p.playerID, p.firstName, p.lastName, t.teamID, t.teamName
    FROM Players p
    JOIN Roster r ON p.playerID = r.playerID
    JOIN Teams t ON r.teamID = t.teamID
    WHERE p.playerID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.playerID#">
    AND r.seasonID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.currentSeasonID#">
</cfquery>

<!--- Count number of players on roster to calculate suggested contribution --->
<cfset suggestedAmount = 100>
<cfif playerTeamInfo.recordCount GT 0>
    <cfquery name="rosterCount" datasource="roundleague">
        SELECT COUNT(*) as totalPlayers
        FROM Roster
        WHERE teamID = <cfqueryparam cfsqltype="cf_sql_integer" value="#playerTeamInfo.teamID#">
        AND seasonID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.currentSeasonID#">
    </cfquery>
    
    <cfif rosterCount.totalPlayers GT 0>
        <cfset suggestedAmount = ceiling(1000 / rosterCount.totalPlayers)>
    </cfif>
</cfif>

<!--- Get team payment status --->
<cfif playerTeamInfo.recordCount GT 0>
    <cfset teamPaymentStatus = getTeamPaymentStatus(teamID=playerTeamInfo.teamID, seasonID=session.currentSeasonID)>
<cfelse>
    <cfset teamPaymentStatus = {
        teamID: 0,
        seasonID: session.currentSeasonID,
        teamPayments: 0,
        playerContributions: 0,
        totalPaid: 0,
        teamFee: 1000,
        percentPaid: 0,
        remainingBalance: 1000,
        isFullyPaid: false
    }>
</cfif>

<!--- Show player's individual contributions --->
<cfquery name="playerContributions" datasource="roundleague">
    SELECT 
        amount, created_at, stripe_session_id
    FROM 
        player_payment_contributions
    WHERE 
        player_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.playerID#">
        AND team_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#playerTeamInfo.teamID#">
        AND season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.currentSeasonID#">
    ORDER BY
        created_at DESC
</cfquery>

<cfinclude template="../account_header.cfm">

<div class="profile-content section">
    <div class="container">
        <div class="row">
            <div class="col-md-10 ml-auto mr-auto">
                <div class="card">
                    <div class="card-header">
                        <h4 class="card-title">Team Payment Status</h4>
                        <p class="category">Season: #session.currentSeasonID#</p>
                    </div>
                    <div class="card-body">
                        <cfif playerTeamInfo.recordCount GT 0>
                            <h5>Team: #playerTeamInfo.teamName#</h5>
                        
                        <!--- Progress Bar --->
                        <div class="progress-container">
                            <span class="progress-badge">Payment Progress</span>
                            <div class="progress">
                                <div class="progress-bar" role="progressbar" 
                                    aria-valuenow="#numberFormat(teamPaymentStatus.percentPaid, '999.99')#" 
                                    aria-valuemin="0" aria-valuemax="100" 
                                    style="width: #numberFormat(teamPaymentStatus.percentPaid, '999.99')#%;">
                                    <span class="progress-value">#numberFormat(teamPaymentStatus.percentPaid, '999.99')#%</span>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Payment Summary --->
                        <div class="row mt-4">
                            <div class="col-md-4">
                                <div class="card bg-light">
                                    <div class="card-body text-center">
                                        <h5>Total Team Fee</h5>
                                        <h3>$#numberFormat(teamPaymentStatus.teamFee, '999,999.99')#</h3>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card bg-light">
                                    <div class="card-body text-center">
                                        <h5>Total Paid</h5>
                                        <h3>$#numberFormat(teamPaymentStatus.totalPaid, '999,999.99')#</h3>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card bg-light">
                                    <div class="card-body text-center">
                                        <h5>Remaining Balance</h5>
                                        <h3>$#numberFormat(teamPaymentStatus.remainingBalance, '999,999.99')#</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Payment Breakdown --->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Team Payments</h5>
                                    </div>
                                    <div class="card-body">
                                        <p>Full team payments: $#numberFormat(teamPaymentStatus.teamPayments, '999,999.99')#</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Player Contributions</h5>
                                    </div>
                                    <div class="card-body">
                                        <p>Total player contributions: $#numberFormat(teamPaymentStatus.playerContributions, '999,999.99')#</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Your Contributions --->
                        <div class="card mt-4">
                            <div class="card-header">
                                <h5 class="card-title">Your Contributions</h5>
                            </div>
                            <div class="card-body">
                                <cfif playerContributions.recordCount GT 0>
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Amount</th>
                                                <th>Date</th>
                                                <th>Transaction ID</th>
                                            </tr>
                                        </thead>
                                        <tbody>                                            <cfloop query="playerContributions">
                                                <tr>
                                                    <td>$#numberFormat(amount, '999,999.99')#</td>
                                                    <td>#dateFormat(created_at, 'mm/dd/yyyy')# #timeFormat(created_at, 'hh:mm tt')#</td>
                                                    <td>#stripe_session_id#</td>
                                                </tr>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                <cfelse>
                                    <p>You haven't made any contributions toward your team fee yet.</p>
                                </cfif>
                            </div>
                        </div>
                        
                        <!--- Payment Options --->                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Make a Player Contribution</h5>
                                    </div>
                                    <div class="card-body">
                                        <p>Contribute a portion of the team fee ($#numberFormat(suggestedAmount, '999,999')# suggested based on roster size of #rosterCount.totalPlayers# players).</p>
                                        <a href="/pages/account/payments/account_stripe_checkout.cfm?playerID=#url.playerID#&teamID=#playerTeamInfo.teamID#&paymentType=player&amount=#suggestedAmount#" 
                                           class="btn btn-primary btn-round">
                                           Pay $#numberFormat(suggestedAmount, '999,999')#
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Pay Full Team Fee</h5>
                                    </div>
                                    <div class="card-body">
                                        <p>Pay the entire team fee or remaining balance.</p>
                                        <cfif teamPaymentStatus.isFullyPaid>
                                            <button class="btn btn-success btn-round" disabled>Already Paid</button>
                                        <cfelse>
                                            <a href="/pages/account/payments/account_stripe_checkout.cfm?playerID=#url.playerID#&teamID=#playerTeamInfo.teamID#&paymentType=captain" 
                                               class="btn btn-danger btn-round">
                                               Pay $#numberFormat(teamPaymentStatus.remainingBalance, '999,999.99')#
                                            </a>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        </div>                    <cfelse>
                        <div class="alert alert-warning">
                            <p>You are not currently assigned to a team for this season, or your team is not active.</p>
                        </div>
                    </cfif>
                </div>
            </div>
        </div>
    </div>
</div>

</cfoutput>

<cfinclude template="/footer.cfm">
