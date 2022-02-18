<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">

<!--- <cfquery name="getPlayerInfo" datasource="roundleague">
</cfquery> --->

<cfoutput>
<div class="main" style="background-color: white; padding-top: 50px">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <h3>IMPORTANT: Do not sign players without their permission.</h3>
        <br>
        <p>You are about to transfer <b>Richard Ung</b> from <b>Oregon ABC</b> to <b>Goodfellas</b>.</p>
        <br>
        <button type="submit" class="btn btn-outline-success btn-round removeBtn" name="confirmSignPlayer" value="#form.signPlayerID#">Sign</button>
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/pages/captain/signPlayer.js"></script>

