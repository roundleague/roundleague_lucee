<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/moreTools/moreTools.css?v=1.1" rel="stylesheet">

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

                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>
                        <div class="tool-card empty"></div>
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
