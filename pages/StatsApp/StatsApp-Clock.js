/* ============================================================
 * StatsApp-Clock.js
 * Shared clock panel logic for scrimmage and live games.
 * Expects a config object on window: SCRIMMAGE_CONFIG or LIVE_SCORE_CONFIG.
 * ============================================================ */
(function () {
  var cfg = window.SCRIMMAGE_CONFIG || window.LIVE_SCORE_CONFIG;
  if (!cfg) return;

  var API_BASE = (cfg.apiBase || "https://round-league-api.onrender.com") + "/api";
  var API_PATH = cfg.apiPath || "/schedule"; // "/playoffs/schedule" for playoff games
  var HALF_SECONDS = 25 * 60;
  var SHOT_CLOCK_SECONDS = 30;
  var SHOT_CLOCK_OREB_SECONDS = 14;

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
  var shotClockEditInput = document.getElementById("shotClockEditInput");
  var btnShotStart = document.getElementById("shotClockStart");
  var btnShotPause = document.getElementById("shotClockPause");
  var btnResetShot = document.getElementById("clockResetShot");
  var btnResetShot14 = document.getElementById("clockResetShot14");
  var btnSubHorn = document.getElementById("clockSubHorn");
  var shotEditWasRunning = false;
  var shotClockWasRunningOnPause = false;
  var shotClockEnabled = true;
  if (!displayEl) return;

  function setShotClockEnabled(enabled) {
    shotClockEnabled = enabled;
    if (!enabled) {
      stopShotClockTicker();
      shotClockRemaining = 0;
      renderShotClock();
      patchShotClock(0, "stopped");
    }
    if (btnResetShot14) {
      btnResetShot14.textContent = enabled ? "SC: ON" : "SC: OFF";
      btnResetShot14.style.background = enabled ? "#27ae60" : "#6c757d";
    }
  }

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
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/score", {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "x-admin-key": cfg.adminKey },
      body: JSON.stringify({ status: status }),
    });
  }

  function patchClock(status) {
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/clock", {
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
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/clock", {
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
        // Heartbeat every second so listeners (overlay, other displays) stay
        // live even when the shot clock isn't ticking to piggyback updates.
        patchClock("running");
        if (remainingSeconds === 0 && !gameBuzzed) {
          gameBuzzed = true;
          playBuzzer("long");
          if (period === 1) {
            setTimeout(function () {
              if (confirm("End of 1st half — switch to 2nd half?")) {
                stopClock();
                period = 2;
                if (periodEl) periodEl.textContent = "H2";
                var switchLabel = document.querySelector(".switch-label");
                if (switchLabel) switchLabel.setAttribute("data-value", "2");
                var switchInput = document.querySelector(".switch-input");
                if (switchInput) switchInput.checked = false;
                remainingSeconds = HALF_SECONDS;
                gameBuzzed = false;
                renderDisplay();
                stopShotClockTicker();
                shotClockRemaining = SHOT_CLOCK_SECONDS;
                shotClockBuzzed = false;
                renderShotClock();
                patchShotClock(SHOT_CLOCK_SECONDS, "stopped");
                patchClock("stopped");
              }
            }, 500);
          }
        }
      } else {
        stopClock();
        patchClock("stopped");
      }
    }, 1000);
    btnStart.disabled = true;
    btnPause.disabled = false;
    if (shotClockWasRunningOnPause && !shotClockBuzzed) {
      startShotClockTicker();
      patchShotClock(shotClockRemaining, "running");
    }
    shotClockWasRunningOnPause = false;
    patchClock("running");
    patchGameStatus("live");
  }

  function stopClock(saveForResume) {
    clearInterval(ticker);
    ticker = null;
    if (saveForResume) {
      shotClockWasRunningOnPause = !!shotClockTicker;
      if (shotClockTicker) {
        stopShotClockTicker();
        patchShotClock(shotClockRemaining, "stopped");
      }
    }
    btnStart.disabled = false;
    btnPause.disabled = true;
  }

  btnStart.addEventListener("click", function () {
    startClock();
  });

  btnPause.addEventListener("click", function () {
    stopClock(true);
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
        stopShotClockTicker();
        patchShotClock(0, "stopped");
      }
    }, 1000);
    if (btnShotStart) btnShotStart.disabled = true;
    if (btnShotPause) btnShotPause.disabled = false;
  }

  function stopShotClockTicker() {
    clearInterval(shotClockTicker);
    shotClockTicker = null;
    if (btnShotStart) btnShotStart.disabled = false;
    if (btnShotPause) btnShotPause.disabled = true;
  }

  if (btnShotStart) {
    btnShotStart.addEventListener("click", function () {
      startShotClockTicker();
      patchShotClock(shotClockRemaining, "running");
    });
  }

  if (btnShotPause) {
    btnShotPause.addEventListener("click", function () {
      stopShotClockTicker();
      patchShotClock(shotClockRemaining, "stopped");
    });
  }

  if (btnResetShot) {
    btnResetShot.addEventListener("click", function () {
      if (!shotClockEnabled) setShotClockEnabled(true);
      stopShotClockTicker();
      shotClockRemaining = SHOT_CLOCK_SECONDS;
      shotClockBuzzed = false;
      renderShotClock();
      patchShotClock(SHOT_CLOCK_SECONDS, "running");
      startShotClockTicker();
    });
  }

  if (btnResetShot14) {
    btnResetShot14.addEventListener("click", function () {
      setShotClockEnabled(!shotClockEnabled);
    });
  }

  // ── Shot clock inline edit ────────────────────────────────
  function enterShotEditMode() {
    shotEditWasRunning = !!shotClockTicker;
    if (shotEditWasRunning) stopShotClockTicker();
    if (shotClockEditInput) {
      shotClockEditInput.value = shotClockRemaining;
      shotClockEl.style.display = "none";
      shotClockEditInput.style.display = "";
      shotClockEditInput.focus();
      shotClockEditInput.select();
    }
  }

  function exitShotEditMode(commit) {
    if (!shotClockEditInput || shotClockEditInput.style.display === "none") return;
    if (commit) {
      var val = Math.max(0, Math.min(99, parseInt(shotClockEditInput.value, 10) || 0));
      shotClockRemaining = val;
      shotClockBuzzed = false;
      renderShotClock();
      patchShotClock(shotClockRemaining, shotEditWasRunning ? "running" : "stopped");
      if (shotEditWasRunning) startShotClockTicker();
    } else {
      renderShotClock();
      if (!shotClockTicker) {
        if (btnShotStart) btnShotStart.disabled = false;
        if (btnShotPause) btnShotPause.disabled = true;
      }
    }
    shotClockEditInput.style.display = "none";
    shotClockEl.style.display = "";
  }

  if (shotClockEl) {
    shotClockEl.addEventListener("click", function () { enterShotEditMode(); });
  }

  if (shotClockEditInput) {
    shotClockEditInput.addEventListener("keydown", function (e) {
      if (e.key === "Enter")  { e.preventDefault(); exitShotEditMode(true); }
      if (e.key === "Escape") { e.preventDefault(); exitShotEditMode(false); }
    });
    shotClockEditInput.addEventListener("blur", function () { exitShotEditMode(true); });
  }

  if (btnSubHorn) {
    btnSubHorn.addEventListener("click", function () {
      playBuzzer("sub");
      if (window.gameSocket) window.gameSocket.emit("subhorn", { scheduleID: cfg.scheduleID, type: cfg.gameType || "schedule" });
    });
  }

  var btnSync = document.getElementById("clockSync");
  if (btnSync) {
    btnSync.addEventListener("click", function () {
      patchShotClock(shotClockRemaining, shotClockTicker ? "running" : "stopped");
      var btn = this;
      btn.textContent = "Synced";
      btn.style.background = "#28a745";
      setTimeout(function () {
        btn.textContent = "Sync Board";
        btn.style.background = "#6c757d";
      }, 1500);
    });
  }

  // ── Reset game ────────────────────────────────────────────
  function resetScores() {
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/score", {
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
    var resetSwitchLabel = document.querySelector(".switch-label");
    if (resetSwitchLabel) resetSwitchLabel.setAttribute("data-value", "1");
    var resetSwitchInput = document.querySelector(".switch-input");
    if (resetSwitchInput) resetSwitchInput.checked = true;
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
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/fouls", {
      method: "PATCH", headers: headers,
      body: JSON.stringify({ home_fouls_h1: 0, home_fouls_h2: 0, away_fouls_h1: 0, away_fouls_h2: 0 }),
    });
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/timeouts", {
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
    // The local ticker is the source of truth while running — only snap to
    // the server value on real drift (>2s), not on every poll/echo. Polled
    // responses are computed via TIMESTAMPDIFF and can land a second off
    // just from request latency/rounding, which used to cause a visible
    // flash backward every 10s.
    if (!ticker || Math.abs(serverSeconds - remainingSeconds) > 2) {
      remainingSeconds = serverSeconds;
    }

    if (serverPeriod !== period) {
      period = serverPeriod;
      if (periodEl) periodEl.textContent = "H" + period;
      // Sync the half-switch so getCurrentHalf() stays accurate on all clients.
      var switchLabel = document.querySelector(".switch-label");
      if (switchLabel) switchLabel.setAttribute("data-value", String(serverPeriod));
      var switchInput = document.querySelector(".switch-input");
      if (switchInput) switchInput.checked = (serverPeriod === 1);
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

      // Any upward jump means a reset — always clear the buzz and apply it.
      if (serverShotSeconds > shotClockRemaining) shotClockBuzzed = false;
      // Keep local shot ticker authoritative while running unless a meaningful
      // drift/reset happens, otherwise echoed socket updates can double-step.
      // Upward jumps (resets) always apply regardless of threshold.
      if (
        !shotClockTicker ||
        !serverShotRunning ||
        serverShotSeconds > shotClockRemaining ||
        Math.abs(serverShotSeconds - shotClockRemaining) > 1
      ) {
        shotClockRemaining = serverShotSeconds;
      }
      renderShotClock();

      if (serverShotRunning && !shotClockTicker) {
        startShotClockTicker();
      } else if (!serverShotRunning && shotClockTicker) {
        stopShotClockTicker();
      } else {
        // Sync button states even when ticker state didn't change
        if (btnShotStart) btnShotStart.disabled = !!shotClockTicker;
        if (btnShotPause) btnShotPause.disabled = !shotClockTicker;
      }
    }
  }

  function fetchClock() {
    fetch(API_BASE + API_PATH + "/" + cfg.scheduleID + "/clock")
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
        stopClock(true);
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
    } else if (e.key === "e" || e.key === "E") {
      enterShotEditMode();
    } else if (e.key === "f" || e.key === "F") {
      if (btnResetShot14) btnResetShot14.click();
    }
  });

  // Initial sync — socket handles subsequent updates; poll every 10s as fallback
  // for missed socket events and to correct accumulated clock drift.
  fetchClock();
  setInterval(fetchClock, 10000);
  if (window.gameSocket) {
    window.gameSocket.on("clock:update", function (data) {
      applyClockState(data);
    });
  }

  renderDisplay();
  renderShotClock();

  setShotClockEnabled(true);

  window.shotClockControl = {
    resetTo30AndStart: function () {
      if (!shotClockEnabled) return;
      stopShotClockTicker();
      shotClockRemaining = SHOT_CLOCK_SECONDS;
      shotClockBuzzed = false;
      renderShotClock();
      patchShotClock(SHOT_CLOCK_SECONDS, "running");
      startShotClockTicker();
    }
  };
})();
