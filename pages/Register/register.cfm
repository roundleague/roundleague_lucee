<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://demos.creative-tim.com/paper-kit-2-pro/assets/css/paper-kit.min.css?v=2.3.1" rel="stylesheet">
<link href="../Register/register.css" rel="stylesheet">

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<div class="wrapper">
		    <div class="profile-content section">
		      <div class="container">
		        <div class="row">
		          <div class="col-md-6 ml-auto mr-auto">
		            <form class="settings-form">
		              <div class="form-group">
		                <label>Email</label>
		                <input type="text" class="form-control border-input" placeholder="Email" name="email">
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>First Name</label>
		                    <input type="text" class="form-control border-input" placeholder="First Name" name="firstName">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Last Name</label>
		                    <input type="text" class="form-control border-input" placeholder="Last Name" name="lastName">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group input-group date" id="datetimepicker">
		                  	<label>Birth Date</label>
		                    <input type="text" class="form-control datetimepicker" placeholder="27/03/2019" />
		                    <div class="input-group-append">
		                      <span class="input-group-text">
		                        <span class="glyphicon glyphicon-calendar"><i class="fa fa-calendar" aria-hidden="true"></i></span>
		                      </span>
		                    </div>
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Last Name</label>
		                    <input type="text" class="form-control border-input" placeholder="Last Name" name="lastName">
		                  </div>
		                </div>
		              </div>
		              <div class="row">
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>First Name</label>
		                    <input type="text" class="form-control border-input" placeholder="First Name" name="firstName">
		                  </div>
		                </div>
		                <div class="col-md-6 col-sm-6">
		                  <div class="form-group">
		                    <label>Last Name</label>
		                    <input type="text" class="form-control border-input" placeholder="Last Name" name="lastName">
		                  </div>
		                </div>
		              </div>
	                  <!--- <div class="form-group">
						  Are you over 18?
						 <input class="registerRadio firstRadio" type="radio" name="over18" value="1"> Yes
						 <input class="registerRadio secondRadio" type="radio" name="over18" value="0"> No
                	  </div> --->
		              <!--- <div class="form-group">
		                <label>Description</label>
		                <textarea class="form-control textarea-limited" placeholder="This is a textarea limited to 150 characters." rows="3" maxlength="150"></textarea>
		                <h5><small><span id="textarea-limited-message" class="pull-right">150 characters left</span></small></h5>
		              </div>
		              <label>Notifications</label>
		              <ul class="notifications">
		                <li class="notification-item">
		                  Updates regarding platform changes
		                  <input type="checkbox" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                  Updates regarding product changes
		                  <input type="checkbox" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		                <li class="notification-item">
		                  Weekly newsletter
		                  <input type="checkbox" data-toggle="switch" checked="" data-on-color="info" data-off-color="info"><span class="toggle"></span>
		                </li>
		              </ul> --->
		              <div class="text-center">
		                <button type="submit" class="btn btn-wd btn-info btn-round">Save</button>
		              </div>
		            </form>
		          </div>
		        </div>
		      </div>
		    </div>
		  </div>

		      </div>
		    </div>
		</div>
</cfoutput>

<cfinclude template="/footer.cfm">
<script src="../Register/register.js"></script>