<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->
<link href="teamFinances.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!--- Include the team payment status function --->
<cfinclude template="/pages/account/payments/get_team_payment_status.cfm">

<!--- Get the team fee for the current season (with fallback to 1000 if not set) --->
<cfquery name="getSeasonFee" datasource="roundleague">
    SELECT COALESCE(team_fee, 1000) as team_fee
    FROM seasons
    WHERE seasonID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.currentSeasonID#">
</cfquery>
<cfset seasonTeamFee = getSeasonFee.recordCount GT 0 ? getSeasonFee.team_fee : 1000>

<cfoutput>

<!--- Get all active teams for the current season --->
<cfquery name="getTeams" datasource="roundleague">
    SELECT 
        t.teamID, 
        t.teamName, 
        d.DivisionName,
        d.divisionID,
        p.firstName,
        p.lastName,
        p.playerID AS captainID,
        (
            SELECT COUNT(*) 
            FROM Roster r 
            WHERE r.teamID = t.teamID 
            AND r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        ) AS rosterCount
    FROM 
        teams t
    LEFT JOIN 
        divisions d ON d.divisionID = t.DivisionID
    LEFT JOIN 
        players p ON p.PlayerID = t.captainPlayerID
    WHERE 
        t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND 
        t.status = 'Active'
    ORDER BY 
        d.DivisionName, t.teamName
</cfquery>

<!--- Get unique divisions for grouping --->
<cfquery name="getDivisions" dbtype="query">
    SELECT DISTINCT divisionID, DivisionName
    FROM getTeams
    WHERE divisionID IS NOT NULL
    ORDER BY DivisionName
</cfquery>

<!--- Get total payments for all teams for stats --->
<cfquery name="getTotalPayments" datasource="roundleague">
    SELECT 
        COALESCE(SUM(tp.amount_paid), 0) as total_team_payments
    FROM 
        team_payments tp
    WHERE 
        tp.season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.currentSeasonID#">
</cfquery>

<cfquery name="getTotalContributions" datasource="roundleague">
    SELECT 
        COALESCE(SUM(ppc.amount), 0) as total_player_contributions
    FROM 
        player_payment_contributions ppc
    WHERE 
        ppc.season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.currentSeasonID#">
</cfquery>

<!--- Calculate overall stats --->
<cfset totalTeamFees = getTeams.recordCount * seasonTeamFee>
<cfset totalCollected = getTotalPayments.total_team_payments + getTotalContributions.total_player_contributions>
<cfset totalRemaining = totalTeamFees - totalCollected>
<cfset overallPercentage = totalTeamFees GT 0 ? (totalCollected / totalTeamFees) * 100 : 0>

<!--- Get total number of teams for reference --->
<cfquery name="getAllTeamsCount" datasource="roundleague">
    SELECT COUNT(*) AS totalTeams
    FROM teams t
    WHERE t.STATUS = 'Active'
    AND t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>

<!--- Process each team to get payment status --->
<cfset teamPaymentData = []>
<cfset divisionTotals = {}>

<cfloop query="getTeams">
    <cfset teamStatus = getTeamPaymentStatus(teamID=teamID, seasonID=session.currentSeasonID)>
    <cfset arrayAppend(teamPaymentData, teamStatus)>
    
    <!--- Track division totals for the charts --->
    <cfif NOT structKeyExists(divisionTotals, DivisionName)>
        <cfset divisionTotals[DivisionName] = {
            totalFee: 0,
            totalPaid: 0,
            teamCount: 0
        }>
    </cfif>
    <cfset divisionTotals[DivisionName].totalFee += teamStatus.teamFee>
    <cfset divisionTotals[DivisionName].totalPaid += teamStatus.totalPaid>
    <cfset divisionTotals[DivisionName].teamCount++>
</cfloop>

<!-- End Navbar -->
<div class="content">
    <!--- Success/Error Messages --->
    <cfif isDefined("url.paymentAdded") AND url.paymentAdded EQ 1>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="nc-icon nc-check-2"></i> Payment recorded successfully!
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </cfif>
    <cfif isDefined("url.feeUpdated") AND url.feeUpdated EQ 1>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="nc-icon nc-check-2"></i> Team fee updated to $#numberFormat(seasonTeamFee, '999,999')#
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </cfif>
    <cfif isDefined("url.error") AND len(url.error)>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="nc-icon nc-simple-remove"></i> Error: #url.error#
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </cfif>
    
    <div class="row">
        <div class="col-md-12">
            <div class="d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h3 class="description">Team Finances - Season <span class="badge badge-primary">#session.currentSeasonID#</span></h3>
                    <p class="text-muted"><i class="fa fa-users"></i> Showing all #getTeams.recordCount# active teams</p>
                </div>
                <div class="card card-stats mb-3" style="min-width: 280px;">
                    <div class="card-body py-2">
                        <div class="row align-items-center">
                            <div class="col-12">
                                <label class="mb-1 text-muted small"><i class="nc-icon nc-settings-gear-65"></i> Team Fee (per team)</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">$</span>
                                    </div>
                                    <input type="number" id="teamFeeInput" class="form-control" value="#int(seasonTeamFee)#" min="0" step="50">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary" type="button" onclick="updateTeamFee()" id="updateFeeBtn">
                                                <i class="nc-icon nc-check-2"></i> Update
                                            </button>
                                        </div>
                                        <script>
                                        // If input is empty or zero, set default
                                        document.addEventListener('DOMContentLoaded', function() {
                                            var feeInput = document.getElementById('teamFeeInput');
                                            if (!feeInput.value || parseFloat(feeInput.value) === 0) {
                                                feeInput.value = 1000;
                                            }
                                        });
                                        </script>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Summary Cards --->
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body ">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-money-coins text-warning"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Total Fees</p>
                                <p class="card-title">$#numberFormat(totalTeamFees, '999,999')#</p>
                            </div>
                        </div>
                    </div>
                </div>                <div class="card-footer ">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-users"></i> #getTeams.recordCount# active teams
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body ">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-check-2 text-success"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Collected</p>
                                <p class="card-title">$#numberFormat(totalCollected, '999,999')#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer ">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-calculator"></i> #numberFormat(overallPercentage, '999.9')#% of total fees
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body ">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-time-alarm text-danger"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Remaining</p>
                                <p class="card-title">$#numberFormat(totalRemaining, '999,999')#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer ">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-clock-o"></i> Still to be collected
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body ">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-chart-pie-36 text-primary"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Paid Teams</p>
                                <cfset paidTeamsCount = 0>
                                <cfloop array="#teamPaymentData#" index="team">
                                    <cfif team.isFullyPaid>
                                        <cfset paidTeamsCount++>
                                    </cfif>
                                </cfloop>
                                <p class="card-title">#paidTeamsCount# / #getTeams.recordCount#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer ">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-check"></i> <cfif paidTeamsCount EQ getTeams.recordCount>All teams paid in full!<cfelse>#numberFormat((paidTeamsCount/getTeams.recordCount)*100, '999.9')#% of teams paid in full</cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Payment Overview Charts --->
    <div class="row">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Division Payment Status</h5>
                    <p class="card-category">Payment distribution by division</p>
                </div>
                <div class="card-body">
                    <canvas id="divisionChart" width="100%" height="50"></canvas>
                </div>
                <div class="card-footer">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-info-circle"></i> Shows paid vs. outstanding by division
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Payment Methods</h5>
                    <p class="card-category">How teams are paying</p>
                </div>
                <div class="card-body">
                    <canvas id="paymentMethodChart" width="100%" height="100"></canvas>
                </div>
                <div class="card-footer">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-credit-card"></i> Full Team vs. Player Contributions
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Payment Details by Division --->
    <cfloop query="getDivisions">
        <cfset currentDivision = DivisionName>
        <cfset currentDivisionID = divisionID>
        
        <!--- Calculate division totals --->
        <cfset divTeamCount = 0>
        <cfset divTotalPaid = 0>
        <cfset divTotalFee = 0>
        <cfset divPaidInFull = 0>
        
        <cfloop array="#teamPaymentData#" index="team">
            <cfif structKeyExists(team, "teamID")>
                <cfquery name="teamDiv" dbtype="query">
                    SELECT divisionID FROM getTeams WHERE teamID = #team.teamID#
                </cfquery>
                <cfif teamDiv.recordCount GT 0 AND teamDiv.divisionID EQ currentDivisionID>
                    <cfset divTeamCount++>
                    <cfset divTotalPaid += team.totalPaid>
                    <cfset divTotalFee += team.teamFee>
                    <cfif team.isFullyPaid><cfset divPaidInFull++></cfif>
                </cfif>
            </cfif>
        </cfloop>
        <cfset divPercent = divTotalFee GT 0 ? (divTotalPaid / divTotalFee) * 100 : 0>
        
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <h5 class="card-title">
                                    <i class="nc-icon nc-basketball"></i> #currentDivision#
                                </h5>
                                <p class="card-category">#divTeamCount# teams &bull; #divPaidInFull# paid in full &bull; $#numberFormat(divTotalPaid, '999,999')# / $#numberFormat(divTotalFee, '999,999')# collected</p>
                            </div>
                            <div class="col-md-6">
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar <cfif divPercent GTE 100>bg-success<cfelseif divPercent GTE 50>bg-info<cfelseif divPercent GTE 25>bg-warning<cfelse>bg-danger</cfif>" 
                                        role="progressbar" 
                                        style="width: #numberFormat(divPercent, '999.9')#%" 
                                        aria-valuenow="#numberFormat(divPercent, '999.9')#" 
                                        aria-valuemin="0" 
                                        aria-valuemax="100">
                                        #numberFormat(divPercent, '999.9')#%
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead class="text-primary">
                                    <tr>
                                        <th>Team</th>
                                        <th>Captain</th>
                                        <th>Roster</th>
                                        <th>Team Fee</th>
                                        <th>Team Payments</th>
                                        <th>Player Contributions</th>
                                        <th>Total Paid</th>
                                        <th>Remaining</th>
                                        <th>Progress</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop query="getTeams">
                                        <cfif getTeams.divisionID EQ currentDivisionID>
                                            <!--- Find the matching team status --->
                                            <cfset teamStatus = {teamFee: seasonTeamFee, teamPayments: 0, playerContributions: 0, totalPaid: 0, remainingBalance: seasonTeamFee, percentPaid: 0}>
                                            <cfloop array="#teamPaymentData#" index="ts">
                                                <cfif ts.teamID EQ getTeams.teamID>
                                                    <cfset teamStatus = ts>
                                                    <cfbreak>
                                                </cfif>
                                            </cfloop>
                                            <tr>
                                                <td><strong>#teamName#</strong></td>
                                                <td><cfif len(captainID) AND captainID GT 0><a href="/pages/account/account_home.cfm?playerID=#captainID#">#firstName# #lastName#</a><cfelse><span class="text-muted">No captain</span></cfif></td>
                                                <td>#rosterCount#</td>
                                                <td>$#numberFormat(teamStatus.teamFee, '999,999')#</td>
                                                <td><cfif teamStatus.teamPayments GT 0><span class="text-success">$#numberFormat(teamStatus.teamPayments, '999,999')#</span><cfelse><span class="text-muted">$0</span></cfif></td>
                                                <td><cfif teamStatus.playerContributions GT 0><span class="text-success">$#numberFormat(teamStatus.playerContributions, '999,999')#</span><cfelse><span class="text-muted">$0</span></cfif></td>
                                                <td><strong>$#numberFormat(teamStatus.totalPaid, '999,999')#</strong></td>
                                                <td><cfif teamStatus.remainingBalance GT 0><span class="text-danger">$#numberFormat(teamStatus.remainingBalance, '999,999')#</span><cfelse><span class="text-success">$0</span></cfif></td>
                                                <td style="min-width: 120px;">
                                                    <div class="progress">
                                                        <div class="progress-bar <cfif teamStatus.percentPaid GTE 100>bg-success<cfelseif teamStatus.percentPaid GTE 50>bg-info<cfelseif teamStatus.percentPaid GTE 25>bg-warning<cfelse>bg-danger</cfif>" 
                                                            role="progressbar" 
                                                            style="width: <cfif teamStatus.percentPaid GT 0>#numberFormat(teamStatus.percentPaid, '999.9')#<cfelse>0</cfif>%" 
                                                            aria-valuenow="#numberFormat(teamStatus.percentPaid, '999.9')#" 
                                                            aria-valuemin="0" 
                                                            aria-valuemax="100">
                                                            <cfif teamStatus.percentPaid GT 0>#numberFormat(teamStatus.percentPaid, '999.9')#%</cfif>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <button class="btn btn-sm btn-primary" onclick="showTeamDetails(#teamID#)" title="View Details">
                                                        <i class="nc-icon nc-zoom-split"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfloop>

    <!--- Team Payment Details Modal --->
    <div class="modal fade" id="teamDetailsModal" tabindex="-1" role="dialog" aria-labelledby="teamDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="teamDetailsModalLabel">Team Payment Details</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="teamDetailsContent">
                    Loading...
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="sendReminderBtn">Send Payment Reminder</button>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

<!--- Include footer FIRST to load jQuery and other dependencies --->
<cfinclude template="/admin-dashboard/admin_footer.cfm">

<!--- JavaScript for charts and team details --->
<cfoutput>
<script>
// Set up division chart
var divCtx = document.getElementById('divisionChart').getContext('2d');
var divisionChart = new Chart(divCtx, {
    type: 'bar',    data: {        labels: [
            <cfset divNames = structKeyArray(divisionTotals)>
            <cfset arraySort(divNames, "textnocase")>
            <cfloop array="#divNames#" index="divName">
                '#divName#',
            </cfloop>
        ],
        datasets: [{
            label: 'Paid',
            data: [
                <cfloop array="#divNames#" index="divName">
                    #divisionTotals[divName].totalPaid#,
                </cfloop>
            ],
            backgroundColor: 'rgba(75, 192, 192, 0.6)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1
        },
        {
            label: 'Outstanding',
            data: [
                <cfloop array="#divNames#" index="divName">
                    #divisionTotals[divName].totalFee - divisionTotals[divName].totalPaid#,
                </cfloop>
            ],
            backgroundColor: 'rgba(255, 99, 132, 0.6)',
            borderColor: 'rgba(255, 99, 132, 1)',
            borderWidth: 1
        }]
    },
    options: {
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    callback: function(value) {
                        return '$' + value.toLocaleString();
                    }
                }
            },
            x: {
                stacked: true
            }
        },
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(context) {
                        let label = context.dataset.label || '';
                        if (label) {
                            label += ': ';
                        }
                        if (context.raw !== null) {
                            label += '$' + context.raw.toLocaleString();
                        }
                        return label;
                    }
                }
            }
        }
    }
});

// Set up payment method chart
var methodCtx = document.getElementById('paymentMethodChart').getContext('2d');
var paymentMethodChart = new Chart(methodCtx, {
    type: 'doughnut',
    data: {
        labels: ['Team Payments', 'Player Contributions'],
        datasets: [{
            data: [#getTotalPayments.total_team_payments#, #getTotalContributions.total_player_contributions#],
            backgroundColor: [
                'rgba(54, 162, 235, 0.6)',
                'rgba(255, 206, 86, 0.6)'
            ],
            borderColor: [
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(context) {
                        let label = context.label || '';
                        if (label) {
                            label += ': ';
                        }
                        if (context.raw !== null) {
                            label += '$' + context.raw.toLocaleString();
                        }
                        return label;
                    }
                }
            }
        }
    }
});

// Initialize on page load
$(document).ready(function() {
    // Auto-open modal if teamID is in URL (after adding manual payment)
    var urlParams = new URLSearchParams(window.location.search);
    var teamID = urlParams.get('teamID');
    if (teamID) {
        showTeamDetails(teamID);
    }
});

// Function to show team payment details in modal
function showTeamDetails(teamID) {
    $('##teamDetailsModal').modal('show');
    $('##teamDetailsContent').html('Loading team details...');
    
    // Load team details via AJAX
    $.ajax({
        url: 'team_details.cfm',
        type: 'GET',
        data: { teamID: teamID },
        success: function(response) {
            $('##teamDetailsContent').html(response);
        },
        error: function(xhr, status, error) {
            $('##teamDetailsContent').html('<div class="alert alert-danger">Error loading team details: ' + error + '<br>Status: ' + status + '</div>');
        }
    });
    
    // Update the send reminder button to have the correct team ID
    $('##sendReminderBtn').attr('onclick', 'sendPaymentReminder(' + teamID + ')');
}

// Function to send payment reminder
function sendPaymentReminder(teamID) {
    $('##sendReminderBtn').html('<i class="fa fa-spinner fa-spin"></i> Sending...');
    $('##sendReminderBtn').attr('disabled', true);
    
    // Send reminder via AJAX
    $.ajax({
        url: 'send_reminder.cfm',
        type: 'POST',
        data: { teamID: teamID },
        success: function(response) {
            alert('Payment reminder sent successfully.');
            $('##sendReminderBtn').html('Send Payment Reminder');
            $('##sendReminderBtn').attr('disabled', false);
        },
        error: function() {
            alert('Error sending payment reminder. Please try again.');
            $('##sendReminderBtn').html('Send Payment Reminder');
            $('##sendReminderBtn').attr('disabled', false);
        }
    });
}

// Function to update team fee for the season
function updateTeamFee() {
    var newFee = $('##teamFeeInput').val();
    if (!newFee || newFee < 0) {
        alert('Please enter a valid team fee amount.');
        return;
    }
    
    $('##updateFeeBtn').html('<i class="fa fa-spinner fa-spin"></i>');
    $('##updateFeeBtn').attr('disabled', true);
    
    $.ajax({
        url: 'update_team_fee.cfm',
        type: 'POST',
        data: { teamFee: newFee, seasonID: #session.currentSeasonID# },
        dataType: 'json',
        success: function(response) {
            if (response.SUCCESS || response.success) {
                window.location.href = 'teamFinances.cfm?feeUpdated=1';
            } else {
                window.location.href = 'teamFinances.cfm?error=' + encodeURIComponent(response.MESSAGE || response.message || 'Unknown error');
            }
        },
        error: function() {
            window.location.href = 'teamFinances.cfm?error=' + encodeURIComponent('Error updating team fee. Please try again.');
        }
    });
}
</script>
</cfoutput>
