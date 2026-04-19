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

  function patchScore(homeScore) {
    fetch(API_BASE + '/schedule/' + cfg.scheduleID + '/score', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'x-admin-key': cfg.adminKey },
      body: JSON.stringify({ homeScore: homeScore, status: 'live' })
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

  btnReset.addEventListener('click', function () {
    stopClock();
    remainingSeconds = HALF_SECONDS;
    renderDisplay();
    patchClock('stopped');
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

  // Sync live score from teamTotalPts to homeScore on scrimmage slot
  $(document).ready(function () {
    var totalPtsEl = document.querySelector('.teamTotalPts');
    if (totalPtsEl) {
      var observer = new MutationObserver(function () {
        var score = parseInt(totalPtsEl.textContent) || 0;
        patchScore(score);
      });
      observer.observe(totalPtsEl, { childList: true, characterData: true, subtree: true });
    }
  });

  // Mark as live on page load
  patchScore(0);

  renderDisplay();
})();
