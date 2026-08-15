// Playoff Schedule Import - Client-side parser

// Colors for bracket badges
var BRACKET_COLORS = [
  '#1976d2','#388e3c','#e64a19','#7b1fa2',
  '#0097a7','#f57c00','#c62828','#00796b'
];

var parsedGames = [];
var bracketColorMap = {};
var bracketColorIdx = 0;
var teamNameMap = {}; // rawName.toLowerCase() → { teamID, teamName } (manual overrides)
var bracketFormatMap = {}; // bracket name → 'single' | 'double_elim_7', default 'single'
var manualBrackets = []; // bracket names declared via the "Add Bracket" field, merged into allBrackets at render time

// ── Fuzzy Matching ────────────────────────────────────────────────────────────

function normalizeTeamName(name) {
  if (!name) return '';
  return name
    .replace(/\s*\([^)]*\)\s*/g, '')
    .replace(/[''`']/g, '') // Strip apostrophes so "N'" matches "N"
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}

var abbreviationMap = {
  nw: 'northwest', ne: 'northeast', sw: 'southwest', se: 'southeast',
  n: 'north', s: 'south', e: 'east', w: 'west',
  st: 'saint', mt: 'mount', jr: 'junior', sr: 'senior'
};

function expandAbbreviations(name) {
  if (!name) return '';
  return name.toLowerCase().trim().split(/\s+/).map(function(w) {
    return abbreviationMap[w] || w;
  }).join(' ');
}

function similarityScore(a, b) {
  if (!a || !b) return 0;
  a = a.toLowerCase();
  b = b.toLowerCase();
  if (a === b) return 1;
  var expandedA = expandAbbreviations(a);
  var expandedB = expandAbbreviations(b);
  if (expandedA === expandedB) return 0.95;
  var wordsA = expandedA.split(/\s+/);
  var wordsB = expandedB.split(/\s+/);
  var matchCount = 0;
  wordsA.forEach(function(wa) {
    wordsB.forEach(function(wb) {
      if (wa === wb) matchCount++;
      else if (wa.length >= 3 && wb.length >= 3) {
        if (wb.indexOf(wa) === 0 || wa.indexOf(wb) === 0) matchCount += 0.7;
        // Near-miss: words share all but last char (e.g. "bones"/"bonez")
        else if (wa.length >= 4 && wb.length >= 4) {
          var shorter = Math.min(wa.length, wb.length);
          if (wa.substring(0, shorter - 1) === wb.substring(0, shorter - 1)) matchCount += 0.85;
        }
      }
    });
  });
  var maxWords = Math.max(wordsA.length, wordsB.length);
  var wordScore = matchCount / maxWords;
  var lenRatio = Math.min(expandedA.length, expandedB.length) / Math.max(expandedA.length, expandedB.length);
  if (lenRatio >= 0.4 && (expandedA.indexOf(expandedB) > -1 || expandedB.indexOf(expandedA) > -1)) {
    wordScore = Math.max(wordScore, 0.6 + lenRatio * 0.3);
  }
  return wordScore;
}

function findSuggestion(teamName) {
  if (!teamName) return null;
  var bestScore = 0;
  var bestMatch = null;
  var threshold = 0.5;
  var normalizedInput = normalizeTeamName(teamName);
  for (var key in teamLookup) {
    var score = similarityScore(normalizedInput, normalizeTeamName(key));
    if (score > bestScore) { bestScore = score; bestMatch = teamLookup[key]; }
  }
  return (bestScore >= threshold && bestMatch) ? { team: bestMatch, score: bestScore } : null;
}

function getBracketColor(name) {
  if (!bracketColorMap[name]) {
    bracketColorMap[name] = BRACKET_COLORS[bracketColorIdx % BRACKET_COLORS.length];
    bracketColorIdx++;
  }
  return bracketColorMap[name];
}

// ── Parsing ──────────────────────────────────────────────────────────────────

function parseSchedule() {
  var text = document.getElementById('pasteArea').value;
  if (!text.trim()) { alert('Please paste a schedule first.'); return; }

  parsedGames = [];
  bracketColorMap = {};
  bracketColorIdx = 0;
  bracketFormatMap = {};

  var lines = text.split(/\r?\n/);
  var currentDate = '';
  var currentRoundName = '';
  var currentRoundOrder = 1;        // within the current bracket context
  var currentBracket = '';

  // First pass: collect all bracket names from division-championship lines
  // e.g. "East Division Championship" → "East Division"
  var detectedBrackets = [];
  var bracketSet = {};
  lines.forEach(function(line) {
    line = line.trim();
    var champMatch = line.match(/^([\w\s']+?)\s+(championship|champions)/i);
    if (champMatch) {
      var bn = normalizeBracketName(champMatch[1].trim());
      if (bn && !bracketSet[bn.toLowerCase()]) {
        bracketSet[bn.toLowerCase()] = true;
        detectedBrackets.push(bn);
      }
    }
    // Also detect "West Division", "East Division", "Premier Division" headers
    var divMatch = line.match(/^([\w\s']+?\s+(?:division|playoffs?))\s*$/i);
    if (divMatch && !isGameLine(line) && !isDateLine(line)) {
      var bn = normalizeBracketName(divMatch[1].trim());
      if (bn && !bracketSet[bn.toLowerCase()]) {
        bracketSet[bn.toLowerCase()] = true;
        detectedBrackets.push(bn);
      }
    }
  });

  // Round order tracker per bracket context (reset when bracket changes)
  var roundOrderByBracketRound = {}; // key: bracketKey+"::"+roundName → roundID

  function getRoundID(bracketName, roundName) {
    var key = (bracketName || '').toLowerCase() + '::' + roundName.toLowerCase();
    if (!roundOrderByBracketRound[key]) {
      // Count distinct rounds for this bracket so far
      var prefix = (bracketName || '').toLowerCase() + '::';
      var existing = Object.keys(roundOrderByBracketRound).filter(function(k) {
        return k.indexOf(prefix) === 0;
      });
      roundOrderByBracketRound[key] = existing.length + 1;
    }
    return roundOrderByBracketRound[key];
  }

  // Second pass: parse games
  lines.forEach(function(line) {
    line = line.trim();
    if (!line) return;

    // Date line — may also contain round name in parens
    if (isDateLine(line)) {
      var parsed = parseDateLine(line);
      currentDate = parsed.date;
      if (parsed.roundName) {
        currentRoundName = parsed.roundName;
      }
      return;
    }

    // Round header (no time, no date, looks like "Semi-Finals", "Play-In Tournament")
    if (isRoundHeader(line)) {
      currentRoundName = line;
      return;
    }

    // Division header
    if (isDivisionHeader(line)) {
      currentBracket = normalizeBracketName(line);
      return;
    }

    // Game line
    if (isGameLine(line)) {
      var game = parseGameLine(line);
      if (!game) return;

      game.date = currentDate;
      game.roundName = currentRoundName || 'Round';
      game.suggestedBracket = currentBracket;
      game.bracketRoundID = getRoundID(currentBracket, game.roundName);

      // Try to infer bracket from championship placeholder text
      if (game.isPlaceholder && !game.suggestedBracket) {
        var champMatch = game.rawText.match(/^([\w\s']+?)\s+championship/i);
        if (champMatch) {
          var inferred = normalizeBracketName(champMatch[1].trim());
          if (inferred) game.suggestedBracket = inferred;
        }
      }

      // Team lookup — skip placeholder sides (e.g. "Winner Game 1", "Loser Game 2")
      game.homeTeamID = game.homeIsPlaceholder ? null : lookupTeam(game.homeTeamRaw);
      game.awayTeamID = game.awayIsPlaceholder ? null : lookupTeam(game.awayTeamRaw);

      parsedGames.push(game);
    }
  });

  if (!parsedGames.length) {
    alert('No games found. Check the format and try again.');
    return;
  }

  renderPreview(detectedBrackets);
}

// Wraps parseSchedule() to also auto-assign every parsed game to the
// "Bracket for this schedule" field, when filled in — used by both the
// Parse & Preview button and the image-upload handler.
function parseScheduleAndAssignBracket() {
  parseSchedule();
  var bracketField = document.getElementById('uploadBracketName');
  var bracketName = bracketField ? bracketField.value.trim() : '';
  if (bracketName) applyBracketToAllParsedGames(bracketName);
}

function applyBracketToAllParsedGames(bracketName) {
  if (!bracketName || !parsedGames.length) return;
  addManualBracket(bracketName);
  parsedGames.forEach(function(g) { g._bracket = bracketName; });
  document.querySelectorAll('select.bracket-select').forEach(function(sel) {
    sel.value = bracketName;
  });
  buildImportSummary();
}

function isDateLine(line) {
  return /\b(sunday|monday|tuesday|wednesday|thursday|friday|saturday)\b/i.test(line) ||
         /\b(january|february|march|april|may|june|july|august|september|october|november|december)\b/i.test(line);
}

function isRoundHeader(line) {
  if (isDateLine(line) || isGameLine(line)) return false;
  return /\b(semi.?finals?|play.?in|quarter.?finals?|championships?|finals?)\b/i.test(line);
}

function isDivisionHeader(line) {
  if (isDateLine(line) || isGameLine(line) || isRoundHeader(line)) return false;
  return /\b(division|playoffs?)\b/i.test(line) && line.length < 60;
}

function isGameLine(line) {
  return /^\d{1,2}:\d{2}\s*(AM|PM)/i.test(line);
}

function parseDateLine(line) {
  var roundName = '';
  var parenMatch = line.match(/\(([^)]+)\)/);
  if (parenMatch) roundName = parenMatch[1].trim();

  // Try to parse a date — look for month + day
  var months = {
    january:0, february:1, march:2, april:3, may:4, june:5,
    july:6, august:7, september:8, october:9, november:10, december:11
  };
  var dateStr = '';
  var monthMatch = line.match(/\b(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{1,2})(?:st|nd|rd|th)?/i);
  if (monthMatch) {
    var month = months[monthMatch[1].toLowerCase()];
    var day = parseInt(monthMatch[2]);
    var year = new Date().getFullYear();
    dateStr = year + '-' + pad(month+1) + '-' + pad(day);
  }

  return { date: dateStr, roundName: roundName };
}

function parseGameLine(line) {
  // Time: 10:30AM or 10:30 AM
  var timeMatch = line.match(/^(\d{1,2}:\d{2})\s*(AM|PM)/i);
  if (!timeMatch) return null;

  var rawTime = timeMatch[1];
  var ampm = timeMatch[2].toUpperCase();
  var startTime = convertTo24(rawTime, ampm);

  // Strip the time portion
  var rest = line.replace(/^\d{1,2}:\d{2}\s*(AM|PM)\s*[-–—]?\s*/i, '').trim();

  var game = {
    startTime: startTime,
    rawText: rest,
    homeSeed: null,
    awaySeed: null,
    homeTeamRaw: '',
    awayTeamRaw: '',
    homeTeamID: null,
    awayTeamID: null,
    isPlaceholder: false,      // true only when BOTH sides are placeholders (or no "vs" at all)
    homeIsPlaceholder: false,
    awayIsPlaceholder: false
  };

  // Check for "vs" — actual matchup
  var vsIdx = rest.search(/\bvs\.?\b/i);
  if (vsIdx === -1) {
    // Whole-line placeholder (e.g. "East Division Championship")
    game.isPlaceholder = true;
    game.homeIsPlaceholder = true;
    game.awayIsPlaceholder = true;
    game.homeTeamRaw = rest;
    return game;
  }

  var homePart = rest.substring(0, vsIdx).trim();
  var awayPart = rest.substring(vsIdx).replace(/^vs\.?\s*/i, '').trim();

  var homeParsed = parseTeamPart(homePart);
  var awayParsed = parseTeamPart(awayPart);

  game.homeSeed = homeParsed.seed;
  game.homeTeamRaw = homeParsed.name;
  game.awaySeed = awayParsed.seed;
  game.awayTeamRaw = awayParsed.name;

  // Per-side placeholder detection — handles mixed lines like "#1 3 DRIBBLES vs WINNER GAME 1"
  // as well as pure-placeholder lines like "LOSER GAME 1 vs LOSER GAME 2"
  game.homeIsPlaceholder = isPlaceholderText(homeParsed.name);
  game.awayIsPlaceholder = isPlaceholderText(awayParsed.name);
  game.isPlaceholder = game.homeIsPlaceholder && game.awayIsPlaceholder;

  return game;
}

// Matches "Winner (2/7)", "Winner Game 1", "Loser Game 2", and bare "Game 8"
// (the WINNER/LOSER prefix is sometimes dropped by OCR) — case-insensitive
function isPlaceholderText(str) {
  if (!str) return false;
  str = str.trim();
  return /^(winner|loser)\s*\(/i.test(str) ||
         /^(?:winner|loser)?\s*game\s*\d+$/i.test(str);
}

function parseTeamPart(str) {
  // Extract leading seed: (N) or #N
  var seedMatch = str.match(/^(?:\((\d+)\)|#(\d+))\s*/);
  var seed = null;
  var name = str;
  if (seedMatch) {
    seed = parseInt(seedMatch[1] || seedMatch[2]);
    name = str.substring(seedMatch[0].length).trim();
  }
  return { seed: seed, name: name };
}

function normalizeBracketName(str) {
  // Capitalize each word
  return str.replace(/\w\S*/g, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1);
  }).trim();
}

function convertTo24(time, ampm) {
  var parts = time.split(':');
  var h = parseInt(parts[0]);
  var m = parts[1];
  if (ampm === 'PM' && h !== 12) h += 12;
  if (ampm === 'AM' && h === 12) h = 0;
  return pad(h) + ':' + m + ':00';
}

function pad(n) { return n < 10 ? '0' + n : '' + n; }

function lookupTeam(name) {
  if (!name) return null;
  var key = name.toLowerCase().trim();

  // Manual override (from "Use This" suggestion)
  if (teamNameMap[key]) return teamNameMap[key].teamID;

  // Exact match
  if (teamLookup[key]) return teamLookup[key].teamID;

  // Normalized match (strips parenthetical content)
  var normalizedInput = normalizeTeamName(name);
  for (var k in teamLookup) {
    if (normalizeTeamName(k) === normalizedInput) return teamLookup[k].teamID;
  }

  // Partial substring match
  var keys = Object.keys(teamLookup);
  for (var i = 0; i < keys.length; i++) {
    if (keys[i].indexOf(key) !== -1 || key.indexOf(keys[i]) !== -1) {
      return teamLookup[keys[i]].teamID;
    }
  }

  // Fuzzy match (abbreviation-aware)
  var suggestion = findSuggestion(name);
  if (suggestion && suggestion.score >= 0.8) return suggestion.team.teamID;

  return null;
}

function getTeamName(id) {
  var keys = Object.keys(teamLookup);
  for (var i = 0; i < keys.length; i++) {
    if (teamLookup[keys[i]].teamID == id) return teamLookup[keys[i]].teamName;
  }
  return null;
}

// ── Rendering ─────────────────────────────────────────────────────────────────

function renderPreview(detectedBrackets) {
  var tbody = document.getElementById('previewBody');
  tbody.innerHTML = '';

  // Collect all bracket names currently assigned + detected
  var allBrackets = detectedBrackets.slice();
  parsedGames.forEach(function(g) {
    if (g.suggestedBracket && allBrackets.indexOf(g.suggestedBracket) === -1) {
      allBrackets.push(g.suggestedBracket);
    }
  });
  manualBrackets.forEach(function(name) {
    if (allBrackets.indexOf(name) === -1) allBrackets.push(name);
  });

  var unknownTeams = {};

  parsedGames.forEach(function(g, idx) {
    var tr = document.createElement('tr');
    if ((!g.homeTeamID && !g.homeIsPlaceholder) || (!g.awayTeamID && !g.awayIsPlaceholder)) tr.classList.add('warning-row');

    // Assigned bracket for this game (mutable)
    g._bracket = g.suggestedBracket || '';

    // Home cell
    var homeCell = renderTeamCell(g.homeTeamRaw, g.homeTeamID, g.homeSeed, g.homeIsPlaceholder);
    var awayCell = renderTeamCell(g.awayTeamRaw, g.awayTeamID, g.awaySeed, g.awayIsPlaceholder);

    if (!g.homeIsPlaceholder && !g.homeTeamID && g.homeTeamRaw) unknownTeams[g.homeTeamRaw] = true;
    if (!g.awayIsPlaceholder && !g.awayTeamID && g.awayTeamRaw) unknownTeams[g.awayTeamRaw] = true;

    // Bracket dropdown
    var bracketSelect = buildBracketSelect(allBrackets, g._bracket, idx);

    tr.innerHTML = '<td>' + (idx+1) + '</td>' +
      '<td><span class="round-badge">' + escHtml(g.roundName) + '</span></td>' +
      '<td style="white-space:nowrap">' + escHtml(g.date || '-') + '</td>' +
      '<td style="white-space:nowrap">' + formatTime(g.startTime) + '</td>' +
      '<td>' + homeCell + '</td>' +
      '<td>' + awayCell + '</td>' +
      '<td></td>';

    tr.cells[6].appendChild(bracketSelect);
    tbody.appendChild(tr);
  });

  // Unknown teams alert
  var unknownKeys = Object.keys(unknownTeams);
  var alertEl = document.getElementById('unknownTeamsAlert');
  var list = document.getElementById('unknownTeamsList');
  if (unknownKeys.length) {
    var listHtml = '<ul style="margin:8px 0 0; padding-left:18px;">';
    unknownKeys.forEach(function(rawName) {
      var suggestion = findSuggestion(rawName);
      listHtml += '<li><strong>' + escHtml(rawName) + '</strong>';
      if (suggestion) {
        var safeRaw = rawName.replace(/'/g, "\\'").replace(/"/g, '&quot;');
        var safeSug = suggestion.team.teamName.replace(/'/g, "\\'").replace(/"/g, '&quot;');
        listHtml += ' &mdash; did you mean <strong>' + escHtml(suggestion.team.teamName) + '</strong>?' +
          ' <button type="button" class="btn btn-primary btn-sm" style="padding:1px 8px; font-size:11px;"' +
          ' onclick="useSuggestedTeam(\'' + safeRaw + '\', ' + suggestion.team.teamID + ', \'' + safeSug + '\')">' +
          'Use This</button>';
      }
      listHtml += '</li>';
    });
    listHtml += '</ul>';
    list.innerHTML = listHtml;
    alertEl.style.display = '';
  } else {
    alertEl.style.display = 'none';
  }

  updateMatchSummary();
  document.getElementById('previewCard').style.display = '';
  document.getElementById('confirmCard').style.display = '';
  buildImportSummary();
}

function renderTeamCell(raw, id, seed, isPlaceholder) {
  if (isPlaceholder) return '<span class="team-placeholder">' + escHtml(raw) + '</span>';
  var seedStr = seed != null ? '<strong>(#' + seed + ')</strong> ' : '';
  if (id) {
    return seedStr + '<span class="team-match">' + escHtml(raw) + '</span>';
  } else {
    return seedStr + '<span class="team-nomatch">' + escHtml(raw) + '</span>';
  }
}

function buildBracketSelect(allBrackets, current, gameIdx) {
  var sel = document.createElement('select');
  sel.className = 'form-control bracket-select';
  sel.dataset.gameIdx = gameIdx;
  sel.addEventListener('change', function() {
    var val = this.value;
    if (val === '__new__') {
      var name = prompt('Enter new bracket name:');
      if (name && name.trim()) {
        name = name.trim();
        // Add to all selects
        addBracketOptionToAll(name);
        this.value = name;
        parsedGames[gameIdx]._bracket = name;
      } else {
        this.value = parsedGames[gameIdx]._bracket || '';
      }
    } else {
      parsedGames[gameIdx]._bracket = val;
    }
    buildImportSummary();
  });

  var emptyOpt = document.createElement('option');
  emptyOpt.value = '';
  emptyOpt.textContent = '-- Unassigned --';
  sel.appendChild(emptyOpt);

  allBrackets.forEach(function(b) {
    var opt = document.createElement('option');
    opt.value = b;
    opt.textContent = b;
    if (b === current) opt.selected = true;
    sel.appendChild(opt);
  });

  var newOpt = document.createElement('option');
  newOpt.value = '__new__';
  newOpt.textContent = 'New bracket…';
  sel.appendChild(newOpt);

  return sel;
}

// ── Persistence (localStorage, scoped per season — mirrors scheduleImport.js's
// sync-summary pattern; nothing here touches the DB until actual Import) ──────

function getPlayoffStorageKey() {
  return 'playoffImport_season_' + currentSeasonID;
}

function savePlayoffImportState() {
  try {
    var bracketField = document.getElementById('uploadBracketName');
    localStorage.setItem(getPlayoffStorageKey(), JSON.stringify({
      manualBrackets: manualBrackets,
      lastBracketField: bracketField ? bracketField.value : ''
    }));
  } catch (e) { /* localStorage unavailable — degrade silently */ }
}

function loadPlayoffImportState() {
  try {
    var raw = localStorage.getItem(getPlayoffStorageKey());
    if (!raw) return;
    var data = JSON.parse(raw);
    if (data.manualBrackets && data.manualBrackets.length) {
      manualBrackets = data.manualBrackets;
      manualBrackets.forEach(function(name) {
        if (!(name in bracketFormatMap)) bracketFormatMap[name] = 'single';
      });
      renderManualBracketsList();
    }
    if (data.lastBracketField) {
      var bracketField = document.getElementById('uploadBracketName');
      if (bracketField) bracketField.value = data.lastBracketField;
    }
  } catch (e) { /* corrupt/unavailable storage — start fresh */ }
}

function addManualBracket(name) {
  name = (name || '').trim();
  if (!name) return;
  if (manualBrackets.indexOf(name) === -1) manualBrackets.push(name);
  if (!(name in bracketFormatMap)) bracketFormatMap[name] = 'single';
  addBracketOptionToAll(name);
  renderManualBracketsList();
  savePlayoffImportState();
}

function renderManualBracketsList() {
  var container = document.getElementById('manualBracketsList');
  if (!container) return;
  container.innerHTML = '';
  manualBrackets.forEach(function(name) {
    var badge = document.createElement('span');
    badge.className = 'bracket-badge';
    badge.style.background = getBracketColor(name);
    badge.style.marginRight = '6px';
    badge.style.marginBottom = '6px';
    badge.style.display = 'inline-block';
    badge.textContent = name;
    container.appendChild(badge);
  });
}

function addBracketOptionToAll(name) {
  var selects = document.querySelectorAll('select.bracket-select');
  selects.forEach(function(sel) {
    // Check if already exists
    var exists = false;
    for (var i = 0; i < sel.options.length; i++) {
      if (sel.options[i].value === name) { exists = true; break; }
    }
    if (!exists) {
      var opt = document.createElement('option');
      opt.value = name;
      opt.textContent = name;
      // Insert before "New bracket…"
      sel.insertBefore(opt, sel.lastElementChild);
    }
  });
}

function updateMatchSummary() {
  var matched = 0, total = 0;
  parsedGames.forEach(function(g) {
    if (!g.homeIsPlaceholder && g.homeTeamRaw) { total++; if (g.homeTeamID) matched++; }
    if (!g.awayIsPlaceholder && g.awayTeamRaw) { total++; if (g.awayTeamID) matched++; }
  });
  document.getElementById('matchSummary').textContent = matched + '/' + total + ' teams matched';
}

function buildImportSummary() {
  // Group games by bracket
  var bracketGroups = {};
  var unassigned = 0;

  parsedGames.forEach(function(g) {
    var b = g._bracket;
    if (!b) { unassigned++; return; }
    if (!bracketGroups[b]) bracketGroups[b] = [];
    bracketGroups[b].push(g);
  });

  var keys = Object.keys(bracketGroups);
  var formatMismatch = false;
  var html = '<ul style="margin:0; padding-left:18px; list-style:none;">';
  keys.forEach(function(b) {
    var color = getBracketColor(b);
    if (!(b in bracketFormatMap)) bracketFormatMap[b] = 'single';
    var count = bracketGroups[b].length;
    var isDouble = bracketFormatMap[b] === 'double_elim_7';
    html += '<li style="margin-bottom:4px;">' +
      '<span class="bracket-badge" style="background:' + color + '">' + escHtml(b) + '</span> ' +
      count + ' game(s) ' +
      '<select class="form-control bracket-format-select" data-bracket="' + escHtml(b) + '" style="width:auto; display:inline-block; font-size:12px; margin-left:6px;">' +
        '<option value="single"' + (isDouble ? '' : ' selected') + '>Single-Elim</option>' +
        '<option value="double_elim_7"' + (isDouble ? ' selected' : '') + '>Double-Elim (7-Team)</option>' +
      '</select>';
    if (isDouble && count !== 12) {
      formatMismatch = true;
      html += ' <span class="text-danger" style="font-size:12px;">&mdash; needs exactly 12 games (has ' + count + ')</span>';
    }
    html += '</li>';
  });
  html += '</ul>';

  if (unassigned) {
    html += '<p class="text-warning" style="margin-top:6px;"><strong>' + unassigned + ' game(s) unassigned</strong> - assign a bracket to all games before importing.</p>';
  }

  document.getElementById('importSummary').innerHTML = html;

  document.querySelectorAll('.bracket-format-select').forEach(function(sel) {
    sel.addEventListener('change', function() {
      bracketFormatMap[this.dataset.bracket] = this.value;
      buildImportSummary();
    });
  });

  var importBtn = document.getElementById('importBtn');
  importBtn.disabled = unassigned > 0 || keys.length === 0 || formatMismatch;
}

// ── Form Submission ───────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', function() {
  loadPlayoffImportState();

  document.getElementById('uploadBracketName').addEventListener('change', savePlayoffImportState);

  document.getElementById('importForm').addEventListener('submit', function(e) {
    e.preventDefault();
    if (!confirm('This will delete ALL existing playoff data for this season and replace it. Continue?')) return;

    var payload = buildPayload();
    document.getElementById('formImportData').value = JSON.stringify(payload);
    this.submit();
  });

  document.getElementById('addBracketBtn').addEventListener('click', function() {
    var input = document.getElementById('newBracketNameInput');
    addManualBracket(input.value);
    input.value = '';
    input.focus();
  });

  document.getElementById('newBracketNameInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      document.getElementById('addBracketBtn').click();
    }
  });

  document.getElementById('uploadPlayoffImageBtn').addEventListener('click', function() {
    document.getElementById('playoffImageInput').click();
  });

  document.getElementById('playoffImageInput').addEventListener('change', function() {
    var file = this.files[0];
    if (!file) return;

    var status = document.getElementById('imageParseStatus');
    status.textContent = 'Extracting schedule...';

    var reader = new FileReader();
    reader.onload = function(e) {
      var base64 = e.target.result.split(',')[1];

      fetch('/admin-dashboard/pages/playoffs/parsePlayoffImage.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ image: base64 })
      })
      .then(function(res) {
        return res.text().then(function(text) {
          var start = text.indexOf('{');
          var end = text.lastIndexOf('}');
          if (start === -1 || end === -1) throw new Error('No JSON found in response: ' + text.substring(0, 300));
          try {
            return JSON.parse(text.substring(start, end + 1));
          } catch (e) {
            throw new Error('JSON parse failed: ' + e.message);
          }
        });
      })
      .then(function(data) {
        if (data.text) {
          document.getElementById('pasteArea').value = data.text;
          parseScheduleAndAssignBracket();
          var bracketField = document.getElementById('uploadBracketName');
          status.textContent = (bracketField && bracketField.value.trim())
            ? 'Extracted and assigned to "' + bracketField.value.trim() + '".'
            : 'Extracted — review before parsing.';
        } else {
          status.textContent = 'Error: ' + (data.error || 'Unknown error');
          console.error('parsePlayoffImage API error:', data);
        }
      })
      .catch(function(err) {
        status.textContent = 'Request failed: ' + err;
        console.error('parsePlayoffImage error:', err);
      });
    };
    reader.readAsDataURL(file);
  });
});

function buildPayload() {
  // Group games by bracket name, preserve order
  var bracketOrder = [];
  var bracketMap = {};

  parsedGames.forEach(function(g) {
    var b = g._bracket;
    if (!bracketMap[b]) {
      bracketMap[b] = [];
      bracketOrder.push(b);
    }
    bracketMap[b].push(g);
  });

  // Assign BracketRoundID per bracket (re-sequence based on roundName order)
  var brackets = bracketOrder.map(function(name) {
    var games = bracketMap[name];

    // Map roundName → roundID in order of first appearance
    var roundMap = {};
    var roundCounter = 1;
    games.forEach(function(g) {
      var key = g.roundName.toLowerCase();
      if (!roundMap[key]) {
        roundMap[key] = roundCounter++;
      }
    });

    var gameID = 1;
    var formattedGames = games.map(function(g) {
      var fg = {
        bracketGameID: gameID++,
        bracketRoundID: roundMap[g.roundName.toLowerCase()],
        date: g.date || '',
        startTime: g.startTime || '',
        homeSeed: g.homeSeed,
        awaySeed: g.awaySeed,
        homeTeamID: g.homeTeamID || 0,
        awayTeamID: g.awayTeamID || 0,
        homeTeamRaw: g.homeTeamRaw,
        awayTeamRaw: g.awayTeamRaw,
        isPlaceholder: g.isPlaceholder
      };
      return fg;
    });

    return { name: name, games: formattedGames, format: bracketFormatMap[name] || 'single' };
  });

  return { brackets: brackets };
}

function useSuggestedTeam(rawName, teamID, teamName) {
  var key = rawName.toLowerCase().trim();
  teamNameMap[key] = { teamID: teamID, teamName: teamName };
  // Update all parsed games that reference this raw name
  parsedGames.forEach(function(g) {
    if (g.homeTeamRaw && g.homeTeamRaw.toLowerCase().trim() === key) g.homeTeamID = teamID;
    if (g.awayTeamRaw && g.awayTeamRaw.toLowerCase().trim() === key) g.awayTeamID = teamID;
  });
  // Re-render with current bracket state preserved
  var selects = document.querySelectorAll('select.bracket-select');
  var savedBrackets = {};
  selects.forEach(function(sel) { savedBrackets[sel.dataset.gameIdx] = sel.value; });
  var detectedBrackets = [];
  var bracketSet = {};
  parsedGames.forEach(function(g) {
    if (g.suggestedBracket && !bracketSet[g.suggestedBracket.toLowerCase()]) {
      bracketSet[g.suggestedBracket.toLowerCase()] = true;
      detectedBrackets.push(g.suggestedBracket);
    }
    if (g._bracket && !bracketSet[g._bracket.toLowerCase()]) {
      bracketSet[g._bracket.toLowerCase()] = true;
      detectedBrackets.push(g._bracket);
    }
  });
  renderPreview(detectedBrackets);
  // Restore bracket selections — both the visible dropdown AND the underlying
  // model, which renderPreview() just reset to suggestedBracket-or-blank
  document.querySelectorAll('select.bracket-select').forEach(function(sel) {
    var saved = savedBrackets[sel.dataset.gameIdx];
    if (saved) {
      sel.value = saved;
      parsedGames[sel.dataset.gameIdx]._bracket = saved;
    }
  });
  buildImportSummary();
}

function resetImport() {
  document.getElementById('pasteArea').value = '';
  document.getElementById('previewBody').innerHTML = '';
  document.getElementById('previewCard').style.display = 'none';
  document.getElementById('confirmCard').style.display = 'none';
  parsedGames = [];
  bracketColorMap = {};
  bracketColorIdx = 0;
  teamNameMap = {};
  bracketFormatMap = {};
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function formatTime(t) {
  if (!t) return '-';
  var parts = t.split(':');
  var h = parseInt(parts[0]);
  var m = parts[1];
  var ampm = h >= 12 ? 'PM' : 'AM';
  if (h > 12) h -= 12;
  if (h === 0) h = 12;
  return h + ':' + m + ' ' + ampm;
}
