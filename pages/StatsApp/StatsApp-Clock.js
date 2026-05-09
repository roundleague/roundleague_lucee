/* ============================================================
 * StatsApp-Clock.js
 * Shared clock panel logic for scrimmage and live games.
 * Expects a config object on window: SCRIMMAGE_CONFIG or LIVE_SCORE_CONFIG.
 * ============================================================ */
(function () {
  var cfg = window.SCRIMMAGE_CONFIG || window.LIVE_SCORE_CONFIG;
  if (!cfg) return;

  var API_BASE = (cfg.apiBase || "https://round-league-api.onrender.com") + "/api";
  var HALF_SECONDS = 25 * 60;
  var SHOT_CLOCK_SECONDS = 24;

  // Game clock state
  var remainingSeconds = HALF_SECONDS;
  var period = 1;
  var ticker = null;
  var gameBuzzed = false;
  var editWasRunning = false;

  // Shot clock state
  var shotClockRemaining = SHOT_CLOCK_SECONDS;
  var shotClockTicker = null;
  var shotClockBuzzed = false;

  var displayEl = document.getElementById("clockDisplay");
  var clockEditInput = document.getElementById("clockEditInput");
  var periodEl = document.getElementById("clockPeriodLabel");
  var btnStart = document.getElementById("clockStart");
  var btnPause = document.getElementById("clockPause");
  var btnReset = document.getElementById("clockReset");
  var shotClockEl = document.getElementById("shotClockDisplay");
  var btnResetShot = document.getElementById("clockResetShot");
  var btnSubHorn = document.getElementById("clockSubHorn");
  if (!displayEl) return;

  function pad(n) {
    return n < 10 ? "0" + n : "" + n;
  }

  function renderDisplay() {
    var m = Math.floor(remainingSeconds / 60);
    var s = remainingSeconds % 60;
    displayEl.textContent = pad(m) + ":" + pad(s);
  }

  function renderShotClock() {
    if (shotClockEl) shotClockEl.textContent = Math.max(0, shotClockRemaining);
  }

  // ── Audio buzzer ──────────────────────────────────────────
  var sounds = {
    sub: new Audio("/assets/sounds/subhorn.MP3"),
    long: new Audio("/assets/sounds/gamebuzzer.MP3"),
  };

  function playBuzzer(type) {
    try {
      var audio = type === "sub" ? sounds.sub : sounds.long;
      audio.currentTime = 0;
      audio.play();
    } catch (e) {}
  }

  // ── API patches ───────────────────────────────────────────
  function patchGameStatus(status) {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/score", {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "x-admin-key": cfg.adminKey },
      body: JSON.stringify({ status: status }),
    });
  }

  function patchClock(status) {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/clock", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "x-admin-key": cfg.adminKey,
      },
      body: JSON.stringify({
        clock_status: status,
        clock_remaining_seconds: remainingSeconds,
        clock_period: period,
      }),
    });
  }

  function patchShotClock(scRemaining, scStatus) {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/clock", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "x-admin-key": cfg.adminKey,
      },
      body: JSON.stringify({
        clock_status: ticker ? "running" : "stopped",
        clock_remaining_seconds: remainingSeconds,
        clock_period: period,
        shot_clock_remaining: scRemaining,
        shot_clock_status: scStatus,
      }),
    });
  }

  // ── Game clock ────────────────────────────────────────────
  function startClock() {
    if (ticker) return;
    gameBuzzed = false;
    ticker = setInterval(function () {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        renderDisplay();
        if (remainingSeconds === 0 && !gameBuzzed) {
          gameBuzzed = true;
          playBuzzer("long");
        }
      } else {
        stopClock();
        patchClock("stopped");
      }
    }, 1000);
    btnStart.disabled = true;
    btnPause.disabled = false;
    patchClock("running");
    patchGameStatus("live");
  }

  function stopClock() {
    clearInterval(ticker);
    ticker = null;
    btnStart.disabled = false;
    btnPause.disabled = true;
  }

  btnStart.addEventListener("click", function () {
    startClock();
  });

  btnPause.addEventListener("click", function () {
    stopClock();
    patchClock("paused");
  });

  // ── Shot clock ────────────────────────────────────────────
  function startShotClockTicker() {
    if (shotClockTicker) return;
    shotClockTicker = setInterval(function () {
      if (shotClockRemaining > 0) {
        shotClockRemaining--;
        renderShotClock();
        patchShotClock(shotClockRemaining, "running");
        if (shotClockRemaining === 0 && !shotClockBuzzed) {
          shotClockBuzzed = true;
          playBuzzer("long");
          patchShotClock(0, "stopped");
        }
      } else {
        clearInterval(shotClockTicker);
        shotClockTicker = null;
        patchShotClock(0, "stopped");
      }
    }, 1000);
  }

  function stopShotClockTicker() {
    clearInterval(shotClockTicker);
    shotClockTicker = null;
  }

  if (btnResetShot) {
    btnResetShot.addEventListener("click", function () {
      stopShotClockTicker();
      shotClockRemaining = SHOT_CLOCK_SECONDS;
      shotClockBuzzed = false;
      renderShotClock();
      patchShotClock(SHOT_CLOCK_SECONDS, "running");
      startShotClockTicker();
    });
  }

  if (btnSubHorn) {
    btnSubHorn.addEventListener("click", function () {
      playBuzzer("sub");
      if (window.gameSocket) window.gameSocket.emit("subhorn", cfg.scheduleID);
    });
  }

  // ── Reset game ────────────────────────────────────────────
  function resetScores() {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/score", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "x-admin-key": cfg.adminKey,
      },
      body: JSON.stringify({
        homeScore: null,
        awayScore: null,
        status: "scheduled",
      }),
    });
  }

  btnReset.addEventListener("click", function () {
    if (
      !confirm(
        "Reset game? This will clear scores and reset the clock to 25:00 H1.",
      )
    )
      return;
    stopClock();
    remainingSeconds = HALF_SECONDS;
    period = 1;
    gameBuzzed = false;
    if (periodEl) periodEl.textContent = "H1";
    renderDisplay();
    patchClock("stopped");
    resetScores();
    // Reset shot clock
    stopShotClockTicker();
    shotClockRemaining = SHOT_CLOCK_SECONDS;
    shotClockBuzzed = false;
    renderShotClock();
    patchShotClock(SHOT_CLOCK_SECONDS, "stopped");
    // Reset fouls and timeouts UI
    document.querySelectorAll(".Fouls_Half_1, .Fouls_Half_2").forEach(function (el) { el.textContent = "0"; });
    document.querySelectorAll(".Timeouts_Half_1, .Timeouts_Half_2").forEach(function (el) { el.textContent = "2"; });
    // Reset fouls and timeouts in DB
    var headers = { "Content-Type": "application/json", "x-admin-key": cfg.adminKey };
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/fouls", {
      method: "PATCH", headers: headers,
      body: JSON.stringify({ home_fouls_h1: 0, home_fouls_h2: 0, away_fouls_h1: 0, away_fouls_h2: 0 }),
    });
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/timeouts", {
      method: "PATCH", headers: headers,
      body: JSON.stringify({ home_timeouts_h1: 2, home_timeouts_h2: 2, away_timeouts_h1: 2, away_timeouts_h2: 2 }),
    });
  });

  // ── Period toggle ─────────────────────────────────────────
  document.addEventListener("click", function (e) {
    if (e.target.closest(".switch-label")) {
      setTimeout(function () {
        var label = document.querySelector(".switch-label");
        period = label ? (label.getAttribute("data-value") === "2" ? 2 : 1) : 1;
        periodEl.textContent = "H" + period;
        patchClock(ticker ? "running" : "stopped");
      }, 50);
    }
  });

  // ── Server sync ───────────────────────────────────────────
  function applyClockState(data) {
    var serverRunning = data.clock_status === "running";
    var serverSeconds = Math.max(
      0,
      parseInt(data.clock_display_seconds, 10) || 0,
    );
    var serverPeriod = data.clock_period || 1;

    // Reset buzz flag if clock was reset (time jumped up)
    if (serverSeconds > remainingSeconds + 5) gameBuzzed = false;
    // Only overwrite local game clock from server echo when ticker is not
    // running, or when value differs by more than 2s (real reset/pause).
    // Prevents shot-clock patches from bouncing remainingSeconds back.
    if (!ticker || Math.abs(serverSeconds - remainingSeconds) > 2) {
      remainingSeconds = serverSeconds;
    }

    if (serverPeriod !== period) {
      period = serverPeriod;
      if (periodEl) periodEl.textContent = "H" + period;
    }

    if (serverRunning && !ticker) {
      ticker = setInterval(function () {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          renderDisplay();
          if (remainingSeconds === 0 && !gameBuzzed) {
            gameBuzzed = true;
            playBuzzer("long");
          }
        } else {
          stopClock();
        }
      }, 1000);
      btnStart.disabled = true;
      btnPause.disabled = false;
    } else if (!serverRunning && ticker) {
      stopClock();
    }

    renderDisplay();

    // Sync shot clock
    if (data.shot_clock_display_seconds !== undefined) {
      var serverShotRunning = data.shot_clock_status === "running";
      var serverShotSeconds = Math.max(
        0,
        parseInt(data.shot_clock_display_seconds, 10) || 0,
      );

      if (serverShotSeconds > shotClockRemaining + 5) shotClockBuzzed = false;
      // Keep local shot ticker authoritative while running unless a meaningful
      // drift/reset happens, otherwise echoed socket updates can double-step.
      if (
        !shotClockTicker ||
        !serverShotRunning ||
        Math.abs(serverShotSeconds - shotClockRemaining) > 1
      ) {
        shotClockRemaining = serverShotSeconds;
      }
      renderShotClock();

      if (serverShotRunning && !shotClockTicker) {
        startShotClockTicker();
      } else if (!serverShotRunning && shotClockTicker) {
        stopShotClockTicker();
      }
    }
  }

  function fetchClock() {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/clock")
      .then(function (r) {
        return r.ok ? r.json() : null;
      })
      .then(function (d) {
        if (d) applyClockState(d);
      })
      .catch(function () {});
  }

  // ── Inline clock edit ─────────────────────────────────────
  function enterEditMode() {
    editWasRunning = !!ticker;
    if (editWasRunning) stopClock();
    if (clockEditInput) {
      clockEditInput.value = displayEl.textContent;
      displayEl.style.display = "none";
      clockEditInput.style.display = "";
      clockEditInput.focus();
      clockEditInput.select();
    }
  }

  function exitEditMode(commit) {
    if (!clockEditInput || clockEditInput.style.display === "none") return;
    if (commit) {
      var raw = clockEditInput.value.trim();
      if (raw) {
        var parts = raw.split(":");
        var mins = Math.max(0, Math.min(99, parseInt(parts[0], 10) || 0));
        var secs = parts.length > 1 ? Math.max(0, Math.min(59, parseInt(parts[1], 10) || 0)) : 0;
        remainingSeconds = mins * 60 + secs;
        gameBuzzed = false;
      }
      renderDisplay();
      patchClock(editWasRunning ? "running" : "stopped");
      if (editWasRunning) startClock();
    } else {
      renderDisplay();
      if (!ticker) { btnStart.disabled = false; btnPause.disabled = true; }
    }
    clockEditInput.style.display = "none";
    displayEl.style.display = "";
  }

  displayEl.addEventListener("click", function () { enterEditMode(); });

  if (clockEditInput) {
    clockEditInput.addEventListener("keydown", function (e) {
      if (e.key === "Enter")  { e.preventDefault(); exitEditMode(true); }
      if (e.key === "Escape") { e.preventDefault(); exitEditMode(false); }
    });
    clockEditInput.addEventListener("blur", function () { exitEditMode(true); });
  }

  // ── Keyboard shortcuts ────────────────────────────────────
  document.addEventListener("keydown", function (e) {
    if (
      e.target.tagName === "INPUT" ||
      e.target.tagName === "TEXTAREA" ||
      e.target.tagName === "SELECT"
    )
      return;
    if (e.code === "Space") {
      e.preventDefault();
      if (ticker) {
        stopClock();
        patchClock("paused");
      } else {
        startClock();
      }
    } else if (e.key === "r" || e.key === "R") {
      if (btnResetShot) btnResetShot.click();
    } else if (e.key === "t" || e.key === "T") {
      if (shotClockTicker) {
        stopShotClockTicker();
        patchShotClock(shotClockRemaining, "stopped");
      } else {
        startShotClockTicker();
        patchShotClock(shotClockRemaining, "running");
      }
    }
  });

  // Initial sync — socket handles subsequent updates
  fetchClock();
  if (window.gameSocket) {
    window.gameSocket.on("clock:update", function (data) {
      applyClockState(data);
    });
  }

  renderDisplay();
  renderShotClock();
})();
