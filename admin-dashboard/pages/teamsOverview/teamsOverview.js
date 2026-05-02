$(document).ready(function () {
  $("#teamsOverviewTable").DataTable();

  $(document).on("change", ".statusSelect", function () {
    console.log("Update Status");

    /* Get and set form variables for ajax call */
    var newStatus = $(this).val();
    var teamID = $(this).data("value");

    console.log("newStatus", newStatus);
    console.log("teamID", teamID);

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=updateTeamStatus",
      cache: false,
      data: {
        status: newStatus,
        teamID: teamID,
      },
      success: function (data) {
        console.log("updateTeamStatus response:", data);
      },
      error: function (xhr, status, err) {
        console.error("updateTeamStatus failed:", status, err);
        alert("Failed to update team status. Check the console for details.");
      },
    });
  });
});
