<cfparam name="url.filter" default="anomalous">

<cfquery name="getEvents" datasource="roundleague">
    SELECT eventID, eventType, clientIP, subject, reason, anomalous,
           DATE_FORMAT(occurredAt, '%b %d, %Y %h:%i %p') AS occurredAtFormatted
    FROM security_events
    <cfif url.filter EQ "anomalous">
        WHERE anomalous = 1
    </cfif>
    ORDER BY occurredAt DESC
    LIMIT 500
</cfquery>

<cfquery name="totals" datasource="roundleague">
    SELECT
        SUM(CASE WHEN anomalous = 1 THEN 1 ELSE 0 END) AS anomalousCount,
        COUNT(*)                                        AS allCount
    FROM security_events
</cfquery>

<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/bugLogger/bugLogger.css?v=1.0" rel="stylesheet">

<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h4 class="card-title mb-0">
                        Security Events
                        <cfoutput>
                        <cfif url.filter EQ "anomalous">
                            <span class="badge badge-danger ml-2">#totals.anomalousCount# anomalous</span>
                        <cfelse>
                            <span class="badge badge-secondary ml-2">#totals.allCount# total</span>
                        </cfif>
                        </cfoutput>
                    </h4>
                    <div class="btn-group btn-group-sm" role="group">
                        <a href="?filter=anomalous" class="btn <cfoutput>#url.filter EQ 'anomalous' ? 'btn-primary' : 'btn-outline-primary'#</cfoutput>">
                            Anomalous only
                        </a>
                        <a href="?filter=all" class="btn <cfoutput>#url.filter EQ 'all' ? 'btn-primary' : 'btn-outline-primary'#</cfoutput>">
                            All blocked
                        </a>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="bug-list">
                        <cfif getEvents.recordCount EQ 0>
                            <div class="bug-empty">
                                <i class="fa fa-shield"></i>
                                <p>No events to show.</p>
                            </div>
                        <cfelse>
                            <cfoutput query="getEvents">
                            <div class="bug-row" style="cursor:default;">
                                <div class="bug-status">
                                    <cfif anomalous EQ 1><span class="bug-dot"></span></cfif>
                                </div>
                                <div class="bug-type">#htmlEditFormat(eventType)#</div>
                                <div class="bug-location">#htmlEditFormat(clientIP)#</div>
                                <div class="bug-meta" style="flex:1 1 auto; text-align:left; padding-left:16px;">
                                    <cfif len(subject)>
                                        <span style="color:##666;">#htmlEditFormat(left(subject, 80))#</span>
                                    <cfelseif len(reason)>
                                        <span style="color:##888;font-style:italic;">#htmlEditFormat(left(reason, 80))#</span>
                                    </cfif>
                                </div>
                                <div class="bug-meta">
                                    <span class="bug-date">#occurredAtFormatted#</span>
                                </div>
                            </div>
                            </cfoutput>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
