// Schedule Import JavaScript

var parsedGames = [];
var validGames = [];
var teamsInSchedule = {}; // Track all teams found in pasted schedule
var unknownTeamsFromSchedule = {}; // Teams in schedule but not in DB
var missingTeamsFromDB = {}; // Teams in DB but not in schedule

// Normalize team name for matching - strips parenthetical codes/numbers and extra whitespace
function normalizeTeamName(name) {
  if (!name) return "";
  return name
    .replace(/\s*\([^)]*\)\s*/g, "") // Remove all parenthetical content like (123), (IVP), etc.
    .replace(/\s+/g, " ") // Normalize whitespace
    .trim()
    .toLowerCase();
}

// Extract alternate/old team name from parentheses if it's text (not a number)
// e.g. "Rip City Rejects (Consumption)" -> "consumption"
// e.g. "Taste Ticklers (54)" -> null (number = team ID, not an alternate name)
function extractAlternateName(name) {
  if (!name) return null;
  var match = name.match(/\(([^)]+)\)/);
  if (match) {
    var inside = match[1].trim();
    // If it's purely numeric, it's a team ID - not an alternate name
    if (/^\d+$/.test(inside)) return null;
    return inside.toLowerCase();
  }
  return null;
}

// Common abbreviation expansions for fuzzy matching
var abbreviationMap = {
  nw: "northwest",
  ne: "northeast",
  sw: "southwest",
  se: "southeast",
  n: "north",
  s: "south",
  e: "east",
  w: "west",
  st: "saint",
  mt: "mount",
  jr: "junior",
  sr: "senior",
};

// Expand abbreviations in a team name for comparison
function expandAbbreviations(name) {
  if (!name) return "";
  var words = name.toLowerCase().trim().split(/\s+/);
  return words
    .map(function (w) {
      return abbreviationMap[w] || w;
    })
    .join(" ");
}

// Calculate similarity score between two strings (0 to 1)
function similarityScore(a, b) {
  if (!a || !b) return 0;
  a = a.toLowerCase();
  b = b.toLowerCase();
  if (a === b) return 1;

  // Check abbreviation-expanded match
  var expandedA = expandAbbreviations(a);
  var expandedB = expandAbbreviations(b);
  if (expandedA === expandedB) return 0.95;

  // Word overlap scoring
  var wordsA = expandedA.split(/\s+/);
  var wordsB = expandedB.split(/\s+/);
  var matchCount = 0;
  wordsA.forEach(function (wa) {
    wordsB.forEach(function (wb) {
      if (wa === wb) matchCount++;
      // Partial word match (one starts with the other, min 3 chars)
      else if (wa.length >= 3 && wb.length >= 3) {
        if (wb.indexOf(wa) === 0 || wa.indexOf(wb) === 0) matchCount += 0.7;
      }
    });
  });
  var maxWords = Math.max(wordsA.length, wordsB.length);
  var wordScore = matchCount / maxWords;

  // Contains check (one is substring of the other after expansion)
  // Require a reasonable length ratio to avoid matching tiny substrings (e.g. "IVP" inside "Skin N' Bones")
  var lenRatio =
    Math.min(expandedA.length, expandedB.length) /
    Math.max(expandedA.length, expandedB.length);
  if (
    lenRatio >= 0.4 &&
    (expandedA.indexOf(expandedB) > -1 || expandedB.indexOf(expandedA) > -1)
  ) {
    wordScore = Math.max(wordScore, 0.6 + lenRatio * 0.3);
  }

  return wordScore;
}

// Find a suggested match from all teams (active + inactive) for an unknown team name.
// Returns {team: {...}, source: 'active'|'inactive'} or null.
function findSuggestion(teamName) {
  if (!teamName) return null;
  var bestScore = 0;
  var bestMatch = null;
  var bestSource = null;
  var threshold = 0.5; // Minimum score to suggest

  var normalizedInput = normalizeTeamName(teamName);
  var altName = extractAlternateName(teamName);

  // Helper to check a candidate and update best match
  function checkCandidate(candidateKey, team, source) {
    var normalizedKey = normalizeTeamName(candidateKey);
    // Score against primary name
    var score = similarityScore(normalizedInput, normalizedKey);
    // Also score against alternate/old name if present
    if (altName) {
      var altScore = similarityScore(altName, normalizedKey);
      score = Math.max(score, altScore);
    }
    if (score > bestScore) {
      bestScore = score;
      bestMatch = team;
      bestSource = source;
    }
  }

  // Search active teams
  for (var key in teamLookup) {
    checkCandidate(key, teamLookup[key], "active");
  }

  // Search inactive teams
  for (var key in inactiveTeamLookup) {
    checkCandidate(key, inactiveTeamLookup[key], "inactive");
  }

  if (bestScore >= threshold && bestMatch) {
    return { team: bestMatch, source: bestSource, score: bestScore };
  }
  return null;
}

// Find a team match using exact match first, then fuzzy match
function findTeamMatch(teamName) {
  if (!teamName) return null;

  var exactKey = teamName.toLowerCase().trim();

  // Try exact match first
  if (teamLookup[exactKey]) {
    return teamLookup[exactKey];
  }

  // Try normalized match (strips parenthetical content)
  var normalizedInput = normalizeTeamName(teamName);

  for (var key in teamLookup) {
    var normalizedKey = normalizeTeamName(key);
    if (normalizedKey === normalizedInput) {
      return teamLookup[key];
    }
  }

  // Try alternate/old name from parentheses e.g. "Rip City Rejects (Consumption)" -> try "consumption"
  var altName = extractAlternateName(teamName);
  if (altName) {
    // Try exact match on alternate name
    if (teamLookup[altName]) {
      return teamLookup[altName];
    }
    // Try normalized match on alternate name
    for (var key in teamLookup) {
      var normalizedKey = normalizeTeamName(key);
      if (normalizedKey === altName) {
        return teamLookup[key];
      }
    }
  }

  // Try contains match as last resort - require minimum length ratio to avoid
  // short names like "IVP" matching inside "Skin N' Bones" just because of a code
  for (var key in teamLookup) {
    var normalizedKey = normalizeTeamName(key);
    var shorter = Math.min(normalizedKey.length, normalizedInput.length);
    var longer = Math.max(normalizedKey.length, normalizedInput.length);
    if (
      shorter / longer >= 0.5 &&
      (normalizedKey.indexOf(normalizedInput) > -1 ||
        normalizedInput.indexOf(normalizedKey) > -1)
    ) {
      return teamLookup[key];
    }
  }

  return null;
}

function parseScheduleData() {
  var pasteArea = document.getElementById("pasteArea");
  var divisionID = document.getElementById("divisionSelect").value;

  if (!divisionID) {
    alert("Please select a division first.");
    return;
  }

  var rawData = pasteArea.value.trim();
  if (!rawData) {
    alert("Please paste schedule data first.");
    return;
  }

  // Split into lines
  var lines = rawData.split("\n");

  parsedGames = [];
  validGames = [];
  var unknownTeams = {};
  teamsInSchedule = {};
  unknownTeamsFromSchedule = {};
  missingTeamsFromDB = {};

  // Track current week and date from week headers
  var currentWeek = 0;
  var currentDate = "";
  var rowNum = 0;

  lines.forEach(function (line) {
    line = line.trim();
    if (!line) return; // Skip empty lines

    // Check if this is a week header line: "Week X - Day, Month Dayth"
    var weekMatch = line.match(/Week\s+(\d+)\s*[-–]\s*\w+,?\s*(.+)/i);
    if (weekMatch) {
      currentWeek = parseInt(weekMatch[1]);
      currentDate = parseWeekDate(weekMatch[2].trim());
      return; // This is a header line, don't create a game
    }

    // Skip division header lines and other non-game lines
    if (line.match(/Division\s+Schedule/i) || !line.match(/vs/i)) {
      return;
    }

    // This should be a game line: "Time\tTeam1 vs Team2" or "Time Team1 vs Team2"
    rowNum++;
    var game = parseGameLine(line, rowNum, currentWeek, currentDate);

    if (game) {
      // Track original team names for diff
      var originalHomeTeam = game.homeTeam;
      var originalAwayTeam = game.awayTeam;

      // Validate home team (try exact match, then fuzzy match)
      var homeMatch = findTeamMatch(game.homeTeam);
      if (homeMatch) {
        game.homeTeamID = homeMatch.teamID;
        game.homeTeam = homeMatch.teamName; // Use canonical name
        teamsInSchedule[homeMatch.teamName.toLowerCase()] = homeMatch;
      } else if (game.homeTeam) {
        game.status = "error";
        game.errors.push("Unknown home team");
        unknownTeams[game.homeTeam] = true;
        unknownTeamsFromSchedule[originalHomeTeam] = true;
      }

      // Validate away team (try exact match, then fuzzy match)
      var awayMatch = findTeamMatch(game.awayTeam);
      if (awayMatch) {
        game.awayTeamID = awayMatch.teamID;
        game.awayTeam = awayMatch.teamName; // Use canonical name
        teamsInSchedule[awayMatch.teamName.toLowerCase()] = awayMatch;
      } else if (game.awayTeam) {
        game.status = "error";
        game.errors.push("Unknown away team");
        unknownTeams[game.awayTeam] = true;
        unknownTeamsFromSchedule[originalAwayTeam] = true;
      }

      // Validate date
      if (!game.date || !isValidDate(game.date)) {
        game.status = "error";
        game.errors.push("Invalid date");
      }

      // Validate week
      if (!game.week || game.week < 1) {
        game.status = "error";
        game.errors.push("Invalid week");
      }

      parsedGames.push(game);

      if (game.status === "valid") {
        validGames.push(game);
      }
    }
  });

  // Find teams in DB for this division that are NOT in the schedule
  var selectedDivisionID = parseInt(divisionID);
  for (var key in teamLookup) {
    var team = teamLookup[key];
    // Only check teams in the selected division
    if (team.divisionID === selectedDivisionID) {
      if (!teamsInSchedule[key]) {
        missingTeamsFromDB[team.teamName] = team;
      }
    }
  }

  // Display team diff panel
  displayTeamDiff(unknownTeamsFromSchedule, missingTeamsFromDB, divisionID);

  // Display preview
  displayPreview(parsedGames, unknownTeams, divisionID);
}

function parseWeekDate(dateStr) {
  // Parse dates like "February 23rd", "March 2nd", etc.
  // Remove ordinal suffixes (st, nd, rd, th)
  dateStr = dateStr.replace(/(\d+)(st|nd|rd|th)/gi, "$1");

  // Get current year
  var currentYear = new Date().getFullYear();

  // Try to parse with current year
  var date = new Date(dateStr + ", " + currentYear);
  if (!isNaN(date.getTime())) {
    return formatDateForDB(date);
  }

  // Fallback: try parsing directly (might have year included)
  date = new Date(dateStr);
  if (!isNaN(date.getTime())) {
    return formatDateForDB(date);
  }

  return dateStr; // Return as-is if we can't parse it
}

function parseGameLine(line, rowNum, currentWeek, currentDate) {
  // Format: "6:15 PM\tKoolaid Jammerz (160) vs Southwest"
  // or: "6:15 PM Koolaid Jammerz (160) vs Southwest"

  var game = {
    row: rowNum,
    homeTeam: "",
    awayTeam: "",
    date: currentDate,
    time: "",
    week: currentWeek,
    homeTeamID: null,
    awayTeamID: null,
    status: "valid",
    errors: [],
  };

  // Split by tab first
  var parts;
  if (line.indexOf("\t") > -1) {
    parts = line.split("\t");
    game.time = parts[0].trim();
    var teamsStr = parts.slice(1).join(" ").trim();
    var teams = teamsStr.split(/\s+vs\s+/i);
    if (teams.length === 2) {
      game.homeTeam = teams[0].trim();
      game.awayTeam = teams[1].trim();
    }
  } else {
    // No tab - try to parse "TIME TEAM vs TEAM"
    var timeMatch = line.match(/^(\d{1,2}:\d{2}\s*(?:AM|PM)?)\s+(.+)/i);
    if (timeMatch) {
      game.time = timeMatch[1].trim();
      var teamsStr = timeMatch[2].trim();
      var teams = teamsStr.split(/\s+vs\s+/i);
      if (teams.length === 2) {
        game.homeTeam = teams[0].trim();
        game.awayTeam = teams[1].trim();
      }
    }
  }

  if (!game.homeTeam || !game.awayTeam) {
    return null; // Couldn't parse this line
  }

  return game;
}

function isValidDate(dateStr) {
  // Try to parse various date formats
  if (dateStr instanceof Date) {
    return !isNaN(dateStr.getTime());
  }
  var date = new Date(dateStr);
  return !isNaN(date.getTime());
}

function formatDateForDB(dateInput) {
  // Convert to YYYY-MM-DD format
  // Handle both Date objects and strings
  var date;
  if (dateInput instanceof Date) {
    date = dateInput;
  } else {
    date = new Date(dateInput);
  }

  if (isNaN(date.getTime())) return "";

  var year = date.getFullYear();
  var month = String(date.getMonth() + 1).padStart(2, "0");
  var day = String(date.getDate()).padStart(2, "0");

  return year + "-" + month + "-" + day;
}

function formatTimeForDB(timeStr) {
  // Convert various time formats to HH:MM:SS
  if (!timeStr) return "";

  timeStr = timeStr.trim().toUpperCase();

  // Try parsing with AM/PM
  var match = timeStr.match(/(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM)?/i);
  if (match) {
    var hours = parseInt(match[1]);
    var minutes = match[2];
    var seconds = match[3] || "00";
    var ampm = match[4];

    if (ampm === "PM" && hours < 12) {
      hours += 12;
    } else if (ampm === "AM" && hours === 12) {
      hours = 0;
    }

    return String(hours).padStart(2, "0") + ":" + minutes + ":" + seconds;
  }

  return timeStr;
}

function displayPreview(games, unknownTeams, divisionID) {
  var previewCard = document.getElementById("previewCard");
  var confirmCard = document.getElementById("confirmCard");
  var previewBody = document.getElementById("previewBody");
  var teamWarnings = document.getElementById("teamWarnings");
  var unknownTeamsList = document.getElementById("unknownTeamsList");
  var importSummary = document.getElementById("importSummary");

  // Show preview card
  previewCard.style.display = "block";

  // Clear previous content
  previewBody.innerHTML = "";
  unknownTeamsList.innerHTML = "";

  // Show unknown teams warning
  var unknownTeamNames = Object.keys(unknownTeams);
  if (unknownTeamNames.length > 0) {
    teamWarnings.style.display = "block";
    unknownTeamNames.forEach(function (team) {
      var li = document.createElement("li");
      li.textContent = team;
      unknownTeamsList.appendChild(li);
    });
  } else {
    teamWarnings.style.display = "none";
  }

  // Build preview table
  games.forEach(function (game) {
    var tr = document.createElement("tr");
    tr.className = game.status === "valid" ? "table-success" : "table-danger";

    tr.innerHTML =
      "<td>" +
      game.row +
      "</td>" +
      "<td>" +
      escapeHtml(game.homeTeam) +
      "</td>" +
      "<td>" +
      escapeHtml(game.awayTeam) +
      "</td>" +
      "<td>" +
      escapeHtml(game.date) +
      "</td>" +
      "<td>" +
      escapeHtml(game.time) +
      "</td>" +
      "<td>" +
      escapeHtml(game.week) +
      "</td>" +
      "<td>" +
      (game.status === "valid" ? "✓ Valid" : "✗ " + game.errors.join(", ")) +
      "</td>";

    previewBody.appendChild(tr);
  });

  // Summary
  var validCount = validGames.length;
  var errorCount = games.length - validCount;

  importSummary.innerHTML =
    "<strong>Summary:</strong> " +
    validCount +
    " valid games, " +
    errorCount +
    " with errors.";

  // Show confirm card if there are valid games
  if (validCount > 0) {
    confirmCard.style.display = "block";
    document.getElementById("validGameCount").textContent = validCount;
    document.getElementById("importBtn").disabled = false;
    document.getElementById("formDivisionID").value = divisionID;

    // Prepare data for submission
    var submitData = validGames.map(function (game) {
      return {
        homeTeamID: game.homeTeamID,
        awayTeamID: game.awayTeamID,
        date: formatDateForDB(game.date),
        time: formatTimeForDB(game.time),
        week: parseInt(game.week),
      };
    });

    document.getElementById("formScheduleData").value =
      JSON.stringify(submitData);
  } else {
    confirmCard.style.display = "none";
  }
}

function escapeHtml(text) {
  if (!text) return "";
  var div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

// Display Team Diff/Sync Panel
function displayTeamDiff(newTeams, missingTeams, divisionID) {
  var teamDiffCard = document.getElementById("teamDiffCard");
  var newTeamsList = document.getElementById("newTeamsList");
  var missingTeamsList = document.getElementById("missingTeamsList");

  var newTeamNames = Object.keys(newTeams);
  var missingTeamNames = Object.keys(missingTeams);

  // Only show the card if there's something to show
  if (newTeamNames.length === 0 && missingTeamNames.length === 0) {
    teamDiffCard.style.display = "none";
    return;
  }

  teamDiffCard.style.display = "block";

  // Build new teams list with quick-add or activate buttons
  if (newTeamNames.length > 0) {
    var html = "";
    newTeamNames.forEach(function (teamName) {
      var escapedName = escapeHtml(teamName);
      var dataName = teamName.replace(/'/g, "\\'").replace(/"/g, "&quot;");
      var normalizedName = normalizeTeamName(teamName);

      // Check if this team exists as inactive
      var inactiveMatch = null;
      for (var key in inactiveTeamLookup) {
        if (normalizeTeamName(key) === normalizedName) {
          inactiveMatch = inactiveTeamLookup[key];
          break;
        }
      }

      if (inactiveMatch) {
        // Team exists but is inactive - show Activate button
        html +=
          '<div class="team-diff-item team-inactive-reactivate" id="new-team-' +
          encodeURIComponent(teamName) +
          '">' +
          '<span class="team-name">' +
          escapedName +
          ' <span class="badge badge-secondary">Inactive</span></span>' +
          '<button type="button" class="btn btn-info btn-sm btn-activate-team" ' +
          'onclick="quickActivateTeam(' +
          inactiveMatch.teamID +
          ", '" +
          dataName +
          "', " +
          divisionID +
          ')">' +
          '<i class="nc-icon nc-check-2"></i> Activate</button>' +
          "</div>";
      } else {
        // Check for fuzzy suggestion from active or inactive teams
        var suggestion = findSuggestion(teamName);

        html +=
          '<div class="team-diff-item team-new" id="new-team-' +
          encodeURIComponent(teamName) +
          '">' +
          '<div class="team-diff-item-content">' +
          '<span class="team-name">' +
          escapedName +
          "</span>";

        if (suggestion) {
          var suggestedName = escapeHtml(suggestion.team.teamName);
          var sugDataName = suggestion.team.teamName
            .replace(/'/g, "\\'")
            .replace(/"/g, "&quot;");
          var isInactive = suggestion.source === "inactive";
          var statusLabel = isInactive
            ? ' <span class="badge badge-secondary">Inactive</span>'
            : "";

          html +=
            '<div class="team-suggestion">' +
            '<i class="nc-icon nc-bulb-63"></i> Did you mean <strong>' +
            suggestedName +
            "</strong>?" +
            statusLabel;

          if (isInactive) {
            // Suggestion is inactive team - Use This will activate it
            html +=
              ' <button type="button" class="btn btn-info btn-sm btn-use-suggestion" ' +
              'onclick="useSuggestedTeamActivate(' +
              suggestion.team.teamID +
              ", '" +
              sugDataName +
              "', '" +
              dataName +
              "', " +
              divisionID +
              ')">' +
              '<i class="nc-icon nc-check-2"></i> Activate &amp; Use</button>';
          } else {
            // Suggestion is active team - Use This will map it
            html +=
              ' <button type="button" class="btn btn-primary btn-sm btn-use-suggestion" ' +
              "onclick=\"useSuggestedTeam('" +
              sugDataName +
              "', '" +
              dataName +
              "')\">" +
              '<i class="nc-icon nc-check-2"></i> Use This</button>';
          }
          html += "</div>";
        }

        // Always show Add as New button
        html +=
          "</div>" +
          '<button type="button" class="btn btn-success btn-sm btn-add-team" ' +
          "onclick=\"quickAddTeam('" +
          dataName +
          "', " +
          divisionID +
          ')">' +
          '<i class="nc-icon nc-simple-add"></i> Add New</button>' +
          "</div>";
      }
    });
    newTeamsList.innerHTML = html;
  } else {
    newTeamsList.innerHTML =
      '<p class="text-muted">All teams in schedule found in database.</p>';
  }

  // Build missing teams list with mark inactive buttons
  if (missingTeamNames.length > 0) {
    var html = "";
    missingTeamNames.forEach(function (teamName) {
      var team = missingTeams[teamName];
      var escapedName = escapeHtml(teamName);
      html +=
        '<div class="team-diff-item team-missing" id="missing-team-' +
        team.teamID +
        '">' +
        '<span class="team-name">' +
        escapedName +
        "</span>" +
        '<button type="button" class="btn btn-warning btn-sm btn-mark-inactive" ' +
        'onclick="markTeamInactive(' +
        team.teamID +
        ", '" +
        escapedName.replace(/'/g, "\\'") +
        "')\">" +
        '<i class="nc-icon nc-simple-remove"></i> Inactive</button>' +
        "</div>";
    });
    missingTeamsList.innerHTML = html;
  } else {
    missingTeamsList.innerHTML =
      '<p class="text-muted">All database teams found in schedule.</p>';
  }
}

// Quick add a new team
function quickAddTeam(teamName, divisionID) {
  if (!confirm('Add team "' + teamName + '" to this division?')) {
    return;
  }

  var formData = new FormData();
  formData.append("action", "addTeam");
  formData.append("teamName", teamName);
  formData.append("divisionID", divisionID);

  fetch("teamActions.cfm", {
    method: "POST",
    body: formData,
  })
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (data.success) {
        // Add to teamLookup
        var key = data.teamName.toLowerCase();
        teamLookup[key] = {
          teamID: data.teamID,
          teamName: data.teamName,
          divisionID: parseInt(divisionID),
        };

        // Update the UI - mark as added
        var itemEl = document.getElementById(
          "new-team-" + encodeURIComponent(teamName),
        );
        if (itemEl) {
          itemEl.classList.remove("team-new");
          itemEl.classList.add("team-added");
          itemEl.innerHTML =
            '<span class="team-name">' +
            escapeHtml(data.teamName) +
            "</span>" +
            '<span class="badge badge-success">Added (ID: ' +
            data.teamID +
            ")</span>";
        }

        // Re-parse to update the preview with the new team
        alert(
          "Team added! Click 'Parse & Preview' again to update the preview.",
        );
      } else {
        alert("Error: " + data.message);
      }
    })
    .catch(function (error) {
      alert("Error adding team: " + error);
    });
}

// Use a suggested active team - maps the schedule name to the existing DB team
function useSuggestedTeam(dbTeamName, scheduleTeamName) {
  var key = dbTeamName.toLowerCase();
  var team = teamLookup[key];
  if (!team) {
    alert("Could not find team '" + dbTeamName + "' in lookup.");
    return;
  }

  // Also add the schedule alias to teamLookup so re-parse will match it
  var aliasKey = scheduleTeamName.toLowerCase();
  teamLookup[aliasKey] = {
    teamID: team.teamID,
    teamName: team.teamName,
    divisionID: team.divisionID,
  };

  // Re-parse automatically to update preview with the mapped team
  parseScheduleData();
}

// Use a suggested inactive team - activate it and map the schedule name
function useSuggestedTeamActivate(
  teamID,
  dbTeamName,
  scheduleTeamName,
  divisionID,
) {
  if (
    !confirm(
      'Activate "' +
        dbTeamName +
        '" and use it for "' +
        scheduleTeamName +
        '"?',
    )
  ) {
    return;
  }

  var formData = new FormData();
  formData.append("action", "activateTeam");
  formData.append("teamID", teamID);
  formData.append("divisionID", divisionID);

  fetch("teamActions.cfm", {
    method: "POST",
    body: formData,
  })
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (data.success) {
        // Add both the canonical name and the schedule alias to teamLookup
        var key = data.teamName.toLowerCase();
        teamLookup[key] = {
          teamID: data.teamID,
          teamName: data.teamName,
          divisionID: parseInt(divisionID),
        };
        var aliasKey = scheduleTeamName.toLowerCase();
        teamLookup[aliasKey] = {
          teamID: data.teamID,
          teamName: data.teamName,
          divisionID: parseInt(divisionID),
        };

        // Remove from inactiveTeamLookup
        for (var iKey in inactiveTeamLookup) {
          if (inactiveTeamLookup[iKey].teamID === data.teamID) {
            delete inactiveTeamLookup[iKey];
            break;
          }
        }

        // Re-parse automatically to update preview with the activated+mapped team
        parseScheduleData();
      } else {
        alert("Error: " + data.message);
      }
    })
    .catch(function (error) {
      alert("Error activating team: " + error);
    });
}

// Activate an inactive team
function quickActivateTeam(teamID, teamName, divisionID) {
  if (
    !confirm(
      'Activate team "' +
        teamName +
        '"? This will set it to Active and assign it to the selected division and current season.',
    )
  ) {
    return;
  }

  var formData = new FormData();
  formData.append("action", "activateTeam");
  formData.append("teamID", teamID);
  formData.append("divisionID", divisionID);

  fetch("teamActions.cfm", {
    method: "POST",
    body: formData,
  })
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (data.success) {
        // Add to teamLookup so parsing recognizes it
        var key = data.teamName.toLowerCase();
        teamLookup[key] = {
          teamID: data.teamID,
          teamName: data.teamName,
          divisionID: parseInt(divisionID),
        };

        // Remove from inactiveTeamLookup
        for (var iKey in inactiveTeamLookup) {
          if (inactiveTeamLookup[iKey].teamID === data.teamID) {
            delete inactiveTeamLookup[iKey];
            break;
          }
        }

        // Update the UI - mark as activated
        var itemEl = document.getElementById(
          "new-team-" + encodeURIComponent(teamName),
        );
        if (itemEl) {
          itemEl.classList.remove("team-inactive-reactivate");
          itemEl.classList.add("team-added");
          itemEl.innerHTML =
            '<span class="team-name">' +
            escapeHtml(data.teamName) +
            "</span>" +
            '<span class="badge badge-success">Activated (ID: ' +
            data.teamID +
            ")</span>";
        }

        alert(
          "Team activated! Click 'Parse & Preview' again to update the preview.",
        );
      } else {
        alert("Error: " + data.message);
      }
    })
    .catch(function (error) {
      alert("Error activating team: " + error);
    });
}

// Mark a team as inactive
function markTeamInactive(teamID, teamName) {
  if (
    !confirm(
      'Mark team "' +
        teamName +
        '" as inactive? This team is not in the current schedule.',
    )
  ) {
    return;
  }

  var formData = new FormData();
  formData.append("action", "markInactive");
  formData.append("teamID", teamID);

  fetch("teamActions.cfm", {
    method: "POST",
    body: formData,
  })
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      if (data.success) {
        // Remove from teamLookup
        for (var key in teamLookup) {
          if (teamLookup[key].teamID === teamID) {
            delete teamLookup[key];
            break;
          }
        }

        // Update the UI - mark as inactive
        var itemEl = document.getElementById("missing-team-" + teamID);
        if (itemEl) {
          itemEl.classList.remove("team-missing");
          itemEl.classList.add("team-inactive");
          itemEl.innerHTML =
            '<span class="team-name">' +
            escapeHtml(teamName) +
            "</span>" +
            '<span class="badge badge-secondary">Marked Inactive</span>';
        }
      } else {
        alert("Error: " + data.message);
      }
    })
    .catch(function (error) {
      alert("Error: " + error);
    });
}
