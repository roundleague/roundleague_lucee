// Playoff Schedule Import - Client-side parser
// One upload = one bracket + a starting round number (picked in Step 0).
// Bracket/round are fixed for the whole batch; the parser only extracts matchups.

var parsedGames = [];
var teamNameMap = {}; // rawName.toLowerCase() → { teamID, teamName } (manual overrides)

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

// ── Step 0: Bracket & Round picker ─────────────────────────────────────────────

function onBracketSelectChange() {
  var sel = document.getElementById('bracketSelect');
  var newBracketRow = document.getElementById('newBracketRow');
  var roundInput = document.getElementById('roundNumberInput');

  if (sel.value === '__new__') {
    newBracketRow.style.display = '';
    roundInput.value = 1;
  } else {
    newBracketRow.style.display = 'none';
    var maxRound = bracketMaxRound[sel.value] || 0;
    roundInput.value = maxRound + 1;
  }
}

function getSelectedBracket() {
  var sel = document.getElementById('bracketSelect');
  if (sel.value === '__new__') {
    var name = document.getElementById('newBracketName').value.trim();
    return { bracketID: null, bracketName: name };
  }
  return { bracketID: parseInt(sel.value), bracketName: null };
}

// ── Image Upload ────────────────────────────────────────────────────────────────

function uploadPlayoffImage(input) {
  var file = input.files[0];
  if (!file) return;

  var status = document.getElementById('uploadStatus');
  status.textContent = 'Reading image...';

  var reader = new FileReader();
  reader.onload = function(e) {
    var base64 = e.target.result.split(',')[1];
    status.textContent = 'Parsing image with AI...';

    fetch('parsePlayoffScheduleImage.cfm', {
      method: 'POST',
      body: JSON.stringify({ image: base64 })
    })
      .then(function(res) { return res.json(); })
      .then(function(data) {
        if (data.error) {
          status.textContent = 'Error: ' + data.error;
          return;
        }
        document.getElementById('pasteArea').value = data.schedule || '';
        status.textContent = 'Image parsed — review the text below, then click Parse & Preview.';
        parseSchedule();
      })
      .catch(function(err) {
        status.textContent = 'Error: ' + err.message;
      });
  };
  reader.readAsDataURL(file);
}

// ── Parsing ──────────────────────────────────────────────────────────────────

function parseSchedule() {
  var text = document.getElementById('pasteArea').value;
  if (!text.trim()) { alert('Please paste or upload a schedule first.'); return; }

  var bracket = getSelectedBracket();
  if (bracket.bracketID === null && !bracket.bracketName) {
    alert('Enter a name for the new bracket first.');
    return;
  }

  var startRound = parseInt(document.getElementById('roundNumberInput').value) || 1;

  parsedGames = [];

  var lines = text.split(/\r?\n/);
  var currentDate = '';
  var currentRoundName = '';

  // Round order tracker — first distinct round name seen gets startRound,
  // each subsequent distinct round name increments from there.
  var roundOrderByName = {};
  var nextRoundCounter = startRound;

  function getRoundID(roundName) {
    var key = (roundName || '').toLowerCase();
    if (!roundOrderByName[key]) {
      roundOrderByName[key] = nextRoundCounter++;
    }
    return roundOrderByName[key];
  }

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

    // Game line
    if (isGameLine(line)) {
      var game = parseGameLine(line);
      if (!game) return;

      game.date = currentDate;
      game.roundName = currentRoundName || 'Round ' + startRound;
      game.bracketRoundID = getRoundID(game.roundName);

      // Team lookup
      game.homeTeamID = lookupTeam(game.homeTeamRaw);
      game.awayTeamID = lookupTeam(game.awayTeamRaw);

      parsedGames.push(game);
    }
  });

  if (!parsedGames.length) {
    alert('No games found. Check the format and try again.');
    return;
  }

  renderPreview();
}

function isDateLine(line) {
  return /\b(sunday|monday|tuesday|wednesday|thursday|friday|saturday)\b/i.test(line) ||
         /\b(january|february|march|april|may|june|july|august|september|october|november|december)\b/i.test(line);
}

function isRoundHeader(line) {
  if (isDateLine(line) || isGameLine(line)) return false;
  return /\b(semi.?finals?|play.?in|quarter.?finals?|championships?|finals?)\b/i.test(line);
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
    isPlaceholder: false
  };

  // Check for "vs" — actual matchup
  var vsIdx = rest.search(/\bvs\.?\b/i);
  if (vsIdx === -1) {
    // Placeholder (e.g. "East Division Championship", "Winner (2/7) vs Winner (3/6)" shouldn't hit this)
    game.isPlaceholder = true;
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

  // If both sides are "Winner (x/y)" style, treat as placeholder
  if (/^winner\s*\(/i.test(homeParsed.name) && /^winner\s*\(/i.test(awayParsed.name)) {
    game.isPlaceholder = true;
  }

  return game;
}

function parseTeamPart(str) {
  // Extract leading seed: (N)
  var seedMatch = str.match(/^\((\d+)\)\s*/);
  var seed = null;
  var name = str;
  if (seedMatch) {
    seed = parseInt(seedMatch[1]);
    name = str.substring(seedMatch[0].length).trim();
  }
  return { seed: seed, name: name };
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

function renderPreview() {
  var tbody = document.getElementById('previewBody');
  tbody.innerHTML = '';

  var unknownTeams = {};

  parsedGames.forEach(function(g, idx) {
    var tr = document.createElement('tr');
    if (!g.homeTeamID && !g.isPlaceholder) tr.classList.add('warning-row');

    var homeCell = renderTeamCell(g.homeTeamRaw, g.homeTeamID, g.homeSeed, g.isPlaceholder);
    var awayCell = renderTeamCell(g.awayTeamRaw, g.awayTeamID, g.awaySeed, g.isPlaceholder);

    if (!g.isPlaceholder) {
      if (!g.homeTeamID && g.homeTeamRaw) unknownTeams[g.homeTeamRaw] = true;
      if (!g.awayTeamID && g.awayTeamRaw) unknownTeams[g.awayTeamRaw] = true;
    }

    tr.innerHTML = '<td>' + (idx+1) + '</td>' +
      '<td><span class="round-badge">Round ' + g.bracketRoundID + ' &mdash; ' + escHtml(g.roundName) + '</span></td>' +
      '<td style="white-space:nowrap">' + escHtml(g.date || '-') + '</td>' +
      '<td style="white-space:nowrap">' + formatTime(g.startTime) + '</td>' +
      '<td>' + homeCell + '</td>' +
      '<td>' + awayCell + '</td>';

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

function updateMatchSummary() {
  var matched = 0, total = 0;
  parsedGames.forEach(function(g) {
    if (!g.isPlaceholder) {
      if (g.homeTeamRaw) { total++; if (g.homeTeamID) matched++; }
      if (g.awayTeamRaw) { total++; if (g.awayTeamID) matched++; }
    }
  });
  document.getElementById('matchSummary').textContent = matched + '/' + total + ' teams matched';
}

function buildImportSummary() {
  var bracket = getSelectedBracket();
  var bracketLabel = bracket.bracketID !== null
    ? (document.getElementById('bracketSelect').selectedOptions[0].textContent)
    : (bracket.bracketName || '(unnamed bracket)');

  var rounds = {};
  parsedGames.forEach(function(g) { rounds[g.bracketRoundID] = true; });
  var roundList = Object.keys(rounds).sort(function(a,b){ return a-b; });

  var html = '<p style="margin:0;"><strong>' + parsedGames.length + ' game(s)</strong> into bracket ' +
    '<span class="bracket-badge" style="background:#1976d2">' + escHtml(bracketLabel) + '</span> ' +
    (roundList.length > 1 ? ('rounds ' + roundList.join(', ')) : ('round ' + roundList[0])) + '</p>';

  document.getElementById('importSummary').innerHTML = html;

  var importBtn = document.getElementById('importBtn');
  importBtn.disabled = parsedGames.length === 0 || (bracket.bracketID === null && !bracket.bracketName);
}

// ── Form Submission ───────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', function() {
  onBracketSelectChange();

  document.getElementById('importForm').addEventListener('submit', function(e) {
    e.preventDefault();
    if (!confirm('Import these games? If this round was already imported and none of its games have scores yet, the existing games for this round will be replaced.')) return;

    var payload = buildPayload();
    document.getElementById('formImportData').value = JSON.stringify(payload);
    this.submit();
  });
});

function buildPayload() {
  var bracket = getSelectedBracket();

  var formattedGames = parsedGames.map(function(g) {
    return {
      bracketRoundID: g.bracketRoundID,
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
  });

  return {
    bracketID: bracket.bracketID,
    bracketName: bracket.bracketName,
    games: formattedGames
  };
}

function useSuggestedTeam(rawName, teamID, teamName) {
  var key = rawName.toLowerCase().trim();
  teamNameMap[key] = { teamID: teamID, teamName: teamName };
  // Update all parsed games that reference this raw name
  parsedGames.forEach(function(g) {
    if (g.homeTeamRaw && g.homeTeamRaw.toLowerCase().trim() === key) g.homeTeamID = teamID;
    if (g.awayTeamRaw && g.awayTeamRaw.toLowerCase().trim() === key) g.awayTeamID = teamID;
  });
  renderPreview();
}

function resetImport() {
  document.getElementById('pasteArea').value = '';
  document.getElementById('previewBody').innerHTML = '';
  document.getElementById('previewCard').style.display = 'none';
  document.getElementById('confirmCard').style.display = 'none';
  parsedGames = [];
  teamNameMap = {};
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
