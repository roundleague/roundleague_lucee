/* ============================================================
 * StatsApp-Clock.js
 * Shared clock panel logic for scrimmage and live games.
 * Expects a config object on window: SCRIMMAGE_CONFIG or LIVE_SCORE_CONFIG.
 * ============================================================ */
(function () {
  var cfg = window.SCRIMMAGE_CONFIG || window.LIVE_SCORE_CONFIG;
  if (!cfg) return;

  var API_BASE = 'https://round-league-api.onrender.com/api';
  var HALF_SECONDS = 25 * 60;
  var remainingSeconds = HALF_SECONDS;
  var period = 1;
  var ticker = null;

  var displayEl = document.getElementById('clockDisplay');
  var periodEl  = document.getElementById('clockPeriodLabel');
  var btnStart  = document.getElementById('clockStart');
  var btnPause  = document.getElementById('clockPause');
  var btnReset  = document.getElementById('clockReset');
  if (!displayEl) return;

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  function renderDisplay() {
    var m = Math.floor(remainingSeconds / 60);
    var s = remainingSeconds % 60;
    displayEl.textContent = pad(m) + ':' + pad(s);
  }

  function patchClock(status) {
    fetch(API_BASE + '/schedule/' + cfg.scheduleID + '/clock', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'x-admin-key': cfg.adminKey },
      body: JSON.stringify({ clock_status: status, clock_remaining_seconds: remainingSeconds, clock_period: period })
    });
  }

  function startClock() {
    if (ticker) return;
    ticker = setInterval(function () {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        renderDisplay();
      } else {
        stopClock();
        patchClock('stopped');
      }
    }, 1000);
    btnStart.disabled = true;
    btnPause.disabled = false;
    patchClock('running');
  }

  function stopClock() {
    clearInterval(ticker);
    ticker = null;
    btnStart.disabled = false;
    btnPause.disabled = true;
  }

  btnStart.addEventListener('click', function () { startClock(); });

  btnPause.addEventListener('click', function () {
    stopClock();
    patchClock('paused');
  });

  function resetScores() {
    fetch(API_BASE + '/schedule/' + cfg.scheduleID + '/score', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'x-admin-key': cfg.adminKey },
      body: JSON.stringify({ homeScore: null, awayScore: null, status: 'scheduled' })
    });
  }

  btnReset.addEventListener('click', function () {
    if (!confirm('Reset game? This will clear scores and reset the clock to 25:00 H1.')) return;
    stopClock();
    remainingSeconds = HALF_SECONDS;
    period = 1;
    if (periodEl) periodEl.textContent = 'H1';
    renderDisplay();
    patchClock('stopped');
    resetScores();
  });

  // Sync period from bench-bar half toggle
  document.addEventListener('click', function (e) {
    if (e.target.closest('.switch-label')) {
      setTimeout(function () {
        var label = document.querySelector('.switch-label');
        period = label ? (label.getAttribute('data-value') === '2' ? 2 : 1) : 1;
        periodEl.textContent = 'H' + period;
        patchClock(ticker ? 'running' : 'stopped');
      }, 50);
    }
  });

  // Poll server clock so both stat keepers stay in sync.
  // clock_display_seconds is computed server-side (accounts for elapsed time
  // since last save), so both pages converge on the same value each poll.
  function applyClockState(data) {
    var serverRunning = data.clock_status === 'running';
    var serverSeconds = Math.max(0, parseInt(data.clock_display_seconds, 10) || 0);
    var serverPeriod  = data.clock_period || 1;

    remainingSeconds = serverSeconds;
    if (serverPeriod !== period) {
      period = serverPeriod;
      if (periodEl) periodEl.textContent = 'H' + period;
    }

    if (serverRunning && !ticker) {
      // Other stat keeper started — begin ticking locally
      ticker = setInterval(function () {
        if (remainingSeconds > 0) { remainingSeconds--; renderDisplay(); }
        else { stopClock(); }
      }, 1000);
      btnStart.disabled = true;
      btnPause.disabled = false;
    } else if (!serverRunning && ticker) {
      // Other stat keeper paused/stopped — halt local ticker
      stopClock();
    }

    renderDisplay();
  }

  function fetchClock() {
    fetch(API_BASE + '/schedule/' + cfg.scheduleID + '/clock')
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (d) { if (d) applyClockState(d); })
      .catch(function () {});
  }

  // Initial sync then poll every 4 s
  fetchClock();
  setInterval(fetchClock, 4000);

  renderDisplay();
})();
