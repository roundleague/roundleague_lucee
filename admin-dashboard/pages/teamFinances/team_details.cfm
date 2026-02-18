<cfparam name="url.teamID" default="0">
<cfparam name="session.currentSeasonID" default="0">

<cftry>
<cfinclude template="/pages/account/payments/get_team_payment_status.cfm">

<cfoutput>
<!--- Get team info --->
<cfquery name="getTeamInfo" datasource="roundleague">
    SELECT 
        t.teamID, 
        t.teamName, 
        d.DivisionName,
        p.firstName,
        p.lastName,
        p.email AS captainEmail,
        p.phone AS captainPhone
    FROM 
        teams t
    LEFT JOIN 
        divisions d ON d.divisionID = t.DivisionID
    LEFT JOIN 
        players p ON p.PlayerID = t.captainPlayerID
    WHERE 
        t.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
</cfquery>

<!--- Get payment data --->
<cfset teamStatus = getTeamPaymentStatus(teamID=url.teamID, seasonID=session.currentSeasonID)>

<!--- Get team payments --->
<cfquery name="getTeamPayments" datasource="roundleague">
    SELECT 
        tp.amount_paid,
        tp.payment_method,
        tp.stripe_session_id,
        p.firstName,
        p.lastName,
        tp.created_at
    FROM 
        team_payments tp
    LEFT JOIN
        players p ON p.playerID = tp.paid_by_player_id
    WHERE 
        tp.team_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
    AND 
        tp.season = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.currentSeasonID#">
    ORDER BY 
        tp.created_at DESC
</cfquery>

<!--- Get player contributions --->
<cfquery name="getPlayerContributions" datasource="roundleague">
    SELECT 
        pc.amount,
        pc.created_at,
        pc.stripe_session_id,
        p.firstName,
        p.lastName
    FROM 
        player_payment_contributions pc
    JOIN
        players p ON p.playerID = pc.player_id
    WHERE 
        pc.team_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
    AND 
        pc.season = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.currentSeasonID#">
    ORDER BY 
        pc.created_at DESC
</cfquery>

<!--- Get roster --->
<cfquery name="getTeamRoster" datasource="roundleague">
    SELECT 
        p.playerID,
        p.firstName,
        p.lastName,
        p.email,
        p.phone,
        r.jersey
    FROM 
        Roster r
    JOIN
        players p ON p.playerID = r.playerID
    WHERE 
        r.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
    AND 
        r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    ORDER BY 
        p.lastName, p.firstName
</cfquery>

<cfif getTeamInfo.recordCount GT 0>
    <div class="row">
        <div class="col-md-6">
            <h4>#getTeamInfo.teamName#</h4>
            <p><strong>Division:</strong> #getTeamInfo.DivisionName#</p>
            <p><strong>Captain:</strong> #getTeamInfo.firstName# #getTeamInfo.lastName#</p>
            <p><strong>Contact:</strong> #getTeamInfo.captainEmail#<cfif len(getTeamInfo.captainPhone)> / #getTeamInfo.captainPhone#</cfif></p>
        </div>
        <div class="col-md-6">
            <div class="payment-summary">
                <h5>Payment Summary</h5>
                <div class="progress mb-3">
                    <div class="progress-bar 
                        <cfif teamStatus.percentPaid GTE 100>
                            bg-success
                        <cfelseif teamStatus.percentPaid GTE 50>
                            bg-info
                        <cfelseif teamStatus.percentPaid GTE 25>
                            bg-warning
                        <cfelse>
                            bg-danger
                        </cfif>" 
                        role="progressbar" 
                        style="width: #numberFormat(teamStatus.percentPaid, '999.9')#%" 
                        aria-valuenow="#numberFormat(teamStatus.percentPaid, '999.9')#" 
                        aria-valuemin="0" 
                        aria-valuemax="100">
                        #numberFormat(teamStatus.percentPaid, '999.9')#%
                    </div>
                </div>
                
                <table class="table table-sm">
                    <tr>
                        <td>Team Fee:</td>
                        <td class="text-right">$#numberFormat(teamStatus.teamFee, '999,999.00')#</td>
                    </tr>
                    <tr>
                        <td>Team Payments:</td>
                        <td class="text-right">$#numberFormat(teamStatus.teamPayments, '999,999.00')#</td>
                    </tr>
                    <tr>
                        <td>Player Contributions:</td>
                        <td class="text-right">$#numberFormat(teamStatus.playerContributions, '999,999.00')#</td>
                    </tr>
                    <tr>
                        <td><strong>Total Paid:</strong></td>
                        <td class="text-right"><strong>$#numberFormat(teamStatus.totalPaid, '999,999.00')#</strong></td>
                    </tr>
                    <tr>
                        <td><strong>Remaining Balance:</strong></td>
                        <td class="text-right"><strong>$#numberFormat(teamStatus.remainingBalance, '999,999.00')#</strong></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    
    <hr>
    
    <div class="row">
        <div class="col-md-12">
            <ul class="nav nav-tabs" id="paymentTabs" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="roster-tab" data-toggle="tab" href="##roster" role="tab" aria-controls="roster" aria-selected="true">Team Roster (#getTeamRoster.recordCount#)</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="team-payments-tab" data-toggle="tab" href="##team-payments" role="tab" aria-controls="team-payments" aria-selected="false">Team Payments (#getTeamPayments.recordCount#)</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="player-contributions-tab" data-toggle="tab" href="##player-contributions" role="tab" aria-controls="player-contributions" aria-selected="false">Player Contributions (#getPlayerContributions.recordCount#)</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="add-payment-tab" data-toggle="tab" href="##add-payment" role="tab" aria-controls="add-payment" aria-selected="false"><i class="nc-icon nc-simple-add"></i> Add Manual Payment</a>
                </li>
            </ul>
            
            <div class="tab-content" id="paymentTabContent">
                <!-- Team Roster Tab -->
                <div class="tab-pane fade show active" id="roster" role="tabpanel" aria-labelledby="roster-tab">
                    <div class="table-responsive mt-3">
                        <table class="table table-striped table-sm">
                            <thead>
                                <tr>
                                    <th>##</th>
                                    <th>Player Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="getTeamRoster">
                                    <tr>
                                        <td>#jersey#</td>
                                        <td>#firstName# #lastName#</td>
                                        <td>#email#</td>
                                        <td>#phone#</td>
                                        <td>
                                            <a href="/pages/account/payments/payment_status.cfm?playerID=#playerID#" class="btn btn-sm btn-info" target="_blank">
                                                <i class="nc-icon nc-money-coins"></i>
                                            </a>
                                            <a href="/pages/account/account_home.cfm?playerID=#playerID#" class="btn btn-sm btn-primary" target="_blank">
                                                <i class="nc-icon nc-single-02"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Team Payments Tab -->
                <div class="tab-pane fade" id="team-payments" role="tabpanel" aria-labelledby="team-payments-tab">
                    <div class="table-responsive mt-3">
                        <table class="table table-striped table-sm">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Paid By</th>
                                    <th>Method</th>
                                    <th>Transaction ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif getTeamPayments.recordCount GT 0>
                                    <cfloop query="getTeamPayments">
                                        <tr>
                                            <td>#dateFormat(created_at, 'mm/dd/yyyy')# #timeFormat(created_at, 'h:mm tt')#</td>
                                            <td>$#numberFormat(amount_paid, '999,999.00')#</td>
                                            <td>#firstName# #lastName#</td>
                                            <td>#payment_method#</td>
                                            <td>#stripe_session_id#</td>
                                        </tr>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <td colspan="5" class="text-center">No team payments recorded.</td>
                                    </tr>
                                </cfif>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Player Contributions Tab -->
                <div class="tab-pane fade" id="player-contributions" role="tabpanel" aria-labelledby="player-contributions-tab">
                    <div class="table-responsive mt-3">
                        <table class="table table-striped table-sm">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Player</th>
                                    <th>Transaction ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif getPlayerContributions.recordCount GT 0>
                                    <cfloop query="getPlayerContributions">
                                        <tr>
                                            <td>#dateFormat(created_at, 'mm/dd/yyyy')# #timeFormat(created_at, 'h:mm tt')#</td>
                                            <td>$#numberFormat(amount, '999,999.00')#</td>
                                            <td>#firstName# #lastName#</td>
                                            <td>#stripe_session_id#</td>
                                        </tr>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <td colspan="4" class="text-center">No player contributions recorded.</td>
                                    </tr>
                                </cfif>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Add Manual Payment Tab -->
                <div class="tab-pane fade" id="add-payment" role="tabpanel" aria-labelledby="add-payment-tab">
                    <div class="mt-3">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title">Add Manual/Offline Payment</h5>
                                <p class="card-category">Record payments made outside of Stripe (cash, Venmo, check, etc.)</p>
                            </div>
                            <div class="card-body">
                                <form action="add_manual_payment.cfm" method="post">
                                    <input type="hidden" name="teamID" value="#url.teamID#">
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Payment Type</label>
                                                <select name="paymentType" id="paymentType" class="form-control" required>
                                                    <option value="team">Team Payment (Full/Partial Fee)</option>
                                                    <option value="player">Player Contribution</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Payment Method</label>
                                                <select name="paymentMethod" class="form-control" required>
                                                    <option value="cash">Cash</option>
                                                    <option value="venmo">Venmo</option>
                                                    <option value="zelle">Zelle</option>
                                                    <option value="check">Check</option>
                                                    <option value="paypal">PayPal</option>
                                                    <option value="stripe">Stripe</option>
                                                    <option value="other">Other</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Amount ($)</label>
                                                <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="Enter amount">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Player <span id="playerRequiredText" style="display:none;">(Required for player contributions)</span></label>
                                                <select name="playerID" id="playerID" class="form-control">
                                                    <option value="0">-- Select Player (Optional) --</option>
                                                    <cfloop query="getTeamRoster">
                                                        <option value="#playerID#">#firstName# #lastName#</option>
                                                    </cfloop>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Notes (Optional)</label>
                                        <input type="text" name="notes" class="form-control" placeholder="e.g., Venmo from John on 2/15, Check ##1234">
                                    </div>
                                    
                                    <button type="submit" class="btn btn-success btn-round">
                                        <i class="nc-icon nc-check-2"></i> Record Payment
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                
                <script>
                document.getElementById('paymentType').addEventListener('change', function() {
                    var playerSelect = document.getElementById('playerID');
                    var requiredText = document.getElementById('playerRequiredText');
                    if (this.value === 'player') {
                        playerSelect.required = true;
                        requiredText.style.display = 'inline';
                    } else {
                        playerSelect.required = false;
                        requiredText.style.display = 'none';
                    }
                });
                </script>
            </div>
        </div>
    </div>
<cfelse>
    <div class="alert alert-warning">
        Team information not found.
    </div>
</cfif>
</cfoutput>

<cfcatch>
    <div class="alert alert-danger">
        <strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput><br>
        <strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput><br>
        <strong>Type:</strong> <cfoutput>#cfcatch.type#</cfoutput><br>
        <cfif structKeyExists(cfcatch, "tagContext") AND arrayLen(cfcatch.tagContext) GT 0>
            <strong>Location:</strong> <cfoutput>#cfcatch.tagContext[1].template# (line #cfcatch.tagContext[1].line#)</cfoutput>
        </cfif>
    </div>
</cfcatch>
</cftry>
