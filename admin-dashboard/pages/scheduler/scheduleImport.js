// Schedule Import JavaScript

var parsedGames = [];
var validGames = [];

// Normalize team name for matching - strips parenthetical numbers and extra whitespace
function normalizeTeamName(name) {
  if (!name) return "";
  return name
    .replace(/\s*\(\d+\)\s*/g, "") // Remove (123) patterns
    .replace(/\s+/g, " ") // Normalize whitespace
    .trim()
    .toLowerCase();
}

// Find a team match using exact match first, then fuzzy match
function findTeamMatch(teamName) {
  if (!teamName) return null;

  var exactKey = teamName.toLowerCase().trim();

  // Try exact match first
  if (teamLookup[exactKey]) {
    return teamLookup[exactKey];
  }

  // Try normalized match (strips parenthetical numbers)
  var normalizedInput = normalizeTeamName(teamName);

  for (var key in teamLookup) {
    var normalizedKey = normalizeTeamName(key);
    if (normalizedKey === normalizedInput) {
      return teamLookup[key];
    }
  }

  // Try contains match as last resort
  for (var key in teamLookup) {
    var normalizedKey = normalizeTeamName(key);
    if (
      normalizedKey.indexOf(normalizedInput) > -1 ||
      normalizedInput.indexOf(normalizedKey) > -1
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
      // Validate home team (try exact match, then fuzzy match)
      var homeMatch = findTeamMatch(game.homeTeam);
      if (homeMatch) {
        game.homeTeamID = homeMatch.teamID;
        game.homeTeam = homeMatch.teamName; // Use canonical name
      } else if (game.homeTeam) {
        game.status = "error";
        game.errors.push("Unknown home team");
        unknownTeams[game.homeTeam] = true;
      }

      // Validate away team (try exact match, then fuzzy match)
      var awayMatch = findTeamMatch(game.awayTeam);
      if (awayMatch) {
        game.awayTeamID = awayMatch.teamID;
        game.awayTeam = awayMatch.teamName; // Use canonical name
      } else if (game.awayTeam) {
        game.status = "error";
        game.errors.push("Unknown away team");
        unknownTeams[game.awayTeam] = true;
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
