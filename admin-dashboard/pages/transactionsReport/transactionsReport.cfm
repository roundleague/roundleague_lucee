<cfinclude template="/admin-dashboard/admin_header.cfm">
<link href="/admin-dashboard/pages/transactionsReport/transactionsReport.css?v=1.1" rel="stylesheet">

<cfoutput>

<cfquery name="qSummary" datasource="roundleague">
    SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN FromTeamID > 0 AND ToTeamID > 0 THEN 1 ELSE 0 END) AS transfers,
        SUM(CASE WHEN FromTeamID > 0 AND ToTeamID = 0 THEN 1 ELSE 0 END) AS drops,
        SUM(CASE WHEN FromTeamID = 0 AND ToTeamID > 0 THEN 1 ELSE 0 END) AS adds
    FROM transactions
    WHERE SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qTransactions" datasource="roundleague">
    SELECT
        t.TransactionsID,
        t.FromTeamID,
        t.ToTeamID,
        t.CaptainModifiedBy,
        t.DateModified,
        p.firstName  AS playerFirst,
        p.lastName   AS playerLast,
        ft.teamName  AS fromTeam,
        tt.teamName  AS toTeam,
        cp.firstName AS captainFirst,
        cp.lastName  AS captainLast
    FROM transactions t
    LEFT JOIN players p  ON p.playerID  = t.PlayerID
    LEFT JOIN teams ft   ON ft.teamID   = t.FromTeamID AND t.FromTeamID > 0
    LEFT JOIN teams tt   ON tt.teamID   = t.ToTeamID   AND t.ToTeamID   > 0
    LEFT JOIN players cp ON cp.playerID = t.CaptainModifiedBy AND t.CaptainModifiedBy > 0
    WHERE t.SeasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
    ORDER BY t.DateModified DESC, t.TransactionsID DESC
</cfquery>

<!-- End Navbar -->
<div class="content">

    <div class="row mb-2">
        <div class="col-md-12">
            <h4 class="card-title">Transactions Report</h4>
            <p class="text-muted">Season #session.currentSeasonID# &mdash; all player movement</p>
        </div>
    </div>

    <!--- KPI Cards --->
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-refresh-69 text-warning"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Total</p>
                                <p class="card-title">#qSummary.total#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-calendar"></i> Current season</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-delivery-fast text-primary"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Transfers</p>
                                <p class="card-title">#qSummary.transfers#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-arrow-right"></i> Team to team</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-simple-remove text-danger"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Drops</p>
                                <p class="card-title">#qSummary.drops#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-sign-out"></i> Removed from team</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-simple-add text-success"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Adds</p>
                                <p class="card-title">#qSummary.adds#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-sign-in"></i> Added to team</div>
                </div>
            </div>
        </div>
    </div>

    <!--- Transaction Log --->
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between flex-wrap">
                    <div>
                        <h5 class="card-title mb-0">Transaction Log</h5>
                        <p class="card-category">#qTransactions.recordCount# records</p>
                    </div>
                    <div class="btn-group">
                        <button class="btn btn-sm btn-primary filter-btn active" data-filter="all">All</button>
                        <button class="btn btn-sm btn-outline-secondary filter-btn" data-filter="transfer">Transfers</button>
                        <button class="btn btn-sm btn-outline-secondary filter-btn" data-filter="drop">Drops</button>
                        <button class="btn btn-sm btn-outline-secondary filter-btn" data-filter="add">Adds</button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-scroll">
                    <table class="table table-sm" id="txTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Player</th>
                                <th>Type</th>
                                <th>From</th>
                                <th>To</th>
                                <th class="tx-hide-mobile">By</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qTransactions">
                                <cfif FromTeamID GT 0 AND ToTeamID GT 0>
                                    <cfset txType = "transfer">
                                    <cfset txLabel = "Transfer">
                                <cfelseif FromTeamID GT 0 AND ToTeamID EQ 0>
                                    <cfset txType = "drop">
                                    <cfset txLabel = "Drop">
                                <cfelse>
                                    <cfset txType = "add">
                                    <cfset txLabel = "Add">
                                </cfif>
                                <tr data-type="#txType#">
                                    <td nowrap><small>#DateFormat(DateModified, "mmm d, yyyy")#</small></td>
                                    <td>
                                        <cfif len(trim(playerFirst)) GT 0>
                                            #playerFirst# #playerLast#
                                        <cfelse>
                                            <span class="text-muted">ID ###qTransactions.PlayerID#</span>
                                        </cfif>
                                    </td>
                                    <td><span class="tx-badge tx-#txType#">#txLabel#</span></td>
                                    <td>
                                        <cfif len(trim(fromTeam)) GT 0>
                                            #fromTeam#
                                        <cfelse>
                                            <span class="text-muted">&mdash;</span>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(trim(toTeam)) GT 0>
                                            #toTeam#
                                        <cfelse>
                                            <span class="text-muted">&mdash;</span>
                                        </cfif>
                                    </td>
                                    <td class="tx-hide-mobile">
                                        <small>
                                        <cfif CaptainModifiedBy GT 0 AND len(trim(captainFirst)) GT 0>
                                            #captainFirst# #captainLast#
                                        <cfelse>
                                            <span class="text-muted">Admin</span>
                                        </cfif>
                                        </small>
                                    </td>
                                </tr>
                            </cfloop>
                            <cfif qTransactions.recordCount EQ 0>
                                <tr><td colspan="6" class="text-center text-muted">No transactions this season</td></tr>
                            </cfif>
                        </tbody>
                    </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</cfoutput>

<script>
(function () {
    var btns = document.querySelectorAll('.filter-btn');
    var rows = document.querySelectorAll('#txTable tbody tr[data-type]');

    btns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var filter = this.getAttribute('data-filter');
            btns.forEach(function (b) {
                b.classList.remove('active', 'btn-primary');
                b.classList.add('btn-outline-secondary');
            });
            this.classList.add('active', 'btn-primary');
            this.classList.remove('btn-outline-secondary');
            rows.forEach(function (row) {
                row.style.display = (filter === 'all' || row.getAttribute('data-type') === filter) ? '' : 'none';
            });
        });
    });
}());
</script>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
