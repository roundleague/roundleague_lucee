$(document).ready(function () {
  if (localStorage.getItem("teamAdded") === "true") {
    toastr.success("Team added successfully!");
    localStorage.removeItem("teamAdded"); // Clear the flag
  }

  // Initialize the tabs
  $("#teamsTab a").on("click", function (e) {
    e.preventDefault();
    $(this).tab("show");
  });

  // DataTables
  $("#teamsOverviewTable").DataTable();
  $("#pendingTeamsOverviewTable").DataTable();

  // Populate the form fields with the selected team details when the button is clicked
  $(".clickOnTeam").click(function () {
    var teamName = $(this).data("team-name");
    var division = $(this).data("division");
    var level = $(this).data("level");
    var dayPreference = $(this).data("day-preference");
    var primaryTime = $(this).data("primary-time");
    var secondaryTime = $(this).data("secondary-time");

    $("#teamName").val(teamName);
    $("#division").val(division);
    $("#level").val(level);
    $("#dayPreference").val(dayPreference);
    $("#primaryTime").val(primaryTime);
    $("#secondaryTime").val(secondaryTime);
  });

  // Handle the form submission to add the team
  $(".confirmTeamApproval").click(function () {
    var teamData = {
      teamName: $("#teamName").val(),
      division: $("#division").val(),
      level: $("#level").val(),
      dayPreference: $("#dayPreference").val(),
      primaryTime: $("#primaryTime").val(),
      secondaryTime: $("#secondaryTime").val(),
    };

    $.ajax({
      url: "/library/teams.cfc?method=addTeam", // The endpoint to handle the request
      type: "POST",
      data: teamData,
      success: function (response) {
        console.log("Team added successfully:", response);
        localStorage.setItem("teamAdded", "true"); // Set the flag
        location.reload(); // Refresh the page to load teams in the right spot
      },
      error: function (error) {
        console.error("Error adding team:", error);
      },
    });
  });
});
