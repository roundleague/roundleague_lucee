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
  logoImg.src =
    "https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp";
}

function drawCard(ctx, W, H, data, playerImg, logoImg) {
  // === Font families ===
  var fontName = '"Bebas Neue", "Oswald", sans-serif'; // Player name — tall, clean display
  var fontStat = '"Barlow Condensed", "Oswald", sans-serif'; // Stat line — condensed athletic
  var fontScore = '"Bebas Neue", "Oswald", sans-serif'; // Scores — big impact
  var fontLabel = '"Oswald", sans-serif'; // Labels (FINAL, team names)

  // === BACKGROUND ===
  var bgGrad = ctx.createLinearGradient(0, 0, 0, H);
  bgGrad.addColorStop(0, "#1a1a1a");
  bgGrad.addColorStop(0.6, "#111111");
  bgGrad.addColorStop(1, "#0a0a0a");
  ctx.fillStyle = bgGrad;
  ctx.fillRect(0, 0, W, H);

  // === RED ACCENT BORDER (top) ===
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, 0, W, 5);

  // === HEADER SECTION ===
  // League logo (top left) — preserve aspect ratio
  if (logoImg) {
    try {
      var logoMaxH = 45;
      var logoRatio = logoImg.naturalWidth / logoImg.naturalHeight;
      var logoDrawW = logoMaxH * logoRatio;
      ctx.drawImage(logoImg, 18, 14, logoDrawW, logoMaxH);
    } catch (e) {}
  }

  // Player name (top right)
  var playerName = data.firstname + " " + data.lastname;
  ctx.fillStyle = "#ffffff";
  ctx.font = "32px " + fontName;
  ctx.textAlign = "right";
  ctx.letterSpacing = "2px";
  ctx.fillText(playerName.toUpperCase(), W - 22, 38);

  // Stat line below name — spaced out, red
  var statLine =
    data.points + " PTS   " + data.rebounds + " REB   " + data.assists + " AST";
  ctx.fillStyle = "#c8102e";
  ctx.font = "700 17px " + fontStat;
  ctx.textAlign = "right";
  ctx.fillText(statLine, W - 22, 60);

  // Thin separator line below header
  ctx.strokeStyle = "rgba(200,16,46,0.4)";
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(20, 72);
  ctx.lineTo(W - 20, 72);
  ctx.stroke();

  // === PLAYER PHOTO (center/main area) ===
  var photoY = 76;
  var photoH = H - 205;
  var photoW = W;

  // Draw the player photo with cover-fit behavior
  drawImageCover(ctx, playerImg, 0, photoY, photoW, photoH);

  // Gradient overlay at bottom of photo for smooth transition into score bar
  var fadeGrad = ctx.createLinearGradient(
    0,
    photoY + photoH - 180,
    0,
    photoY + photoH,
  );
  fadeGrad.addColorStop(0, "rgba(0,0,0,0)");
  fadeGrad.addColorStop(0.5, "rgba(0,0,0,0.4)");
  fadeGrad.addColorStop(1, "rgba(17,17,17,1)");
  ctx.fillStyle = fadeGrad;
  ctx.fillRect(0, photoY + photoH - 180, W, 180);

  // === SCORE SECTION (bottom) ===
  var scoreAreaY = H - 130;
  var scoreAreaH = 130;

  // Dark background for score area
  ctx.fillStyle = "#111111";
  ctx.fillRect(0, scoreAreaY, W, scoreAreaH);

  // Red accent line at top of score area
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, scoreAreaY, W, 3);

  // Determine winner/loser
  var homeIsWinner = parseInt(data.homescore) > parseInt(data.awayscore);
  var winScore = homeIsWinner ? data.homescore : data.awayscore;
  var loseScore = homeIsWinner ? data.awayscore : data.homescore;
  var winTeamName = homeIsWinner ? data.hometeamname : data.awayteamname;
  var loseTeamName = homeIsWinner ? data.awayteamname : data.hometeamname;

  // Winner score (left side)
  ctx.fillStyle = "#ffffff";
  ctx.font = "82px " + fontScore;
  ctx.textAlign = "left";
  ctx.fillText(winScore, 30, scoreAreaY + 80);

  // Loser score (right side)
  ctx.fillStyle = "#555555";
  ctx.font = "82px " + fontScore;
  ctx.textAlign = "right";
  ctx.fillText(loseScore, W - 30, scoreAreaY + 80);

  // "FINAL" pill (center)
  ctx.font = "500 16px " + fontLabel;
  var finalText = "FINAL";
  var finalW = ctx.measureText(finalText).width;
  var pillW = finalW + 24;
  var pillH = 24;
  var pillX = (W - pillW) / 2;
  var pillY = scoreAreaY + 82;
  // Pill background
  ctx.fillStyle = "rgba(200,16,46,0.9)";
  roundRect(ctx, pillX, pillY, pillW, pillH, 3);
  ctx.fill();
  // Pill text
  ctx.fillStyle = "#ffffff";
  ctx.font = "500 14px " + fontLabel;
  ctx.textAlign = "center";
  ctx.fillText(finalText, W / 2, pillY + 17);

  // Winner team name (bottom left)
  ctx.fillStyle = "#c8102e";
  ctx.font = "600 15px " + fontLabel;
  ctx.textAlign = "left";
  ctx.fillText(winTeamName.toUpperCase(), 30, scoreAreaY + 118);

  // Loser team name (bottom right)
  ctx.fillStyle = "#666666";
  ctx.font = "600 15px " + fontLabel;
  ctx.textAlign = "right";
  ctx.fillText(loseTeamName.toUpperCase(), W - 30, scoreAreaY + 118);

  // === RED ACCENT BORDER (bottom) ===
  ctx.fillStyle = "#c8102e";
  ctx.fillRect(0, H - 4, W, 4);
}

/**
 * Draw a rounded rectangle path
 */
function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
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
