<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Round League Scoreboard</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background: #0a0a0a;
      color: #fff;
      font-family: 'Arial Black', 'Impact', Arial, sans-serif;
      height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      user-select: none;
    }

    #board {
      width: 100%;
      max-width: 1400px;
      padding: 0 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
    }

    .team-block {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 16px;
    }

    .team-name {
      font-size: clamp(1.6rem, 4vw, 3.2rem);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      text-align: center;
      color: #f0f0f0;
    }

    .team-score {
      font-size: clamp(5rem, 18vw, 14rem);
      line-height: 1;
      font-variant-numeric: tabular-nums;
      color: #fff;
      text-shadow: 0 0 40px rgba(255,255,255,0.15);
    }

    .team-label {
      font-size: clamp(0.75rem, 1.5vw, 1.1rem);
      letter-spacing: 0.2em;
      color: #666;
      text-transform: uppercase;
    }

    #center-block {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
      min-width: 220px;
    }

    #clock {
      font-size: clamp(3rem, 9vw, 7rem);
      font-variant-numeric: tabular-nums;
      letter-spacing: 0.05em;
      color: #ffd700;
      text-shadow: 0 0 30px rgba(255, 215, 0, 0.3);
    }

    #period {
      font-size: clamp(1rem, 2.5vw, 1.8rem);
      color: #aaa;
      letter-spacing: 0.15em;
    }

    #status-badge {
      margin-top: 8px;
      font-size: clamp(0.75rem, 1.5vw, 1rem);
      letter-spacing: 0.25em;
      color: #444;
    }

    #status-badge.live {
      color: #ff4444;
      animation: pulse 2s ease-in-out infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }

    #no-game {
      font-size: 1.4rem;
      color: #555;
      text-align: center;
      letter-spacing: 0.1em;
    }
  </style>
</head>
<body>

<div id="board" style="display:none">
  <div class="team-block">
    <div class="team-label">HOME</div>
    <div class="team-name" id="homeName">—</div>
    <div class="team-score" id="homeScore">0</div>
  </div>

  <div id="center-block">
    <div id="clock">25:00</div>
    <div id="period">H1</div>
    <div id="status-badge">SCHEDULED</div>
  </div>

  <div class="team-block">
    <div class="team-label">AWAY</div>
    <div class="team-name" id="awayName">—</div>
    <div class="team-score" id="awayScore">0</div>
  </div>
</div>

<div id="no-game">Loading game…</div>

<script>
  var API_BASE = 'https://round-league-api.onrender.com/api';
  var params   = new URLSearchParams(location.search);
  var scheduleID = params.get('game');

  // --- Clock state (maintained locally, resynced from server)
  var clockRemaining = 25 * 60; // seconds
  var clockRunning   = false;
  var clockPeriod    = 1;
  var clockTicker    = null;
  var lastSyncAt     = null; // wall-clock ms when we last synced
  var lastSyncRemaining = null;

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  function renderClock() {
    var s = Math.max(0, clockRemaining);
    document.getElementById('clock').textContent = pad(Math.floor(s / 60)) + ':' + pad(s % 60);
    document.getElementById('period').textContent = 'H' + clockPeriod;
  }

  function startLocalTicker() {
    if (clockTicker) return;
    clockTicker = setInterval(function () {
      if (clockRunning && clockRemaining > 0) {
        clockRemaining--;
        renderClock();
      }
    }, 1000);
  }

  function applyClockState(data) {
    clockPeriod  = data.clock_period || 1;
    clockRunning = data.clock_status === 'running';
    // clock_display_seconds is pre-computed server-side via TIMESTAMPDIFF — no client time math
    clockRemaining = Math.max(0, parseInt(data.clock_display_seconds, 10) || 0);
    if (clockRunning) startLocalTicker();
    renderClock();
  }

  function fetchClock() {
    if (!scheduleID) return;
    fetch(API_BASE + '/schedule/' + scheduleID + '/clock')
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (data) { if (data) applyClockState(data); })
      .catch(function () {});
  }

  function fetchGame() {
    if (!scheduleID) {
      document.getElementById('no-game').textContent = 'No game ID in URL. Add ?game=SCHEDULEID';
      return;
    }
    fetch(API_BASE + '/schedule/' + scheduleID)
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (data) {
        if (!data || !data.game) {
          document.getElementById('no-game').textContent = 'Game not found.';
          return;
        }
        var g = data.game;
        document.getElementById('homeName').textContent  = g.homeTeam  || '—';
        document.getElementById('awayName').textContent  = g.awayTeam  || '—';
        document.getElementById('homeScore').textContent = g.homeScore !== null ? g.homeScore : 0;
        document.getElementById('awayScore').textContent = g.awayScore !== null ? g.awayScore : 0;

        var badge = document.getElementById('status-badge');
        badge.textContent = (g.status || 'scheduled').toUpperCase();
        badge.className   = g.status === 'live' ? 'live' : '';

        document.getElementById('board').style.display = 'flex';
        document.getElementById('no-game').style.display = 'none';
      })
      .catch(function () {});
  }

  if (!scheduleID) {
    document.getElementById('no-game').textContent = 'No game ID in URL. Add ?game=SCHEDULEID';
  } else {
    // Initial loads
    fetchGame();
    fetchClock();

    // Poll scores every 5s
    setInterval(fetchGame, 5000);

    // Resync clock every 3s — fast enough to catch pause/resume quickly
    setInterval(fetchClock, 3000);

    // Local ticker already started by applyClockState when running
    startLocalTicker();
  }
</script>

</body>
</html>
