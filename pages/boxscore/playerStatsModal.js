function openPlayerStatsModal(
  firstName,
  lastName,
  jersey,
  teamName,
  fgm,
  fga,
  fgm3,
  fga3,
  ftm,
  fta,
  pts,
  reb,
  ast,
  stl,
  blk,
  to,
  fls,
  playerID,
) {
  document.getElementById("modalFirstName").textContent =
    firstName.toUpperCase() + " " + jersey;
  document.getElementById("modalLastName").textContent = lastName.toUpperCase();
  document.getElementById("modalTeamName").textContent = teamName.toUpperCase();
  document.getElementById("modalPTS").textContent = pts;
  document.getElementById("modalREB").textContent = reb;
  document.getElementById("modalAST").textContent = ast;
  document.getElementById("modalFG").textContent = fgm + "-" + fga;
  document.getElementById("modal3PT").textContent = fgm3 + "-" + fga3;
  document.getElementById("modalFT").textContent = ftm + "-" + fta;
  document.getElementById("modalSTL").textContent = stl;
  document.getElementById("modalBLK").textContent = blk;
  document.getElementById("modalTO").textContent = to;
  document.getElementById("modalFLS").textContent = fls;

  // Set player photo with fallback
  var photoImg = document.getElementById("modalPlayerPhoto");
  photoImg.onerror = function () {
    this.src = "/assets/img/PlayerProfiles/default.JPG";
  };
  photoImg.src = "/assets/img/PlayerProfiles/" + playerID + ".JPG";

  // Hide the download preview if it was showing from a previous use
  var previewContainer = document.getElementById("pogModalDownloadPreview");
  if (previewContainer) {
    previewContainer.style.display = "none";
  }
  document.getElementById("pogModalCapture").style.display = "block";
  document.querySelector(".pogModal-downloadHint").style.display = "block";

  $("#playerStatsModal").modal("show");
}

// Long-press to download
(function () {
  var timer = null;
  var startY = 0;
  var HOLD_DURATION = 600; // ms

  function startHold(e) {
    if (e.type === "touchstart") {
      startY = e.touches[0].clientY;
    }
    timer = setTimeout(function () {
      captureAndDownload();
    }, HOLD_DURATION);
  }

  function cancelHold(e) {
    // Only cancel on touchmove if user scrolled significantly
    if (e.type === "touchmove" && timer) {
      var moveY = e.touches[0].clientY;
      if (Math.abs(moveY - startY) < 10) return; // ignore tiny movements
    }
    if (timer) {
      clearTimeout(timer);
      timer = null;
    }
  }

  function captureAndDownload() {
    var captureEl = document.getElementById("pogModalCapture");
    if (!captureEl) return;

    html2canvas(captureEl, {
      backgroundColor: "#0d0d0d",
      scale: 2,
      useCORS: true,
    }).then(function (canvas) {
      // Replace modal content with the rendered image for native long-press save
      var imgDataUrl = canvas.toDataURL("image/png");
      var previewContainer = document.getElementById("pogModalDownloadPreview");
      if (!previewContainer) {
        previewContainer = document.createElement("div");
        previewContainer.id = "pogModalDownloadPreview";
        previewContainer.style.textAlign = "center";
        captureEl.parentNode.insertBefore(previewContainer, captureEl);
      }
      previewContainer.innerHTML =
        '<img src="' +
        imgDataUrl +
        '" style="width:100%;border-radius:8px;" alt="Player Stats">';
      previewContainer.style.display = "block";
      captureEl.style.display = "none";
      document.querySelector(".pogModal-downloadHint").style.display = "none";
    });
  }

  // Bind after modal is in DOM — use capture phase for touchstart to prevent text selection
  var captureArea = document.getElementById("pogModalCapture");
  if (captureArea) {
    captureArea.addEventListener("touchstart", startHold, { passive: true });
    captureArea.addEventListener("touchend", cancelHold);
    captureArea.addEventListener("touchcancel", cancelHold);
    captureArea.addEventListener("touchmove", cancelHold, { passive: true });
  }
  $(document).on("mousedown", "#pogModalCapture", startHold);
  $(document).on("mouseup mouseleave", "#pogModalCapture", cancelHold);
})();
