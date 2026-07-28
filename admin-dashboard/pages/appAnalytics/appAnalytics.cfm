<cfinclude template="/admin-dashboard/admin_header.cfm">
<link href="/admin-dashboard/pages/appAnalytics/appAnalytics.css?v=1.0" rel="stylesheet">

<cfparam name="url.days" default="7">
<cfset daysVal = val(url.days)>

<cfif daysVal EQ 1>
    <cfset cutoff = CreateDate(Year(Now()), Month(Now()), Day(Now()))>
    <cfset rangeLabel = "Today">
<cfelseif daysVal GT 1>
    <cfset cutoff = DateAdd("d", -daysVal, Now())>
    <cfset rangeLabel = "Last #daysVal# days">
<cfelse>
    <cfset rangeLabel = "All time">
</cfif>

<cfoutput>

<cfquery name="qSummary" datasource="roundleague">
    SELECT COUNT(*) AS total_events, COUNT(DISTINCT player_id) AS unique_users
    FROM app_events
    <cfif daysVal GT 0>
        WHERE created_at >= <cfqueryparam value="#cutoff#" cfsqltype="cf_sql_timestamp">
    </cfif>
</cfquery>

<cfquery name="qPayments" datasource="roundleague">
    SELECT
        SUM(CASE WHEN event = 'payment_started'   THEN 1 ELSE 0 END) AS started,
        SUM(CASE WHEN event = 'payment_completed' THEN 1 ELSE 0 END) AS completed
    FROM app_events
</cfquery>
<cfset conversionRate = 0>
<cfif val(qPayments.started) GT 0>
    <cfset conversionRate = Round((val(qPayments.completed) / val(qPayments.started)) * 100)>
</cfif>

<cfquery name="qEventBreakdown" datasource="roundleague">
    SELECT event, COUNT(*) AS cnt
    FROM app_events
    <cfif daysVal GT 0>
        WHERE created_at >= <cfqueryparam value="#cutoff#" cfsqltype="cf_sql_timestamp">
    </cfif>
    GROUP BY event
    ORDER BY cnt DESC
</cfquery>
<cfset maxEventCount = 1>
<cfloop query="qEventBreakdown">
    <cfif cnt GT maxEventCount><cfset maxEventCount = cnt></cfif>
</cfloop>

<cfquery name="qWeeklyActivity" datasource="roundleague">
    SELECT
        YEARWEEK(created_at, 1) AS week_key,
        DATE(DATE_SUB(created_at, INTERVAL WEEKDAY(created_at) DAY)) AS week_start,
        COUNT(DISTINCT player_id) AS unique_users,
        COUNT(*) AS total_events
    FROM app_events
    WHERE created_at >= <cfqueryparam value="#DateAdd('d', -70, Now())#" cfsqltype="cf_sql_timestamp">
    GROUP BY YEARWEEK(created_at, 1), DATE(DATE_SUB(created_at, INTERVAL WEEKDAY(created_at) DAY))
    ORDER BY week_key DESC
</cfquery>

<cfquery name="qTopUsers" datasource="roundleague">
    SELECT ae.player_id,
           MAX(p.firstName) AS firstName,
           MAX(p.lastName)  AS lastName,
           COUNT(*)         AS event_count,
           MAX(ae.created_at) AS last_seen
    FROM app_events ae
    LEFT JOIN players p ON p.playerID = ae.player_id
    <cfif daysVal GT 0>
        WHERE ae.created_at >= <cfqueryparam value="#cutoff#" cfsqltype="cf_sql_timestamp">
    </cfif>
    GROUP BY ae.player_id
    ORDER BY event_count DESC
    LIMIT 10
</cfquery>

<cfquery name="qRecentEvents" datasource="roundleague">
    SELECT ae.id, ae.player_id, ae.event, ae.metadata, ae.created_at,
           p.firstName, p.lastName
    FROM app_events ae
    LEFT JOIN players p ON p.playerID = ae.player_id
    ORDER BY ae.created_at DESC
    LIMIT 50
</cfquery>

<!-- End Navbar -->
<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>

    <!--- Header + Date Range --->
    <div class="row mb-2">
        <div class="col-md-12 d-flex align-items-center justify-content-between flex-wrap">
            <h4 class="card-title mb-2">App Analytics</h4>
            <div class="btn-group mb-2">
                <a href="?days=1"  class="btn btn-sm <cfif daysVal EQ 1>btn-primary<cfelse>btn-outline-secondary</cfif>">Today</a>
                <a href="?days=7"  class="btn btn-sm <cfif daysVal EQ 7>btn-primary<cfelse>btn-outline-secondary</cfif>">7 Days</a>
                <a href="?days=30" class="btn btn-sm <cfif daysVal EQ 30>btn-primary<cfelse>btn-outline-secondary</cfif>">30 Days</a>
                <a href="?days=0"  class="btn btn-sm <cfif daysVal EQ 0>btn-primary<cfelse>btn-outline-secondary</cfif>">All Time</a>
            </div>
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
                                <i class="nc-icon nc-chart-bar-32 text-warning"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Total Events</p>
                                <p class="card-title">#NumberFormat(qSummary.total_events)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-calendar"></i> #rangeLabel#</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-single-02 text-success"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Unique Users</p>
                                <p class="card-title">#NumberFormat(qSummary.unique_users)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-calendar"></i> #rangeLabel#</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-money-coins text-danger"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Payments Completed</p>
                                <p class="card-title">#NumberFormat(qPayments.completed)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-refresh"></i> All time</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-check-2 text-primary"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Payment Conversion</p>
                                <p class="card-title">#conversionRate#%</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-arrow-right"></i> #qPayments.started# started &rarr; #qPayments.completed# completed</div>
                </div>
            </div>
        </div>
    </div>

    <!--- Event Breakdown + Top Users --->
    <div class="row">
        <div class="col-md-7">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Event Breakdown</h5>
                    <p class="card-category">#rangeLabel#</p>
                </div>
                <div class="card-body">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Event</th>
                                <th class="text-right">Count</th>
                                <th>Share</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qEventBreakdown">
                                <cfset barWidth = Round((cnt / maxEventCount) * 80)>
                                <cfset sharePct = qSummary.total_events GT 0 ? Round((cnt / qSummary.total_events) * 100) : 0>
                                <tr>
                                    <td><span class="event-badge">#event#</span></td>
                                    <td class="text-right">#NumberFormat(cnt)#</td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="mini-bar mr-1" style="width:#barWidth#px"></div>
                                            <small class="text-muted">#sharePct#%</small>
                                        </div>
                                    </td>
                                </tr>
                            </cfloop>
                            <cfif qEventBreakdown.recordCount EQ 0>
                                <tr><td colspan="3" class="text-center text-muted">No events in this range</td></tr>
                            </cfif>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-5">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Top Users</h5>
                    <p class="card-category">#rangeLabel#</p>
                </div>
                <div class="card-body">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Player</th>
                                <th class="text-right">Events</th>
                                <th>Last Seen</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qTopUsers">
                                <tr>
                                    <td>
                                        <cfif len(trim(firstName)) GT 0>
                                            #firstName# #lastName#
                                        <cfelse>
                                            <span class="text-muted">Player ###player_id#</span>
                                        </cfif>
                                    </td>
                                    <td class="text-right">#event_count#</td>
                                    <td nowrap><small class="text-muted">#DateFormat(last_seen, "mmm d")# #TimeFormat(last_seen, "h:mm tt")#</small></td>
                                </tr>
                            </cfloop>
                            <cfif qTopUsers.recordCount EQ 0>
                                <tr><td colspan="3" class="text-center text-muted">No activity</td></tr>
                            </cfif>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Weekly Activity --->
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Weekly Activity</h5>
                    <p class="card-category">Last 10 weeks</p>
                </div>
                <div class="card-body">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Week</th>
                                <th class="text-right">Unique Users</th>
                                <th class="text-right">Total Events</th>
                                <th class="text-right">Avg Events / User</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qWeeklyActivity">
                                <cfset weekEnd = DateAdd("d", 6, week_start)>
                                <cfset avgPerUser = unique_users GT 0 ? NumberFormat(total_events / unique_users, "0.0") : "—">
                                <tr>
                                    <td nowrap>#DateFormat(week_start, "mmm d")# &ndash; #DateFormat(weekEnd, "mmm d")#</td>
                                    <td class="text-right">#unique_users#</td>
                                    <td class="text-right">#total_events#</td>
                                    <td class="text-right">#avgPerUser#</td>
                                </tr>
                            </cfloop>
                            <cfif qWeeklyActivity.recordCount EQ 0>
                                <tr><td colspan="4" class="text-center text-muted">No activity in the last 10 weeks</td></tr>
                            </cfif>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Recent Events Feed --->
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Recent Events</h5>
                    <p class="card-category">Last 50 events across all users</p>
                </div>
                <div class="card-body">
                    <table class="table table-sm" id="recentEventsTable">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Player</th>
                                <th>Event</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qRecentEvents">
                                <tr>
                                    <td nowrap>
                                        <small class="text-muted">
                                            #DateFormat(created_at, "mm/dd")#
                                            #TimeFormat(created_at, "h:mm tt")#
                                        </small>
                                    </td>
                                    <td>
                                        <cfif len(trim(firstName)) GT 0>
                                            #firstName# #lastName#
                                        <cfelse>
                                            <span class="text-muted">###player_id#</span>
                                        </cfif>
                                    </td>
                                    <td><span class="event-badge">#event#</span></td>
                                    <td>
                                        <small class="text-muted metadata-cell">
                                            <cfif len(trim(metadata)) GT 0>#HtmlEditFormat(metadata)#</cfif>
                                        </small>
                                    </td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    <div class="d-flex align-items-center justify-content-between mt-2">
                        <button id="prevBtn" class="btn btn-sm btn-outline-secondary" disabled>&larr; Prev</button>
                        <small id="pageInfo" class="text-muted"></small>
                        <button id="nextBtn" class="btn btn-sm btn-outline-secondary">Next &rarr;</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</cfoutput>

<script src="/admin-dashboard/pages/appAnalytics/appAnalytics.js?v=1.0"></script>
<cfinclude template="/admin-dashboard/admin_footer.cfm">
