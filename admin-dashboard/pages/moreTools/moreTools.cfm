<cftry>
    <cfquery name="msgUnread" datasource="roundleague">
        SELECT COUNT(*) AS cnt FROM contact_messages WHERE isRead = 0
    </cfquery>
    <cfcatch type="any">
        <cfset msgUnread = { cnt: 0 }>
    </cfcatch>
</cftry>

<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/moreTools/moreTools.css?v=1.1" rel="stylesheet">
<link href="/admin-dashboard/pages/messages/messages.css?v=1.0" rel="stylesheet">

<!-- End Navbar -->
<div class="content">
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h4 class="card-title">More Tools</h4>
                </div>
                <div class="card-body">
                    <div class="tools-grid">

                        <a href="/admin-dashboard/pages/playerOfTheGame/playerOfTheGame.cfm" class="tool-card">
                            <i class="nc-icon nc-image"></i>
                            <p>Player of the Game</p>
                        </a>

                        <a href="/admin-dashboard/pages/appAnalytics/appAnalytics.cfm" class="tool-card">
                            <i class="nc-icon nc-chart-bar-32"></i>
                            <p>App Analytics</p>
                        </a>

                        <a href="/admin-dashboard/pages/transactionsReport/transactionsReport.cfm" class="tool-card">
                            <i class="nc-icon nc-refresh-69"></i>
                            <p>Transactions Report</p>
                        </a>

                        <a href="/pages/scoreboard/scoreboard.cfm" target="_blank" class="tool-card">
                            <i class="nc-icon nc-tv-2"></i>
                            <p>Live Scoreboard</p>
                        </a>

                        <a href="/admin-dashboard/pages/teamPhotos/teamPhotos.cfm" class="tool-card">
                            <i class="nc-icon nc-album-2"></i>
                            <p>Team Photo Upload</p>
                        </a>

                        <a href="/admin-dashboard/pages/sponsorshipReach/sponsorshipReach.cfm" class="tool-card">
                            <i class="nc-icon nc-chart-pie-36"></i>
                            <p>Round League Reach</p>
                        </a>

                        <a href="/admin-dashboard/pages/statCorrections/statCorrections.cfm" class="tool-card">
                            <i class="nc-icon nc-chat-33"></i>
                            <p>Stat Corrections</p>
                        </a>

                        <a href="/admin-dashboard/pages/leagueRules/leagueRules.cfm" class="tool-card">
                            <i class="nc-icon nc-single-copy-04"></i>
                            <p>League Rules</p>
                        </a>

                        <cfoutput>
                        <a href="/admin-dashboard/pages/messages/messages.cfm" class="tool-card">
                            <span style="position:relative; display:inline-block;">
                                <i class="nc-icon nc-email-85"></i>
                                <cfif msgUnread.cnt GT 0>
                                    <span class="tool-badge">#msgUnread.cnt#</span>
                                </cfif>
                            </span>
                            <p>Messages</p>
                        </a>
                        </cfoutput>

                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
