/**
 * Player of the Game Generator
 * Generates a basketball card-style image using HTML5 Canvas
 */

// Filter games table by division and week
function filterGames() {
  var divisionID = document.getElementById("divisionFilter").value;
  var week = document.getElementById("weekFilter").value;
  var rows = document.querySelectorAll("#gamesTable tbody tr");
  rows.forEach(function (row) {
    var divMatch =
      divisionID === "all" || row.getAttribute("data-division") === divisionID;
    var weekMatch = week === "all" || row.getAttribute("data-week") === week;
    row.style.display = divMatch && weekMatch ? "" : "none";
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
  var W = canvas.width; // 1080
  var H = canvas.height; // 1350

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
  // ============================================================
  //  FONT FAMILIES — modern, premium sports typography
  // ============================================================
  var fontDisplay = '"Bebas Neue", "Oswald", sans-serif'; // Hero display (name, score)
  var fontBody = '"Montserrat", "Inter", sans-serif'; // Labels, badges
  var fontStat = '"Barlow Condensed", "Oswald", sans-serif'; // Stat numbers
  var fontAccent = '"Oswald", sans-serif'; // Team names

  // ============================================================
  //  COLORS
  // ============================================================
  var red = "#c8102e";
  var darkBg = "#0d0d0d";
  var midBg = "#141414";

  // ============================================================
  //  1. SOLID DARK BASE
  // ============================================================
  ctx.fillStyle = darkBg;
  ctx.fillRect(0, 0, W, H);

  // ============================================================
  //  2. FULL-BLEED PLAYER PHOTO (cinematic, anchored top)
  // ============================================================
  var photoH = Math.round(H * 0.72); // ~972px — photo dominates
  drawImageCover(ctx, playerImg, 0, 0, W, photoH);

  // --- Shallow depth-of-field vignette (darken edges) ---
  var vigGrad = ctx.createRadialGradient(
    W / 2,
    photoH * 0.38,
    W * 0.22,
    W / 2,
    photoH * 0.38,
    W * 0.85,
  );
  vigGrad.addColorStop(0, "rgba(0,0,0,0)");
  vigGrad.addColorStop(0.6, "rgba(0,0,0,0.15)");
  vigGrad.addColorStop(1, "rgba(0,0,0,0.65)");
  ctx.fillStyle = vigGrad;
  ctx.fillRect(0, 0, W, photoH);

  // --- Top gradient (readability for header text) ---
  var topGrad = ctx.createLinearGradient(0, 0, 0, 260);
  topGrad.addColorStop(0, "rgba(0,0,0,0.72)");
  topGrad.addColorStop(0.5, "rgba(0,0,0,0.30)");
  topGrad.addColorStop(1, "rgba(0,0,0,0)");
  ctx.fillStyle = topGrad;
  ctx.fillRect(0, 0, W, 260);

  // --- Bottom gradient (smooth transition into score panel) ---
  var btmGrad = ctx.createLinearGradient(0, photoH - 360, 0, photoH);
  btmGrad.addColorStop(0, "rgba(13,13,13,0)");
  btmGrad.addColorStop(0.35, "rgba(13,13,13,0.40)");
  btmGrad.addColorStop(0.7, "rgba(13,13,13,0.85)");
  btmGrad.addColorStop(1, "rgba(13,13,13,1)");
  ctx.fillStyle = btmGrad;
  ctx.fillRect(0, photoH - 360, W, 360);

  // --- Subtle left-edge gradient for dramatic side lighting ---
  var sideGrad = ctx.createLinearGradient(0, 0, 220, 0);
  sideGrad.addColorStop(0, "rgba(0,0,0,0.45)");
  sideGrad.addColorStop(1, "rgba(0,0,0,0)");
  ctx.fillStyle = sideGrad;
  ctx.fillRect(0, 0, 220, photoH);

  // ============================================================
  //  3. GRAIN / NOISE TEXTURE (cinematic film look)
  // ============================================================
  applyGrain(ctx, W, H, 0.035);

  // ============================================================
  //  4. RED ACCENT — TOP BAR
  // ============================================================
  ctx.fillStyle = red;
  ctx.fillRect(0, 0, W, 8);

  // ============================================================
  //  5. HEADER — Logo + "PLAYER OF THE GAME" badge
  // ============================================================
  var headerY = 40;
  var pad = 48;

  // League logo (top-left, semi-transparent)
  if (logoImg) {
    try {
      var logoMaxH = 52;
      var logoRatio = logoImg.naturalWidth / logoImg.naturalHeight;
      var logoDrawW = logoMaxH * logoRatio;
      ctx.globalAlpha = 0.85;
      ctx.drawImage(logoImg, pad, headerY, logoDrawW, logoMaxH);
      ctx.globalAlpha = 1.0;
    } catch (e) {}
  }

  // "PLAYER OF THE GAME" badge (top-right)
  ctx.font = "800 18px " + fontBody;
  ctx.letterSpacing = "4px";
  ctx.textAlign = "right";
  ctx.fillStyle = "rgba(255,255,255,0.9)";
  var pogText = "PLAYER OF THE GAME";
  ctx.fillText(pogText, W - pad, headerY + 22);
  ctx.letterSpacing = "0px";

  // Thin accent underline beneath badge
  var pogW = ctx.measureText(pogText).width;
  ctx.fillStyle = red;
  ctx.fillRect(W - pad - pogW, headerY + 30, pogW, 3);

  // ============================================================
  //  6. PLAYER NAME — large hero typography
  // ============================================================
  var nameBaseY = photoH - 220;

  // First name — medium weight, tracked out
  ctx.textAlign = "left";
  ctx.fillStyle = "rgba(255,255,255,0.85)";
  ctx.font = "400 52px " + fontDisplay;
  ctx.letterSpacing = "6px";
  // Drop shadow for depth
  ctx.shadowColor = "rgba(0,0,0,0.6)";
  ctx.shadowBlur = 12;
  ctx.shadowOffsetX = 2;
  ctx.shadowOffsetY = 3;
  ctx.fillText(data.firstname.toUpperCase(), pad, nameBaseY);

  // Last name — very large, bold, dominant
  ctx.fillStyle = "#ffffff";
  ctx.font = "700 108px " + fontDisplay;
  ctx.letterSpacing = "4px";
  ctx.shadowBlur = 20;
  ctx.fillText(data.lastname.toUpperCase(), pad - 3, nameBaseY + 94);

  // Reset shadow
  ctx.shadowColor = "transparent";
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
  ctx.letterSpacing = "0px";

  // Team name below — red accent
  ctx.fillStyle = red;
  ctx.font = "700 28px " + fontAccent;
  ctx.letterSpacing = "8px";
  ctx.fillText(data.teamname.toUpperCase(), pad, nameBaseY + 132);
  ctx.letterSpacing = "0px";

  // ============================================================
  //  7. STATS BAR — clean, evenly spaced with separators
  // ============================================================
  var statsY = photoH - 30;
  var statsH = 90;
  var statsCenterY = statsY + statsH / 2;

  // Semi-transparent bar background
  ctx.fillStyle = "rgba(13,13,13,0.85)";
  ctx.fillRect(0, statsY, W, statsH);

  // Top accent line
  ctx.fillStyle = "rgba(200,16,46,0.5)";
  ctx.fillRect(pad, statsY, W - pad * 2, 2);

  var stats = [
    { label: "PTS", value: data.points },
    { label: "REB", value: data.rebounds },
    { label: "AST", value: data.assists },
  ];

  var statZoneW = (W - pad * 2) / stats.length;

  for (var i = 0; i < stats.length; i++) {
    var cx = pad + statZoneW * i + statZoneW / 2;

    // Stat number — large
    ctx.fillStyle = "#ffffff";
    ctx.font = "700 54px " + fontDisplay;
    ctx.textAlign = "center";
    ctx.letterSpacing = "2px";
    ctx.fillText(stats[i].value, cx, statsCenterY + 8);

    // Stat label — smaller, dimmed
    ctx.fillStyle = "rgba(255,255,255,0.45)";
    ctx.font = "700 16px " + fontBody;
    ctx.letterSpacing = "4px";
    ctx.fillText(stats[i].label, cx, statsCenterY + 32);
    ctx.letterSpacing = "0px";

    // Vertical separator (except after last)
    if (i < stats.length - 1) {
      var sepX = pad + statZoneW * (i + 1);
      ctx.strokeStyle = "rgba(255,255,255,0.12)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(sepX, statsY + 16);
      ctx.lineTo(sepX, statsY + statsH - 16);
      ctx.stroke();
    }
  }

  // ============================================================
  //  8. SCORE SECTION — dominant, clean grid
  // ============================================================
  var scoreAreaY = statsY + statsH + 12;
  var scoreAreaH = H - scoreAreaY - 8;

  // Score panel background
  ctx.fillStyle = midBg;
  ctx.fillRect(0, scoreAreaY, W, scoreAreaH);

  // Determine winner/loser
  var homeIsWinner = parseInt(data.homescore) > parseInt(data.awayscore);
  var winScore = homeIsWinner ? data.homescore : data.awayscore;
  var loseScore = homeIsWinner ? data.awayscore : data.homescore;
  var winTeamName = homeIsWinner ? data.hometeamname : data.awayteamname;
  var loseTeamName = homeIsWinner ? data.awayteamname : data.hometeamname;

  // --- Team names row ---
  var teamNameY = scoreAreaY + 48;
  ctx.font = "700 26px " + fontAccent;
  ctx.letterSpacing = "5px";

  // Winner team name (left)
  ctx.textAlign = "left";
  ctx.fillStyle = "#ffffff";
  ctx.fillText(winTeamName.toUpperCase(), pad, teamNameY);

  // Loser team name (right)
  ctx.textAlign = "right";
  ctx.fillStyle = "rgba(255,255,255,0.35)";
  ctx.fillText(loseTeamName.toUpperCase(), W - pad, teamNameY);
  ctx.letterSpacing = "0px";

  // --- Score numbers row ---
  var scoreNumY = teamNameY + 120;

  // Winner score — huge, white, bold
  ctx.textAlign = "left";
  ctx.fillStyle = "#ffffff";
  ctx.font = "700 144px " + fontDisplay;
  ctx.letterSpacing = "4px";
  // Subtle glow behind winner score
  ctx.shadowColor = "rgba(200,16,46,0.25)";
  ctx.shadowBlur = 30;
  ctx.fillText(winScore, pad, scoreNumY);
  ctx.shadowColor = "transparent";
  ctx.shadowBlur = 0;

  // Loser score — dimmed, smaller weight feel
  ctx.textAlign = "right";
  ctx.fillStyle = "rgba(255,255,255,0.22)"; // heavily dimmed
  ctx.font = "700 144px " + fontDisplay;
  ctx.fillText(loseScore, W - pad, scoreNumY);
  ctx.letterSpacing = "0px";

  // --- Dash separator between scores ---
  ctx.textAlign = "center";
  ctx.fillStyle = "rgba(255,255,255,0.15)";
  ctx.font = "400 80px " + fontDisplay;
  ctx.fillText("—", W / 2, scoreNumY - 18);

  // --- "FINAL" badge (centered pill with glow) ---
  var pillText = "FINAL";
  ctx.font = "800 20px " + fontBody;
  ctx.letterSpacing = "6px";
  var pillTextW = ctx.measureText(pillText).width;
  var pillPadX = 28;
  var pillPadY = 10;
  var pillW = pillTextW + pillPadX * 2;
  var pillH = 36;
  var pillX = (W - pillW) / 2;
  var pillY = scoreNumY + 24;

  // Glow behind pill
  ctx.shadowColor = "rgba(200,16,46,0.5)";
  ctx.shadowBlur = 20;
  ctx.fillStyle = red;
  roundRect(ctx, pillX, pillY, pillW, pillH, 6);
  ctx.fill();
  ctx.shadowColor = "transparent";
  ctx.shadowBlur = 0;

  // Pill text
  ctx.fillStyle = "#ffffff";
  ctx.font = "800 20px " + fontBody;
  ctx.letterSpacing = "6px";
  ctx.textAlign = "center";
  ctx.fillText(pillText, W / 2, pillY + 26);
  ctx.letterSpacing = "0px";

  // ============================================================
  //  9. BOTTOM ACCENT BAR
  // ============================================================
  ctx.fillStyle = red;
  ctx.fillRect(0, H - 8, W, 8);

  // ============================================================
  //  10. EDGE VIGNETTE (entire canvas, subtle)
  // ============================================================
  var edgeVig = ctx.createRadialGradient(
    W / 2,
    H / 2,
    W * 0.35,
    W / 2,
    H / 2,
    W * 0.95,
  );
  edgeVig.addColorStop(0, "rgba(0,0,0,0)");
  edgeVig.addColorStop(1, "rgba(0,0,0,0.30)");
  ctx.fillStyle = edgeVig;
  ctx.fillRect(0, 0, W, H);
}

/**
 * Apply subtle film grain / noise texture
 */
function applyGrain(ctx, W, H, opacity) {
  var grainCanvas = document.createElement("canvas");
  grainCanvas.width = W;
  grainCanvas.height = H;
  var gCtx = grainCanvas.getContext("2d");
  var imageData = gCtx.createImageData(W, H);
  var pixels = imageData.data;
  for (var i = 0; i < pixels.length; i += 4) {
    var v = Math.random() * 255;
    pixels[i] = v;
    pixels[i + 1] = v;
    pixels[i + 2] = v;
    pixels[i + 3] = Math.random() * 255 * opacity;
  }
  gCtx.putImageData(imageData, 0, 0);
  ctx.drawImage(grainCanvas, 0, 0);
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
