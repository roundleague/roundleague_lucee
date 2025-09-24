$(document).ready(function () {
  // Check if the element with ID "playerGameLogTable" exists
  if ($("#playerGameLogTable").length) {
    // If the element exists, perform the animation
    $("html, body").animate(
      {
        scrollTop: $("#playerGameLogTable").offset().top,
      },
      "slow"
    );
  }
});

function toggleSeasons() {
  var hiddenSeasons = document.querySelectorAll(".hidden-season");
  var btn = document.getElementById("showMoreSeasonsBtn");

  if (btn.innerText === "Show More Seasons") {
    hiddenSeasons.forEach(function (row) {
      row.style.display = "table-row";
    });
    btn.innerText = "Show Less Seasons";
  } else {
    hiddenSeasons.forEach(function (row) {
      row.style.display = "none";
    });
    btn.innerText = "Show More Seasons";
  }
}

// Initially hide seasons beyond the first 5
document.addEventListener("DOMContentLoaded", function () {
  var hiddenSeasons = document.querySelectorAll(".hidden-season");
  hiddenSeasons.forEach(function (row) {
    row.style.display = "none";
  });
});
