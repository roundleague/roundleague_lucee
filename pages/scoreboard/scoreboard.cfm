<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Round League Scoreboard</title>
  <script src="https://cdn.socket.io/4.7.5/socket.io.min.js"></script>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    /* ── STYLE 1: Dark ESPN ── */
    body.s1 {
      background: #0a0a0a; color: #fff;
      font-family: 'Arial Black', Arial, sans-serif;
    }
    body.s1 .team-name  { color: #f0f0f0; }
    body.s1 .team-score { color: #fff; text-shadow: 0 0 40px rgba(255,255,255,.15); }
    body.s1 .team-label { color: #555; }
    body.s1 #clock      { color: #ffd700; text-shadow: 0 0 30px rgba(255,215,0,.3); }
    body.s1 #period     { color: #aaa; }
    body.s1 #status-badge        { color: #333; }
    body.s1 #status-badge.live   { color: #ff4444; }

    /* ── STYLE 2: Retro Gym (LED orange on black) ── */
    body.s2 {
      background: #0d0d0d; color: #ff8c00;
      font-family: 'Courier New', 'Lucida Console', monospace;
    }
    body.s2 .team-name  { color: #ffaa44; letter-spacing: 0.12em; }
    body.s2 .team-score { color: #ff8c00; text-shadow: 0 0 20px #ff6600, 0 0 60px rgba(255,100,0,.4); }
    body.s2 .team-label { color: #663300; letter-spacing: 0.25em; }
    body.s2 #clock      { color: #ff8c00; text-shadow: 0 0 20px #ff6600, 0 0 60px rgba(255,100,0,.4); }
    body.s2 #period     { color: #cc5500; }
    body.s2 #status-badge        { color: #442200; }
    body.s2 #status-badge.live   { color: #ff4400; }
    body.s2 #board { border: 2px solid #331100; border-radius: 4px; padding: 40px; background: #0a0800; }

    /* ── STYLE 3: Clean Light (modern arena) ── */
    body.s3 {
      background: #f0f2f5; color: #0d1b2a;
      font-family: 'Arial Black', 'Helvetica Neue', Arial, sans-serif;
    }
    body.s3 #board { background: #fff; border-radius: 16px; box-shadow: 0 8px 40px rgba(0,0,0,.12); padding: 60px 80px; }
    body.s3 .team-name  { color: #0d1b2a; }
    body.s3 .team-score { color: #0d1b2a; }
    body.s3 .team-label { color: #aaa; font-size: clamp(.65rem, 1.2vw, .95rem); }
    body.s3 #clock      { color: #c8102e; }
    body.s3 #period     { color: #888; }
    body.s3 #status-badge        { color: #ccc; }
    body.s3 #status-badge.live   { color: #c8102e; }

    /* ── Shared layout ── */
    body {
      height: 100vh; display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      overflow: hidden; user-select: none;
    }

    #board {
      width: 100%; max-width: 1500px; padding: 0 60px;
      display: flex; align-items: center; justify-content: space-between; gap: 20px;
    }

    .team-block {
      flex: 1; display: flex; flex-direction: column;
      align-items: center; gap: 12px;
    }

    .team-name  { font-size: clamp(1.6rem, 4vw, 3.4rem); text-transform: uppercase; letter-spacing: .06em; text-align: center; min-height: 3em; display: flex; align-items: center; justify-content: center; }
    .team-score { font-size: clamp(6rem, 20vw, 16rem); line-height: 1; font-variant-numeric: tabular-nums; }
    .team-label { font-size: clamp(.7rem, 1.4vw, 1rem); letter-spacing: .2em; text-transform: uppercase; }

    #center-block { display: flex; flex-direction: column; align-items: center; gap: 8px; min-width: 240px; }

    #clock   { font-size: clamp(3.5rem, 10vw, 8rem); font-variant-numeric: tabular-nums; letter-spacing: .04em; }
    #period  { font-size: clamp(1rem, 2.5vw, 1.8rem); letter-spacing: .15em; }

    #shot-clock-block { display: flex; flex-direction: column; align-items: center; gap: 2px; margin-top: 4px; }
    #shot-clock-label { font-size: clamp(.55rem, 1vw, .8rem); letter-spacing: .25em; text-transform: uppercase; opacity: .6; }
    #shot-clock { font-size: clamp(2.5rem, 7vw, 5.5rem); font-variant-numeric: tabular-nums; font-weight: bold; line-height: 1; }
    body.s1 #shot-clock { color: #ff8c00; text-shadow: 0 0 20px rgba(255,140,0,.35); }
    body.s2 #shot-clock { color: #ff8c00; text-shadow: 0 0 16px #ff6600; }
    body.s3 #shot-clock { color: #c8102e; }

    #status-badge { margin-top: 6px; font-size: clamp(.7rem, 1.4vw, 1rem); letter-spacing: .25em; }
    #status-badge.live { animation: pulse 2s ease-in-out infinite; }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.35} }

    .team-fouls-block { display: flex; flex-direction: column; align-items: center; gap: 2px; margin-top: -4px; }
    .team-fouls { font-size: clamp(1.4rem, 4vw, 3rem); font-variant-numeric: tabular-nums; line-height: 1; }
    body.s1 .team-fouls { color: #bbb; }
    body.s2 .team-fouls { color: #cc6600; }
    body.s3 .team-fouls { color: #555; }

    .team-timeouts-block { display: flex; flex-direction: column; align-items: center; gap: 4px; margin-top: 6px; }
    .timeout-dots { display: flex; gap: clamp(4px, 1vw, 10px); }
    .timeout-dot {
      width: clamp(10px, 1.8vw, 18px); height: clamp(10px, 1.8vw, 18px);
      border-radius: 50%; border: 2px solid currentColor;
      transition: background .2s;
    }
    .timeout-dot.used { background: transparent; opacity: .35; }
    .timeout-dot.remaining { background: currentColor; }
    body.s1 .timeout-dot { color: #bbb; }
    body.s2 .timeout-dot { color: #cc6600; }
    body.s3 .timeout-dot { color: #555; }

    #no-game { font-size: 1.4rem; color: #555; text-align: center; letter-spacing: .1em; }

    /* Style picker (visible locally for review, hidden when ?preview=0) */
    #style-picker {
      position: fixed; top: 16px; right: 16px; display: flex; gap: 8px; z-index: 100;
    }
    #style-picker button {
      padding: 6px 14px; border: none; border-radius: 4px; cursor: pointer;
      font-size: .85rem; font-weight: bold; background: rgba(128,128,128,.3); color: inherit;
    }
    #style-picker button.active { background: rgba(255,255,255,.7); color: #000; }
    body.s3 #style-picker button.active { background: rgba(0,0,0,.15); color: #000; }

    #reset-btn {
      position: fixed; top: 16px; left: 16px; z-index: 100;
      padding: 6px 14px; border: none; border-radius: 4px; cursor: pointer;
      font-size: .85rem; font-weight: bold; background: rgba(200,0,0,.55); color: #fff;
    }
    #reset-btn:hover { background: rgba(200,0,0,.85); }
  </style>
</head>
<body class="s1">

<button id="reset-btn" onclick="resetGame()">Reset Game</button>

<div id="style-picker">
  <button onclick="setStyle(1)" class="active">Style 1</button>
  <button onclick="setStyle(2)">Style 2</button>
  <button onclick="setStyle(3)">Style 3</button>
</div>

<div id="waiting-overlay" style="position:fixed;inset:0;background:rgba(0,0,0,.85);display:flex;flex-direction:column;align-items:center;justify-content:center;z-index:200;">
  <div style="font-size:clamp(2rem,6vw,4rem);letter-spacing:.1em;margin-bottom:1rem;">WAITING FOR GAME</div>
  <div style="font-size:clamp(.9rem,2vw,1.4rem);opacity:.5;letter-spacing:.15em;">AUTO MODE</div>
</div>

<div id="gameover-overlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.85);align-items:center;justify-content:center;z-index:200;">
  <div style="font-size:clamp(3rem,10vw,7rem);letter-spacing:.1em;">FINAL</div>
</div>

<div id="board" style="display:none">
  <div class="team-block">
    <div class="team-label">HOME</div>
    <div class="team-name" id="homeName">&mdash;</div>
    <div class="team-score" id="homeScore">0</div>
    <div class="team-fouls-block">
      <div class="team-label">TEAM FOULS</div>
      <div class="team-fouls" id="homeFouls">0</div>
    </div>
    <div class="team-timeouts-block">
      <div class="team-label">TIMEOUTS</div>
      <div class="timeout-dots" id="homeTimeoutDots"></div>
    </div>
  </div>

  <div id="center-block">
    <div id="clock">25:00</div>
    <div id="period">H1</div>
    <div id="shot-clock-block">
      <div id="shot-clock-label">Shot Clock</div>
      <div id="shot-clock">30</div>
    </div>
    <div id="status-badge">SCHEDULED</div>
  </div>

  <div class="team-block">
    <div class="team-label">AWAY</div>
    <div class="team-name" id="awayName">&mdash;</div>
    <div class="team-score" id="awayScore">0</div>
    <div class="team-fouls-block">
      <div class="team-label">TEAM FOULS</div>
      <div class="team-fouls" id="awayFouls">0</div>
    </div>
    <div class="team-timeouts-block">
      <div class="team-label">TIMEOUTS</div>
      <div class="timeout-dots" id="awayTimeoutDots"></div>
    </div>
  </div>
</div>

<div id="no-game">Loading game&hellip;</div>

<script>
  var API_BASE   = '<cfoutput>#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#</cfoutput>/api';
  var ADMIN_KEY  = '<cfoutput>#application.adminApiKey#</cfoutput>';
  var params     = new URLSearchParams(location.search);
  var scheduleID = params.get('game');
  var overrideHome = params.get('home');
  var overrideAway = params.get('away');
  var styleParam = parseInt(params.get('style') || '1', 10);

  // Apply URL style param on load
  setStyle(styleParam);

  function setStyle(n) {
    document.body.className = 's' + n;
    document.querySelectorAll('#style-picker button').forEach(function(b, i) {
      b.classList.toggle('active', i + 1 === n);
    });
  }

  // Clock state
  var clockRemaining = 25 * 60;
  var clockRunning   = false;
  var clockPeriod    = 1;
  var clockTicker    = null;
  var gameBuzzed     = false;

  // Shot clock state
  var shotRemaining = 30;
  var shotRunning   = false;
  var shotTicker    = null;
  var shotBuzzed    = false;

  // Team foul state (per half, home + away)
  var foulState = { home_fouls_h1: 0, home_fouls_h2: 0, away_fouls_h1: 0, away_fouls_h2: 0 };

  function renderFouls() {
    var h = clockPeriod === 2 ? 'h2' : 'h1';
    document.getElementById('homeFouls').textContent = foulState['home_fouls_' + h];
    document.getElementById('awayFouls').textContent = foulState['away_fouls_' + h];
  }

  // Timeout state (per half, home + away) — default 2 per half
  var timeoutState = { home_timeouts_h1: 2, home_timeouts_h2: 2, away_timeouts_h1: 2, away_timeouts_h2: 2 };

  function renderTimeouts() {
    var h = clockPeriod === 2 ? 'h2' : 'h1';
    renderDots('homeTimeoutDots', timeoutState['home_timeouts_' + h], 2);
    renderDots('awayTimeoutDots', timeoutState['away_timeouts_' + h], 2);
  }

  function renderDots(elId, remaining, total) {
    var el = document.getElementById(elId);
    if (!el) return;
    var html = '';
    for (var i = 0; i < total; i++) {
      html += '<div class="timeout-dot ' + (i < remaining ? 'remaining' : 'used') + '"></div>';
    }
    el.innerHTML = html;
  }

  // Audio buzzer
  var sounds = {
    sub:  new Audio('/assets/sounds/subhorn.MP3'),
    long: new Audio('/assets/sounds/gamebuzzer.MP3'),
    countdown: new Audio('/assets/sounds/shot_clock_countdown_beep.mp3')
  };

  function playBuzzer(type) {
    try {
      var audio = type === 'sub' ? sounds.sub : type === 'countdown' ? sounds.countdown : sounds.long;
      audio.currentTime = 0;
      audio.play();
    } catch (e) {}
  }

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  function renderClock() {
    var s = Math.max(0, clockRemaining);
    document.getElementById('clock').textContent = pad(Math.floor(s / 60)) + ':' + pad(s % 60);
    document.getElementById('period').textContent = 'H' + clockPeriod;
  }

  function renderShotClock() {
    document.getElementById('shot-clock').textContent = Math.max(0, shotRemaining);
  }

  function startLocalTicker() {
    if (clockTicker) return;
    clockTicker = setInterval(function () {
      if (clockRunning && clockRemaining > 0) {
        clockRemaining--;
        renderClock();
        if (clockRemaining === 0 && !gameBuzzed) {
          gameBuzzed = true;
          playBuzzer('long');
        }
      }
    }, 1000);
  }

  function startShotTicker() {
    if (shotTicker) return;
    shotTicker = setInterval(function () {
      if (shotRunning && shotRemaining > 0) {
        shotRemaining--;
        renderShotClock();
        if (shotRemaining === 0 && !shotBuzzed) {
          shotBuzzed = true;
          playBuzzer('long');
        } else if (shotRemaining > 0 && shotRemaining <= 10) {
          playBuzzer('countdown');
        }
      }
    }, 1000);
  }

  function applyClockState(data) {
    var prevClockRemaining = clockRemaining;
    var prevShotRemaining  = shotRemaining;

    clockPeriod  = data.clock_period || 1;
    clockRunning = data.clock_status === 'running';
    var serverClockSeconds = Math.max(0, parseInt(data.clock_display_seconds, 10) || 0);

    // Drift guard: keep local ticker authoritative while running to avoid shot-clock
    // echo patches causing the game clock to stutter. When stopped/paused, always
    // snap to server value so the clock doesn't freeze at 1 second when time expires.
    if (!clockTicker || !clockRunning || Math.abs(serverClockSeconds - clockRemaining) > 2) {
      clockRemaining = serverClockSeconds;
    }

    // Reset buzz flag if clock was reset (time jumped up)
    if (serverClockSeconds > prevClockRemaining + 5) gameBuzzed = false;
    // Buzz here if the server confirms time expired and we haven't buzzed yet
    if (clockRemaining === 0 && !clockRunning && !gameBuzzed) {
      gameBuzzed = true;
      playBuzzer('long');
    }
    if (clockRunning) startLocalTicker();
    renderClock();

    // Shot clock
    if (data.shot_clock_display_seconds !== undefined) {
      shotRunning = data.shot_clock_status === 'running';
      var serverShotSeconds = Math.max(0, parseInt(data.shot_clock_display_seconds, 10) || 0);

      if (serverShotSeconds > prevShotRemaining + 5) shotBuzzed = false;
      // Keep local shot ticker authoritative while running unless a meaningful
      // drift/reset happens, otherwise echoed socket updates can double-step.
      if (!shotTicker || !shotRunning || Math.abs(serverShotSeconds - shotRemaining) > 1) {
        shotRemaining = serverShotSeconds;
      }

      if (shotRunning) {
        startShotTicker();
      } else if (shotTicker) {
        clearInterval(shotTicker);
        shotTicker = null;
      }
      renderShotClock();
    }

    renderFouls();
    renderTimeouts();
  }

  function applyFoulData(d) {
    if (d.home_fouls_h1 !== undefined) foulState.home_fouls_h1 = d.home_fouls_h1;
    if (d.home_fouls_h2 !== undefined) foulState.home_fouls_h2 = d.home_fouls_h2;
    if (d.away_fouls_h1 !== undefined) foulState.away_fouls_h1 = d.away_fouls_h1;
    if (d.away_fouls_h2 !== undefined) foulState.away_fouls_h2 = d.away_fouls_h2;
    renderFouls();
  }

  function applyTimeoutData(d) {
    if (d.home_timeouts_h1 !== undefined) timeoutState.home_timeouts_h1 = d.home_timeouts_h1;
    if (d.home_timeouts_h2 !== undefined) timeoutState.home_timeouts_h2 = d.home_timeouts_h2;
    if (d.away_timeouts_h1 !== undefined) timeoutState.away_timeouts_h1 = d.away_timeouts_h1;
    if (d.away_timeouts_h2 !== undefined) timeoutState.away_timeouts_h2 = d.away_timeouts_h2;
    renderTimeouts();
  }

  function fetchClock() {
    if (!scheduleID) return;
    fetch(API_BASE + '/schedule/' + scheduleID + '/clock')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(d) { if (d) { applyClockState(d); applyFoulData(d); applyTimeoutData(d); } })
      .catch(function() {});
  }

  function fetchGame(nameHome, nameAway) {
    if (!scheduleID) return;
    fetch(API_BASE + '/schedule/' + scheduleID)
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (!data || !data.game) { document.getElementById('no-game').textContent = 'Game not found.'; return; }
        var g = data.game;
        document.getElementById('homeName').textContent  = nameHome || overrideHome || g.homeTeam || '—';
        document.getElementById('awayName').textContent  = nameAway || overrideAway || g.awayTeam || '—';
        document.getElementById('homeScore').textContent = g.homeScore !== null ? g.homeScore : 0;
        document.getElementById('awayScore').textContent = g.awayScore !== null ? g.awayScore : 0;
        applyFoulData(g);
        applyTimeoutData(g);

        var badge = document.getElementById('status-badge');
        badge.textContent = (g.status || 'scheduled').toUpperCase();
        badge.className   = g.status === 'live' ? 'live' : '';

        document.getElementById('board').style.display = 'flex';
        document.getElementById('no-game').style.display = 'none';
      })
      .catch(function() {});
  }

  function resetGame() {
    if (!scheduleID) return;
    if (!confirm('Reset game? This will clear both scores and reset the clock to 25:00 H1.')) return;
    var headers = { 'Content-Type': 'application/json', 'x-admin-key': ADMIN_KEY };
    fetch(API_BASE + '/schedule/' + scheduleID + '/score', {
      method: 'PATCH', headers: headers,
      body: JSON.stringify({ homeScore: null, awayScore: null, status: 'scheduled' })
    });
    fetch(API_BASE + '/schedule/' + scheduleID + '/clock', {
      method: 'PATCH', headers: headers,
      body: JSON.stringify({ clock_status: 'stopped', clock_remaining_seconds: 1500, clock_period: 1, shot_clock_remaining: 30, shot_clock_status: 'stopped' })
    });
    fetch(API_BASE + '/schedule/' + scheduleID + '/fouls', {
      method: 'PATCH', headers: headers,
      body: JSON.stringify({ home_fouls_h1: 0, home_fouls_h2: 0, away_fouls_h1: 0, away_fouls_h2: 0 })
    });
    fetch(API_BASE + '/schedule/' + scheduleID + '/timeouts', {
      method: 'PATCH', headers: headers,
      body: JSON.stringify({ home_timeouts_h1: 2, home_timeouts_h2: 2, away_timeouts_h1: 2, away_timeouts_h2: 2 })
    });
    // Update display immediately without waiting for next poll
    document.getElementById('homeScore').textContent = '—';
    document.getElementById('awayScore').textContent = '—';
    foulState = { home_fouls_h1: 0, home_fouls_h2: 0, away_fouls_h1: 0, away_fouls_h2: 0 };
    timeoutState = { home_timeouts_h1: 2, home_timeouts_h2: 2, away_timeouts_h1: 2, away_timeouts_h2: 2 };
    renderFouls();
    renderTimeouts();
    clockRemaining = 1500;
    clockRunning   = false;
    clockPeriod    = 1;
    gameBuzzed     = false;
    clearInterval(clockTicker);
    clockTicker = null;
    renderClock();
    shotRemaining = 30;
    shotRunning   = false;
    shotBuzzed    = false;
    clearInterval(shotTicker);
    shotTicker = null;
    renderShotClock();
    var badge = document.getElementById('status-badge');
    badge.textContent = 'SCHEDULED';
    badge.className   = '';
  }

  var isAutoMode = !scheduleID;

  if (!isAutoMode) {
    // ── MANUAL MODE: existing behavior ───────────────────────────
    document.getElementById('waiting-overlay').style.display = 'none';
    fetchGame();
    fetchClock();
    startLocalTicker();
    setInterval(fetchClock, 10000);
    setInterval(fetchGame, 10000);

    var socket = io('<cfoutput>#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#</cfoutput>');
    socket.emit('join', scheduleID);
    socket.on('connect', function() {
      socket.emit('join', scheduleID);
      fetchClock();
      fetchGame();
    });
    socket.on('clock:update', function(data) { applyClockState(data); });
    socket.on('score:update', function(data) {
      if (data.homeScore !== undefined) document.getElementById('homeScore').textContent = data.homeScore !== null ? data.homeScore : 0;
      if (data.awayScore !== undefined) document.getElementById('awayScore').textContent = data.awayScore !== null ? data.awayScore : 0;
      if (data.status) {
        var badge = document.getElementById('status-badge');
        badge.textContent = data.status.toUpperCase();
        badge.className = data.status === 'live' ? 'live' : '';
      }
    });
    socket.on('fouls:update', function(data) { applyFoulData(data); });
    socket.on('timeouts:update', function(data) { applyTimeoutData(data); });
    socket.on('subhorn', function() { playBuzzer('sub'); });

  } else {
    // ── AUTO MODE: state machine ──────────────────────────────────
    var GAME_OVER_DELAY = 8000;
    var autoState    = 'waiting';
    var activeGameID = null;

    var waitingOverlay  = document.getElementById('waiting-overlay');
    var gameoverOverlay = document.getElementById('gameover-overlay');
    var boardEl         = document.getElementById('board');
    document.getElementById('no-game').style.display = 'none';

    var socket = io('<cfoutput>#isDefined("application.apiBase") ? application.apiBase : "https://round-league-api.onrender.com"#</cfoutput>');

    socket.on('connect', function() {
      socket.emit('join-lobby');
      if (autoState === 'live' && activeGameID) socket.emit('join', activeGameID);
    });

    function enterWaiting() {
      autoState    = 'waiting';
      activeGameID = null;
      scheduleID   = null;
      clearInterval(clockTicker); clockTicker = null;
      clearInterval(shotTicker);  shotTicker  = null;
      waitingOverlay.style.display  = 'flex';
      gameoverOverlay.style.display = 'none';
      boardEl.style.display         = 'none';
      socket.emit('join-lobby');
      pollActiveGame();
    }

    function enterLive(id, homeTeam, awayTeam) {
      if (autoState === 'live' && activeGameID === String(id)) return;
      autoState    = 'live';
      activeGameID = String(id);
      scheduleID   = String(id);
      clockRemaining = 25 * 60; clockRunning = false; clockPeriod = 1; gameBuzzed = false;
      shotRemaining  = 30;      shotRunning  = false; shotBuzzed  = false;
      clearInterval(clockTicker); clockTicker = null;
      clearInterval(shotTicker);  shotTicker  = null;
      renderClock(); renderShotClock();
      socket.emit('join', activeGameID);
      waitingOverlay.style.display  = 'none';
      gameoverOverlay.style.display = 'none';
      boardEl.style.display         = 'flex';
      fetchGame(homeTeam, awayTeam);
      fetchClock();
    }

    function enterGameOver() {
      if (autoState !== 'live') return;
      autoState = 'game_over';
      clearInterval(clockTicker); clockTicker = null;
      clearInterval(shotTicker);  shotTicker  = null;
      gameoverOverlay.style.display = 'flex';
      setTimeout(function() {
        gameoverOverlay.style.display = 'none';
        enterWaiting();
      }, GAME_OVER_DELAY);
    }

    function pollActiveGame() {
      fetch(API_BASE + '/schedule/active-game')
        .then(function(r) { return r.ok ? r.json() : null; })
        .then(function(d) {
          if (d && d.game && autoState === 'waiting')
            enterLive(d.game.scheduleID, d.game.homeTeam, d.game.awayTeam);
        })
        .catch(function() {});
    }

    socket.on('game:active', function(data) {
      if (autoState === 'waiting') enterLive(data.scheduleID, data.homeTeam, data.awayTeam);
    });
    socket.on('game:ended', function(data) {
      if (autoState === 'live' && String(data.scheduleID) === activeGameID) enterGameOver();
    });
    socket.on('clock:update', function(data) {
      if (autoState === 'live') applyClockState(data);
    });
    socket.on('score:update', function(data) {
      if (autoState !== 'live') return;
      if (data.homeScore !== undefined) document.getElementById('homeScore').textContent = data.homeScore !== null ? data.homeScore : 0;
      if (data.awayScore !== undefined) document.getElementById('awayScore').textContent = data.awayScore !== null ? data.awayScore : 0;
      if (data.status) {
        var badge = document.getElementById('status-badge');
        badge.textContent = data.status.toUpperCase();
        badge.className   = data.status === 'live' ? 'live' : '';
        if (data.status === 'final') enterGameOver();
      }
    });
    socket.on('fouls:update', function(data) { if (autoState === 'live') applyFoulData(data); });
    socket.on('timeouts:update', function(data) { if (autoState === 'live') applyTimeoutData(data); });
    socket.on('subhorn', function() { if (autoState === 'live') playBuzzer('sub'); });

    enterWaiting();
  }
</script>

</body>
</html>
