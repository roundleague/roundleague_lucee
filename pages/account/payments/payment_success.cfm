<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />

<cfparam name="url.playerID" default="0">
<cfparam name="url.session_id" default="">

<cfoutput>
<cfinclude template="../account_header.cfm">

<div class="profile-content section">
    <div class="container">
        <div class="row">
            <div class="col-md-10 ml-auto mr-auto">
                <div class="card">
                    <div class="card-header text-center">
                        <i class="fa fa-check-circle text-success" style="font-size: 4rem;"></i>
                        <h4 class="card-title mt-3">Payment Successful!</h4>
                    </div>
                    <div class="card-body text-center">
                        <p>Thank you for your payment. Your contribution has been recorded.</p>
                        <p class="text-muted" style="font-size: 0.85rem;">Session ID: #url.session_id#</p>
                        <hr>
                        <a href="/pages/account/payments/payment_status.cfm?playerID=#url.playerID#" class="btn btn-primary btn-round">
                            <i class="fa fa-credit-card-alt"></i> View Payment Status
                        </a>
                        <a href="/pages/account/account_home.cfm?playerID=#url.playerID#" class="btn btn-outline-default btn-round">
                            <i class="fa fa-home"></i> Account Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</cfoutput>

<cfinclude template="/footer.cfm">