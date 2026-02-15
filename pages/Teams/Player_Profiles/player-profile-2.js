$(document).ready(function () {
  // Check if the element with ID "playerGameLogTable" exists
  if ($("#playerGameLogTable").length) {
    // If the element exists, perform the animation
    $("html, body").animate(
      {
        scrollTop: $("#playerGameLogTable").offset().top,
      },
      "slow",
    );
  }
});

function toggleSeasons() {
  var hiddenSeasons = document.querySelectorAll(".hidden-season");
  var btn = document.getElementById("showMoreSeasonsBtn");
  if (btn.innerText.trim() === "SHOW MORE SEASONS") {
    hiddenSeasons.forEach(function (row) {
      row.classList.add("shown");
    });
    btn.innerText = "SHOW LESS SEASONS";
  } else {
    hiddenSeasons.forEach(function (row) {
      row.classList.remove("shown");
    });
    btn.innerText = "SHOW MORE SEASONS";
  }
}
