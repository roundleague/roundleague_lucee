<!--- Handle POST: save manual metrics --->
<cfif isDefined("form.save_metrics")>
    <cfquery datasource="roundleague">
        INSERT INTO audience_metrics (metricKey, metricValue)
        VALUES ('email_subscribers', <cfqueryparam value="#val(form.email_subscribers)#" cfsqltype="cf_sql_bigint">)
        ON DUPLICATE KEY UPDATE metricValue = VALUES(metricValue), updatedAt = NOW()
    </cfquery>
    <cfquery datasource="roundleague">
        INSERT INTO audience_metrics (metricKey, metricValue)
        VALUES ('instagram_followers', <cfqueryparam value="#val(form.instagram_followers)#" cfsqltype="cf_sql_bigint">)
        ON DUPLICATE KEY UPDATE metricValue = VALUES(metricValue), updatedAt = NOW()
    </cfquery>
    <cfquery datasource="roundleague">
        INSERT INTO audience_metrics (metricKey, metricValue)
        VALUES ('stream_views', <cfqueryparam value="#val(form.stream_views)#" cfsqltype="cf_sql_bigint">)
        ON DUPLICATE KEY UPDATE metricValue = VALUES(metricValue), updatedAt = NOW()
    </cfquery>
    <cfquery datasource="roundleague">
        INSERT INTO audience_metrics (metricKey, metricValue)
        VALUES ('website_visits', <cfqueryparam value="#val(form.website_visits)#" cfsqltype="cf_sql_bigint">)
        ON DUPLICATE KEY UPDATE metricValue = VALUES(metricValue), updatedAt = NOW()
    </cfquery>
    <cflocation url="sponsorshipReach.cfm?saved=1" addtoken="false">
</cfif>

<cfinclude template="/admin-dashboard/admin_header.cfm">

<cfoutput>

<cfquery name="qLive" datasource="roundleague">
    SELECT
        (SELECT COUNT(DISTINCT r.playerID)
         FROM roster r
         WHERE r.seasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">) AS active_players,
        (SELECT COUNT(*)
         FROM teams t
         WHERE t.seasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">) AS active_teams,
        (SELECT COUNT(*)
         FROM schedule sc
         WHERE sc.seasonID = <cfqueryparam value="#session.currentSeasonID#" cfsqltype="cf_sql_integer">
           AND sc.status = 'final') AS games_played,
        (SELECT COUNT(*) FROM users WHERE status = 'active') AS app_users
</cfquery>

<cfquery name="qManual" datasource="roundleague">
    SELECT metricKey, metricValue, updatedAt
    FROM audience_metrics
</cfquery>

<cfset mVals = StructNew()>
<cfset mVals["email_subscribers"] = 0>
<cfset mVals["instagram_followers"] = 0>
<cfset mVals["stream_views"] = 0>
<cfset mVals["website_visits"] = 0>
<cfset mDates = StructNew()>
<cfset mDates["email_subscribers"] = "Never">
<cfset mDates["instagram_followers"] = "Never">
<cfset mDates["stream_views"] = "Never">
<cfset mDates["website_visits"] = "Never">
<cfloop query="qManual">
    <cfset mVals[metricKey] = metricValue>
    <cfif isDate(updatedAt)>
        <cfset mDates[metricKey] = DateFormat(updatedAt, "mmm d, yyyy")>
    </cfif>
</cfloop>

<cfset emailVal     = mVals["email_subscribers"]>
<cfset igVal        = mVals["instagram_followers"]>
<cfset streamVal    = mVals["stream_views"]>
<cfset webVal       = mVals["website_visits"]>
<cfset emailDate    = mDates["email_subscribers"]>
<cfset igDate       = mDates["instagram_followers"]>
<cfset streamDate   = mDates["stream_views"]>
<cfset webDate      = mDates["website_visits"]>

<!-- End Navbar -->
<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>

    <div class="row mb-3">
        <div class="col-md-12">
            <h4 class="card-title mb-0">Round League Reach</h4>
            <p class="card-category">Audience snapshot for sponsorship conversations</p>
        </div>
    </div>

    <cfif isDefined("url.saved") AND url.saved EQ 1>
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <strong>Saved!</strong> Metrics updated successfully.
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </div>
    </div>
    </cfif>

    <!--- Section: Live Metrics --->
    <div class="row mb-1">
        <div class="col-md-12">
            <p class="text-muted text-uppercase" style="font-size:11px;font-weight:600;letter-spacing:1px;">
                <i class="fa fa-circle text-success" style="font-size:8px;vertical-align:middle;"></i>&nbsp; Live from Database
            </p>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-single-02 text-warning"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Active Players</p>
                                <p class="card-title">#NumberFormat(qLive.active_players)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-refresh"></i> Current season</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-badge text-success"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Teams</p>
                                <p class="card-title">#NumberFormat(qLive.active_teams)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-refresh"></i> Current season</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-check-2 text-info"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Games Played</p>
                                <p class="card-title">#NumberFormat(qLive.games_played)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-refresh"></i> Current season</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-chart-bar-32 text-danger"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">App Users</p>
                                <p class="card-title">#NumberFormat(qLive.app_users)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-refresh"></i> All time</div>
                </div>
            </div>
        </div>
    </div>

    <!--- Section: Manual Metrics --->
    <div class="row mb-1 mt-2">
        <div class="col-md-12">
            <p class="text-muted text-uppercase" style="font-size:11px;font-weight:600;letter-spacing:1px;">
                <i class="fa fa-pencil" style="font-size:10px;vertical-align:middle;"></i>&nbsp; Manually Updated
            </p>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-email-85 text-warning"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Email Subscribers</p>
                                <p class="card-title">#NumberFormat(emailVal)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-pencil"></i> #emailDate#</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-image text-danger"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Instagram Followers</p>
                                <p class="card-title">#NumberFormat(igVal)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-pencil"></i> #igDate#</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-tv-2 text-info"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Stream Views</p>
                                <p class="card-title">#NumberFormat(streamVal)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-pencil"></i> #streamDate#</div>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card card-stats">
                <div class="card-body">
                    <div class="row">
                        <div class="col-5 col-md-4">
                            <div class="icon-big text-center icon-warning">
                                <i class="nc-icon nc-globe-2 text-success"></i>
                            </div>
                        </div>
                        <div class="col-7 col-md-8">
                            <div class="numbers">
                                <p class="card-category">Website Visits</p>
                                <p class="card-title">#NumberFormat(webVal)#</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer"><hr>
                    <div class="stats"><i class="fa fa-pencil"></i> #webDate#</div>
                </div>
            </div>
        </div>
    </div>

    <!--- Update Manual Metrics Form --->
    <div class="row mt-2">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title">Update Metrics</h5>
                    <p class="card-category">Edit off-platform numbers and save</p>
                </div>
                <div class="card-body">
                    <form method="post" action="sponsorshipReach.cfm">
                        <input type="hidden" name="save_metrics" value="1">
                        <div class="row">
                            <div class="col-md-3 col-sm-6">
                                <div class="form-group">
                                    <label>Email Subscribers</label>
                                    <input type="number" class="form-control" name="email_subscribers" value="#emailVal#" min="0">
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="form-group">
                                    <label>Instagram Followers</label>
                                    <input type="number" class="form-control" name="instagram_followers" value="#igVal#" min="0">
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="form-group">
                                    <label>Stream Views</label>
                                    <input type="number" class="form-control" name="stream_views" value="#streamVal#" min="0">
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="form-group">
                                    <label>Website Visits</label>
                                    <input type="number" class="form-control" name="website_visits" value="#webVal#" min="0">
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Save Metrics</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
