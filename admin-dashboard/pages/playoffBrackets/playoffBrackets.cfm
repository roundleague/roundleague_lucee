<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/admin-dashboard/assets/css/toast.css" rel="stylesheet">

<cfoutput>
<cfif isDefined("form.bracketName")>
	<cfinclude template="savePlayoffBrackets.cfm">
</cfif>	

<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Enter Playoff Bracket Details</h3>
      <form method="post">
        <div class="form-group">
          <label for="bracketName">Playoff Bracket Name:</label>
          <input type="text" class="form-control" id="bracketName" name="bracketName" required>
        </div>
        <div class="form-group">
          <label for="numTeams">Number of Teams:</label>
          <input type="number" class="form-control" id="numTeams" name="numTeams" min="1" required>
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
      </form>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
<script src="../../assets/js/toast.js?v=1.0"></script>
