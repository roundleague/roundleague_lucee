$(document).ready(function () {
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
        // Optionally, update the UI to reflect the new team
      },
      error: function (error) {
        console.error("Error adding team:", error);
      },
    });
  });
});
