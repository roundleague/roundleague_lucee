/**
 * Player of the Game Generator
 * Generates a basketball card-style image using HTML5 Canvas
 */

// Filter games table by division
function filterByDivision(divisionID) {
  var rows = document.querySelectorAll("#gamesTable tbody tr");
  rows.forEach(function (row) {
    if (
      divisionID === "all" ||
      row.getAttribute("data-division") === divisionID
    ) {
      row.style.display = "";
    } else {
      row.style.display = "none";
    }
  });
}

// Main generate function
function generatePlayerOfTheGame(btn) {
  var scheduleID = btn.getAttribute("data-scheduleid");
  var winnerTeamID = btn.getAttribute("data-winnerteamid");
  var homeScore = btn.getAttribute("data-homescore");
  var awayScore = btn.getAttribute("data-awayscore");
  var homeTeam = btn.getAttribute("data-hometeam");
  var awayTeam = btn.getAttribute("data-awayteam");

  // Show preview section and loading
  document.getElementById("previewSection").style.display = "block";
  document.getElementById("loadingSpinner").style.display = "block";
  document.getElementById("canvasContainer").style.display = "none";

  // Scroll to preview
  document
    .getElementById("previewSection")
    .scrollIntoView({ behavior: "smooth" });

  // Fetch player data from the server
  fetch(
    "/admin-dashboard/pages/playerOfTheGame/getPlayerOfTheGame.cfm?scheduleID=" +
      scheduleID +
      "&winnerTeamID=" +
      winnerTeamID,
  )
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (data.error) {
        alert("Error: " + data.error);
        document.getElementById("loadingSpinner").style.display = "none";
        return;
      }
      renderCard(data);
    })
    .catch(function (err) {
      alert("Error generating player of the game: " + err.message);
      document.getElementById("loadingSpinner").style.display = "none";
    });
}

function renderCard(data) {
  // Normalize Lucee JSON keys (Lucee uppercases keys by default)
  var d = normalizeKeys(data);

  var canvas = document.getElementById("pogCanvas");
  var ctx = canvas.getContext("2d");
  var W = canvas.width; // 540
  var H = canvas.height; // 680

  // Load images first, then draw
  var playerImg = new Image();
  playerImg.crossOrigin = "anonymous";
  var logoImg = new Image();
  logoImg.crossOrigin = "anonymous";

  var imagesLoaded = 0;
  var totalImages = 2;

  function onImageLoad() {
    imagesLoaded++;
    if (imagesLoaded >= totalImages) {
      drawCard(ctx, W, H, d, playerImg, logoImg);
      document.getElementById("loadingSpinner").style.display = "none";
      document.getElementById("canvasContainer").style.display = "block";
    }
  }

  playerImg.onload = onImageLoad;
  playerImg.onerror = function () {
    // If player photo fails, try default
    playerImg.src = "/assets/img/PlayerProfiles/default.JPG";
  };

  logoImg.onload = onImageLoad;
  logoImg.onerror = function () {
    // If logo fails, still proceed
    imagesLoaded++;
    if (imagesLoaded >= totalImages) {
      drawCard(ctx, W, H, d, playerImg, null);
      document.getElementById("loadingSpinner").style.display = "none";
      document.getElementById("canvasContainer").style.display = "block";
    }
  };

  playerImg.src = d.photourl;
  logoImg.src = "/assets/img/Logos/BW Logo.png";
}

function drawCard(ctx, W, H, data, playerImg, logoImg) {
  // === BACKGROUND ===
  // Dark gradient background
  var bgGrad = ctx.createLinearGradient(0, 0, 0, H);
  bgGrad.addColorStop(0, "#1a1a1a");
  bgGrad.addColorStop(1, "#0d0d0d");
  ctx.fillStyle = bgGrad;
  ctx.fillRect(0, 0, W, H);

  // === RED ACCENT BORDER (top) ===
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, 0, W, 6);

  // === HEADER SECTION ===
  // League logo (top left) — preserve aspect ratio
  if (logoImg) {
    try {
      var logoMaxH = 50;
      var logoRatio = logoImg.naturalWidth / logoImg.naturalHeight;
      var logoDrawW = logoMaxH * logoRatio;
      ctx.drawImage(logoImg, 15, 12, logoDrawW, logoMaxH);
    } catch (e) {}
  }

  // Player name (top right)
  var playerName = data.firstname + " " + data.lastname;
  ctx.fillStyle = "#ffffff";
  ctx.font = 'bold 26px "Arial Black", Arial, sans-serif';
  ctx.textAlign = "right";
  ctx.fillText(playerName, W - 20, 35);

  // Stat line below name
  var statLine =
    data.points + " PTS  " + data.rebounds + " REB  " + data.assists + " AST";
  ctx.fillStyle = "#c8102e";
  ctx.font = "bold 16px Arial, sans-serif";
  ctx.textAlign = "right";
  ctx.fillText(statLine, W - 20, 58);

  // === PLAYER PHOTO (center/main area) ===
  var photoY = 75;
  var photoH = H - 200;
  var photoW = W;

  // Draw the player photo with cover-fit behavior
  drawImageCover(ctx, playerImg, 0, photoY, photoW, photoH);

  // Subtle gradient overlay at bottom of photo for text readability
  var fadeGrad = ctx.createLinearGradient(
    0,
    photoY + photoH - 150,
    0,
    photoY + photoH,
  );
  fadeGrad.addColorStop(0, "rgba(0,0,0,0)");
  fadeGrad.addColorStop(1, "rgba(0,0,0,0.85)");
  ctx.fillStyle = fadeGrad;
  ctx.fillRect(0, photoY + photoH - 150, W, 150);

  // === SCORE SECTION (bottom) ===
  var scoreAreaY = H - 125;
  var scoreAreaH = 125;

  // Dark background for score area
  ctx.fillStyle = "#111111";
  ctx.fillRect(0, scoreAreaY, W, scoreAreaH);

  // Red accent line
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, scoreAreaY, W, 4);

  // Determine winner/loser sides
  var homeIsWinner = parseInt(data.homescore) > parseInt(data.awayscore);
  var winScore = homeIsWinner ? data.homescore : data.awayscore;
  var loseScore = homeIsWinner ? data.awayscore : data.homescore;
  var winTeamName = homeIsWinner ? data.hometeamname : data.awayteamname;
  var loseTeamName = homeIsWinner ? data.awayteamname : data.hometeamname;

  // Winner score (left side, large white)
  ctx.fillStyle = "#ffffff";
  ctx.font = 'bold 72px "Arial Black", Arial, sans-serif';
  ctx.textAlign = "left";
  ctx.fillText(winScore, 30, scoreAreaY + 78);

  // Loser score (right side, large gray)
  ctx.fillStyle = "#888888";
  ctx.font = 'bold 72px "Arial Black", Arial, sans-serif';
  ctx.textAlign = "right";
  ctx.fillText(loseScore, W - 30, scoreAreaY + 78);

  // "FINAL" text (center bottom)
  ctx.fillStyle = "#ffffff";
  ctx.font = "bold 18px Arial, sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("FINAL", W / 2, scoreAreaY + 100);

  // Winner team name (bottom LEFT, aligned with winner score)
  ctx.fillStyle = "#c8102e";
  ctx.font = "bold 14px Arial, sans-serif";
  ctx.textAlign = "left";
  ctx.fillText(winTeamName.toUpperCase(), 30, scoreAreaY + 118);

  // Loser team name (bottom RIGHT, aligned with loser score)
  ctx.fillStyle = "#888888";
  ctx.font = "bold 14px Arial, sans-serif";
  ctx.textAlign = "right";
  ctx.fillText(loseTeamName.toUpperCase(), W - 30, scoreAreaY + 118);

  // === RED ACCENT BORDER (bottom) ===
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, H - 4, W, 4);
}

/**
 * Draw an image with "object-fit: cover" behavior on a canvas
 */
function drawImageCover(ctx, img, x, y, w, h) {
  var imgW = img.naturalWidth || img.width;
  var imgH = img.naturalHeight || img.height;

  if (imgW === 0 || imgH === 0) return;

  var imgRatio = imgW / imgH;
  var targetRatio = w / h;

  var sx, sy, sw, sh;

  if (imgRatio > targetRatio) {
    // Image is wider than target: crop sides
    sh = imgH;
    sw = imgH * targetRatio;
    sx = (imgW - sw) / 2;
    sy = 0;
  } else {
    // Image is taller than target: crop top/bottom (favor top for player photos)
    sw = imgW;
    sh = imgW / targetRatio;
    sx = 0;
    sy = 0; // Anchor to top to capture head/upper body
  }

  ctx.drawImage(img, sx, sy, sw, sh, x, y, w, h);
}

/**
 * Normalize Lucee JSON keys (Lucee upper-cases all struct keys)
 */
function normalizeKeys(obj) {
  var result = {};
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      result[key.toLowerCase()] = obj[key];
    }
  }
  return result;
}

/**
 * Download the generated canvas as a PNG image
 */
function downloadImage() {
  var canvas = document.getElementById("pogCanvas");
  var link = document.createElement("a");

  // Try to get player name for filename
  var filename = "player_of_the_game.png";

  link.download = filename;
  link.href = canvas.toDataURL("image/png");
  link.click();
}
