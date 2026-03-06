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

function showSeasonStats() {
  document.getElementById("seasonStats").style.display = "";
  var career = document.getElementById("careerStats");
  if (career) career.style.display = "none";
  document.getElementById("btnSeason").classList.add("active");
  document.getElementById("btnCareer").classList.remove("active");
  document.getElementById("statsTitle").textContent = "Season Statistics";
}

function showCareerStats() {
  document.getElementById("seasonStats").style.display = "none";
  var career = document.getElementById("careerStats");
  if (career) career.style.display = "";
  document.getElementById("btnSeason").classList.remove("active");
  document.getElementById("btnCareer").classList.add("active");
  document.getElementById("statsTitle").textContent = "Career Averages";
}

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
