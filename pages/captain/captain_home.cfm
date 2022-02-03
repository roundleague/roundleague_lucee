<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/captain/captain_home.css" rel="stylesheet" />

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		  <div class="section profile-content">
		    <div class="container profileHome">
		        <div class="owner">
		          <div class="avatar">
		            <img src="../../assets/img/PlayerProfiles/68.JPG" alt="Circle Image" class="img-circle img-no-padding img-responsive">
		          </div>
		          <div class="name">
		            <h4 class="title">Tim Huynh
		              <br />
		            </h4>
		            <h6 class="description">Point Guard</h6>
		          </div>
		        </div>
		        <div class="row bottomProfile">
		          <div class="col-md-6 ml-auto mr-auto text-center">
		            <p>Oregon ABC</p>
		            <br />
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-cog"></i> Account Settings</btn>
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-credit-card-alt"></i> Payments</btn>
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-list"></i> Edit Team</btn>
		            <btn class="btn btn-outline-default btn-round"><i class="fa fa-pencil-square-o"></i> Sign Free Agent</btn>
		          </div>
		        </div>
		        <br/>
		      <div class="nav-tabs-navigation">
		        <div class="nav-tabs-wrapper">
		          <ul class="nav nav-tabs" role="tablist">
		            <li class="nav-item">
		              <a class="nav-link active" data-toggle="tab" href="##follows" role="tab">Upcoming Schedule</a>
		            </li>
		            <li class="nav-item">
		              <a class="nav-link" data-toggle="tab" href="##following" role="tab">Previous</a>
		            </li>
		          </ul>
		        </div>
		      </div>
		      <!-- Tab panes -->
		      <div class="tab-content following">
		        <div class="tab-pane active" id="follows" role="tabpanel">
		          <div class="row">
		            <div class="col-md-6 ml-auto mr-auto">
		              <ul class="list-unstyled follows">
		                <li>
		                  <div class="row">
		                    <div class="col-lg-2 col-md-4 col-4 ml-auto mr-auto">
		                      <img src="../../assets/img/PlayerProfiles/79.JPG" alt="Circle Image" class="img-circle img-no-padding img-responsive">
		                    </div>
		                    <div class="col-lg-7 col-md-4 col-4  ml-auto mr-auto">
		                      <h6>Goodfellas
		                        <br/>
		                        <small>Feb 5, 2022 | 12:00 PM</small>
		                      </h6>
		                    </div>
		                    <div class="col-lg-3 col-md-4 col-4  ml-auto mr-auto">
		                      <!--- <div class="form-check">
		                        <label class="form-check-label">
		                          <input class="form-check-input" type="checkbox" value="" checked>
		                          <span class="form-check-sign"></span>
		                        </label>
		                      </div> --->
		                    </div>
		                  </div>
		                </li>
		                <hr />
		                <li>
		                  <div class="row">
		                    <div class="col-lg-2 col-md-4 col-4 mx-auto ">
		                      <img src="../../assets/img/PlayerProfiles/21.JPG" alt="Circle Image" class="img-circle img-no-padding img-responsive">
		                    </div>
		                    <div class="col-lg-7 col-md-4 col-4">
		                      <h6>Mobb Deep
		                        <br />
		                        <small>Feb 12, 2022 | 2:00 PM</small>
		                      </h6>
		                    </div>
		                    <div class="col-lg-3 col-md-4 col-4">
		                      <!--- <div class="form-check">
		                        <label class="form-check-label">
		                          <input class="form-check-input" type="checkbox" value="">
		                          <span class="form-check-sign"></span>
		                        </label>
		                      </div> --->
		                    </div>
		                  </div>
		                </li>
		              </ul>
		            </div>
		          </div>
		        </div>
		        <div class="tab-pane text-center" id="following" role="tabpanel">
		          <h3 class="text-muted">Not following anyone yet :(</h3>
		          <button class="btn btn-warning btn-round">Find artists</button>
		        </div>
		      </div>
		    </div>
		  </div>


      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

