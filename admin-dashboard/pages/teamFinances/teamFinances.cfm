<cfinclude template="/admin-dashboard/admin_header.cfm">
<!--- Page Specific CSS/JS Here --->
<link href="teamFinances.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!--- Include the team payment status function --->
<cfinclude template="/pages/account/payments/get_team_payment_status.cfm">

<cfoutput>

<!--- Get list of all active teams with their division and captain info --->
<cfquery name="getTeams" datasource="roundleague">
    SELECT 
        t.teamID, 
        t.teamName, 
        d.DivisionName,
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
        t.STATUS = 'Active'
    AND 
        t.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    ORDER BY 
        d.DivisionName, t.teamName
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
<cfset totalTeamFees = getTeams.recordCount * 1000>
<cfset totalCollected = getTotalPayments.total_team_payments + getTotalContributions.total_player_contributions>
<cfset totalRemaining = totalTeamFees - totalCollected>
<cfset overallPercentage = totalTeamFees GT 0 ? (totalCollected / totalTeamFees) * 100 : 0>

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
    <div class="row">
        <div class="col-md-12">
            <h3 class="description">Team Finances - Season <span class="badge badge-primary">#session.currentSeasonID#</span></h3>
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
                </div>
                <div class="card-footer ">
                    <hr>
                    <div class="stats">
                        <i class="fa fa-users"></i> #getTeams.recordCount# Teams × $1,000
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

    <!--- Payment Details Table --->
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Team Payment Details</h5>
                    <p class="card-category">Detailed breakdown by team</p>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table id="financeTable" class="table table-striped">
                            <thead class="text-primary">
                                <tr>
                                    <th>Team</th>
                                    <th>Division</th>
                                    <th>Captain</th>
                                    <th>Roster Size</th>
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
                                <cfset rowIndex = 0>
                                <cfloop query="getTeams">
                                    <cfset rowIndex++>
                                    <cfset teamStatus = teamPaymentData[rowIndex]>
                                    <tr>
                                        <td>#teamName#</td>
                                        <td>#DivisionName#</td>
                                        <td><a href="/pages/account/account_home.cfm?playerID=#captainID#">#firstName# #lastName#</a></td>
                                        <td>#rosterCount#</td>
                                        <td>$#numberFormat(teamStatus.teamFee, '999,999')#</td>
                                        <td>$#numberFormat(teamStatus.teamPayments, '999,999')#</td>
                                        <td>$#numberFormat(teamStatus.playerContributions, '999,999')#</td>
                                        <td>$#numberFormat(teamStatus.totalPaid, '999,999')#</td>
                                        <td>$#numberFormat(teamStatus.remainingBalance, '999,999')#</td>
                                        <td>
                                            <div class="progress">
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
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-primary" onclick="showTeamDetails(#teamID#)">
                                                <i class="nc-icon nc-zoom-split"></i> Details
                                            </button>
                                            <a href="/pages/account/payments/payment_status.cfm?playerID=#captainID#" class="btn btn-sm btn-info" target="_blank">
                                                <i class="nc-icon nc-money-coins"></i> Payment
                                            </a>
                                        </td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

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

<!--- JavaScript for charts and team details --->
<script>
// Set up division chart
var divCtx = document.getElementById('divisionChart').getContext('2d');
var divisionChart = new Chart(divCtx, {
    type: 'bar',
    data: {
        labels: [
            <cfset divNames = structKeySort(divisionTotals)>
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

// Initialize DataTable
$(document).ready(function() {
    $('##financeTable').DataTable({
        responsive: true,
        order: [[9, 'asc']] // Sort by payment progress column initially
    });
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
        error: function() {
            $('##teamDetailsContent').html('Error loading team details. Please try again.');
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
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
