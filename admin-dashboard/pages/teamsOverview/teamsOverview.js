$( document ).ready(function() {
	$('#teamsOverviewTable').DataTable();

	$('.statusSelect').change(function(){
		console.log("Update Status");

		/* Get and set form variables for ajax call */
		var newStatus = $(this).val();
		var teamID = $(this).data('value');

		console.log("newStatus", newStatus);
		console.log("teamID", teamID);

		var jsonOBJ = {};

		$.ajaxSetup({
			data: {
				status: newStatus,
				teamID: teamID
			}
		});

		$.ajax({
		  type: "POST",
		  url: "/library/teams.cfc?method=updateTeamStatus",
		  cache: false,
		  success: function(data){
		  	 console.log(data);
		     // for (var key in jsonOBJ) {
		     //   $("input[name=" + key + "]").val(jsonOBJ[key]);
		     // }
		  },
		});
	});
});