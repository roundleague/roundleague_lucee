// A $( document ).ready() block.
$(document).ready(function () {
  var globalHistory = [];
  var playerFlag = false;
  var playerNode;
  var playerNodeRow;
  var playerNodeIndex;

  var dnpPlayerId;

  $(".saveBtn").click(function () {
    $("#saveScoresModal").show();

    // Default the current team final score in the box to prevent confusion
    var finalScore = $(".teamTotalPts").text();
    $(".defaultScore").val(finalScore);

    // Pre-populate opponent score from live tracking
    if (typeof LIVE_SCORE_CONFIG !== "undefined") {
      var opponentScore = LIVE_SCORE_CONFIG.isHome ? currentScores.awayScore : currentScores.homeScore;
      $("#saveScoresModal input[type='number']").not(".defaultScore").val(opponentScore);
    }

    // Remove the player highlight to prevent any numbers from updating stats
    $("td.playerBox").removeClass("playerHighlight");

    return false;
  });

  // Hidden Jersey Column for export
  $(".jerseyNumber").keyup(function () {
    var exportJerseyNode = $(this).parent().next();
    exportJerseyNode.html($(this).val());
  });

  $(".dnpIcon").click(function () {
    // Get the Player name to display in confirmation
    var playerName = $(this).next(".playerName").text();
    $(".dnpPlayer").text(playerName);

    $("#dnpModal").show();

    // Get/Set the Player's ID to remove later
    var rowPlayerID = $(this).parent().parent();
    dnpPlayerId = parseInt($(rowPlayerID).attr("id").replace(/[^\d]/g, ""), 10);

    setTimeout(function () {
      $("td.playerBox").removeClass("playerHighlight");
    }, 100);
  });

  // DNP Remove Player Row
  $(".dnpConfirm").click(function () {
    $("#Player_" + dnpPlayerId).remove();
    $("#dnpModal").hide();
  });

  $(document).keydown(function (e) {
    var currentFocus = $(":focus");
    if (
      currentFocus.hasClass("playerName") ||
      currentFocus.hasClass("jerseyNumber")
    ) {
      return;
    }
    if (playerNode.hasClass("playerHighlight")) {
      switch (e.which) {
        case 97:
        case 49:
          hotKeyAdd("FGM");
          break;
        case 98:
        case 50:
          hotKeyAdd("FGA");
          break;
        case 99:
        case 51:
          hotKeyAdd("3FGM");
          break;
        case 100:
        case 52:
          hotKeyAdd("3FGA");
          break;
        case 101:
        case 53:
          hotKeyAdd("REBS");
          break;
        case 102:
        case 54:
          hotKeyAdd("ASTS");
          break;
        case 103:
        case 55:
          hotKeyAdd("STLS");
          break;
        case 104:
        case 56:
          hotKeyAdd("BLKS");
          break;
        case 105:
        case 57:
          hotKeyAdd("TO");
          break;
        case 83: // s
          playerNodeIndex = $(".playerBox").index(playerNode) + 1;
          if (playerNodeIndex < $(".playerBox").length) {
            $($(".playerBox")[playerNodeIndex]).trigger("click");
          }
          break;
        case 87: // w
          playerNodeIndex = $(".playerBox").index(playerNode) - 1;
          if (playerNodeIndex >= 0) {
            $($(".playerBox")[playerNodeIndex]).trigger("click");
          }
          break;
      }
    }
  });

  $(".playerBox").click(function () {
    // var row = $(this).parent('tr').index(),
    //         column = $(this).index();
    // console.log(row, column);

    $("td").not(this).removeClass("playerHighlight");
    $(this).toggleClass("playerHighlight");
    playerNode = $(this);
    playerNodeRow = $(this).parent("tr");
  });

  // $(document).keydown(function(e){
  // 	if( e.which === 90 && e.ctrlKey )
  // 	{
  // 		e.preventDefault();
  //         $('.undoBtn').trigger("click");
  //     }
  // });

  function hotKeyAdd(category) {
    var addNode = $(playerNodeRow)
      .find("." + category)
      .not(".button-error");

    // Push to globalHistory
    var undoNode = $(addNode).siblings(".button-error");
    globalHistory.push(undoNode);

    var playerID = $(addNode).closest("tr").attr("id");
    var fieldValueSpan = $(addNode).siblings(".fieldValue");
    var fieldValue = parseInt($(addNode).siblings(".fieldValue").val());
    var newFieldValue = fieldValue + 1;
    fieldValueSpan.val(newFieldValue);

    /* Visual Display of Add*/
    var tdFlash = $(addNode).parent();
    flashBackground(tdFlash);

    if ($(addNode).hasClass("FGM")) {
      addToValue("FGA", 1, playerID);
      addToValue("PTS", 2, playerID);
    } else if ($(addNode).hasClass("3FGM")) {
      addToValue("FGM", 1, playerID);
      addToValue("FGA", 1, playerID);
      addToValue("3FGA", 1, playerID);
      addToValue("PTS", 3, playerID);
    } else if ($(addNode).hasClass("3FGA")) {
      addToValue("FGA", 1, playerID);
    } else if ($(addNode).hasClass("FTM")) {
      addToValue("PTS", 1, playerID);
      addToValue("FTA", 1, playerID);
    }
  }

  $(".button-success").click(function () {
    // Push to globalHistory
    var undoNode = $(this).siblings(".button-error");
    globalHistory.push(undoNode);

    var playerID = $(this).closest("tr").attr("id");
    var fieldValueSpan = $(this).siblings(".fieldValue");
    var fieldValue = parseInt($(this).siblings(".fieldValue").val());
    var newFieldValue = fieldValue + 1;
    fieldValueSpan.val(newFieldValue);

    if ($(this).hasClass("FGM")) {
      addToValue("FGA", 1, playerID);
      addToValue("PTS", 2, playerID);
    } else if ($(this).hasClass("3FGM")) {
      addToValue("FGM", 1, playerID);
      addToValue("FGA", 1, playerID);
      addToValue("3FGA", 1, playerID);
      addToValue("PTS", 3, playerID);
    } else if ($(this).hasClass("3FGA")) {
      addToValue("FGA", 1, playerID);
    } else if ($(this).hasClass("FTM")) {
      addToValue("PTS", 1, playerID);
      addToValue("FTA", 1, playerID);
    } else if ($(this).hasClass("FOULS")) {
      var currentHalf = getCurrentHalf();
      var currentNum = parseFloat($(".Fouls_Half_" + currentHalf).html());
      currentNum += 1;
      $(".Fouls_Half_" + currentHalf).html(currentNum);
      patchFouls(currentHalf);
    }
  });

  $(document).keydown(function (e) {
    if (e.which === 90 && e.ctrlKey) {
      e.preventDefault();
      $(".undoBtn").trigger("click");
    }
  });

  $(".undoBtn").click(function () {
    var undoAction = globalHistory.pop();
    $(undoAction).trigger("click");
  });

  $(".button-error").click(function () {
    var fieldValueSpan = $(this).siblings(".fieldValue");
    var fieldValue = parseInt($(this).siblings(".fieldValue").val());
    var playerID = $(this).closest("tr").attr("id");
    var newFieldValue = fieldValue - 1;
    if (newFieldValue >= 0) {
      fieldValueSpan.val(newFieldValue);
      if ($(this).hasClass("FGM")) {
        addToValue("FGA", -1, playerID);
        addToValue("PTS", -2, playerID);
      } else if ($(this).hasClass("3FGM")) {
        addToValue("FGM", -1, playerID);
        addToValue("FGA", -1, playerID);
        addToValue("3FGA", -1, playerID);
        addToValue("PTS", -3, playerID);
      } else if ($(this).hasClass("3FGA")) {
        addToValue("FGA", -1, playerID);
      } else if ($(this).hasClass("FTM")) {
        addToValue("PTS", -1, playerID);
        addToValue("FTA", -1, playerID);
      } else if ($(this).hasClass("FOULS")) {
        var currentHalf = getCurrentHalf();
        var currentNum = parseFloat($(".Fouls_Half_" + currentHalf).html());
        if (currentNum > 0) {
          $(".Fouls_Half_" + currentHalf).html(currentNum - 1);
          patchFouls(currentHalf);
        }
      }
    }
  });

  function patchFouls(half) {
    if (!window.LIVE_SCORE_CONFIG) return;
    var cfg = window.LIVE_SCORE_CONFIG;
    var key = (cfg.isHome ? 'home' : 'away') + '_fouls_h' + half;
    var body = {};
    body[key] = parseInt($('.Fouls_Half_' + half).html()) || 0;
    fetch(cfg.apiBase + '/api/schedule/' + cfg.scheduleID + '/fouls', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'x-admin-key': cfg.adminKey },
      body: JSON.stringify(body)
    }).catch(function() {});
  }

  function addToValue(id, addValue, playerID) {
    var fieldValueSpan = $("#" + playerID).find("#" + id);
    var fieldValue = parseInt(fieldValueSpan.val());
    var newFieldValue = fieldValue + addValue;
    fieldValueSpan.val(newFieldValue);

    /* Visual Display of Add*/
    // var tdFlash = $(fieldValueSpan).parent();
    // flashBackground(tdFlash);

    if (id == "PTS") {
      var currentNum = parseFloat($(".teamTotalPts").html());
      currentNum += addValue;
      $(".teamTotalPts").html(currentNum);
      if (typeof window._rlUpdateScore === "function") {
        window._rlUpdateScore(currentNum);
      }
      updatePMDisplay();
    }
  }

  /* Drag and drop section */
  // var fixHelperModified = function(e, tr) {
  //     var $originals = tr.children();
  //     var $helper = tr.clone();
  //     $helper.children().each(function(index) {
  //         $(this).width($originals.eq(index).width())
  //     });
  //     return $helper;
  // },
  //     updateIndex = function(e, ui) {
  //         $('td.index', ui.item.parent()).each(function (i) {
  //             $(this).html(i + 1);
  //         });
  //     };

  // $("#sort tbody").sortable({
  //     helper: fixHelperModified,
  //     stop: updateIndex,
  //     cursor: "grabbing",
  //     cancel: "#bench"
  // }).disableSelection();
  /* End Drag and drop section */

  /* Test Drag and Replace */
  jQuery.fn.swap = function (b) {
    // method from: http://blog.pengoworks.com/index.cfm/2008/9/24/A-quick-and-dirty-swap-method-for-jQuery
    b = jQuery(b)[0];
    var a = this[0];
    var t = a.parentNode.insertBefore(document.createTextNode(""), a);
    b.parentNode.insertBefore(a, b);
    t.parentNode.insertBefore(b, t);
    t.parentNode.removeChild(t);
    return this;
  };

  $(".dragdrop").draggable({ revert: true, helper: "clone" });

  $(".dragdrop").droppable({
    accept: ".dragdrop",
    activeClass: "ui-state-hover",
    hoverClass: "ui-state-active",
    drop: function (event, ui) {
      var draggable = ui.draggable,
        droppable = $(this),
        dragPos = draggable.position(),
        dropPos = droppable.position();

      // Detect cross-boundary sub (starter ↔ bench) and record silently
      if (isPlayerInBench(draggable[0]) !== isPlayerInBench(droppable[0])) {
        var outRow = isPlayerInBench(draggable[0]) ? droppable[0] : draggable[0];
        var inRow  = isPlayerInBench(draggable[0]) ? draggable[0] : droppable[0];
        recordSub(outRow, inRow);
      }

      draggable.css({
        left: dropPos.left + "px",
        top: dropPos.top + "px",
      });

      droppable.css({
        left: dragPos.left + "px",
        top: dragPos.top + "px",
      });
      draggable.swap(droppable);
    },
  });
  /* End Drag Replace */

  // Collapse Bench Section
  $("#benchToggle").removeClass("ui-sortable-handle");
  $("#benchToggle").click(function (e) {
    if (
      $(e.target).closest(
        "#useTimeout, .switch, .switch-label, .switch-input, .switch-handle",
      ).length
    ) {
      return;
    }
    $(this).nextAll().toggle();
  });

  function flashBackground(node) {
    // Flash yellow background
    $(node).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
  }

  // 1st Half to 2nd Half Logic
  $(".switch-label").click(function () {
    var currentHalf = $(this).attr("data-value");
    if (currentHalf == "1") {
      $(this).attr("data-value", "2");
    } else {
      $(this).attr("data-value", "1");
    }
  });

  // Timeout +/- buttons
  function patchTimeouts(half) {
    if (!window.LIVE_SCORE_CONFIG) return;
    var cfg = window.LIVE_SCORE_CONFIG;
    var key = (cfg.isHome ? 'home' : 'away') + '_timeouts_h' + half;
    var body = {};
    body[key] = parseInt($('.Timeouts_Half_' + half).html()) || 0;
    fetch(cfg.apiBase + '/api/schedule/' + cfg.scheduleID + '/timeouts', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'x-admin-key': cfg.adminKey },
      body: JSON.stringify(body)
    }).catch(function() {});
  }

  $(".to-minus, .to-plus").click(function (e) {
    e.stopPropagation();
    var half = $(this).data("half");
    var span = $(".Timeouts_Half_" + half);
    var val = parseInt(span.html());
    if ($(this).hasClass("to-minus") && val > 0) {
      span.html(val - 1);
      patchTimeouts(half);
    } else if ($(this).hasClass("to-plus") && val < 10) {
      span.html(val + 1);
      patchTimeouts(half);
    }
  });

  function getCurrentHalf() {
    return $(".switch-label").attr("data-value");
  }
});

// +/- sub tracking state (module-level so accessible from jQuery ready + sub button handler)
var subEvents = [];
var currentScores = { homeScore: 0, awayScore: 0 };
var initialStarters = new Set();

function computeLivePM(playerID) {
  if (typeof LIVE_SCORE_CONFIG === 'undefined') return 0;
  var myScore = parseInt(document.querySelector('.teamTotalPts').textContent) || 0;
  var curH, curA;
  if (LIVE_SCORE_CONFIG.isHome) {
    curH = myScore; curA = currentScores.awayScore;
  } else {
    curA = myScore; curH = currentScores.homeScore;
  }
  var enterH = 0, enterA = 0, pm = 0;
  var onCourt = initialStarters.has(playerID);
  for (var k = 0; k < subEvents.length; k++) {
    var ev = subEvents[k];
    if (ev.playerOutID === playerID && onCourt) {
      pm += LIVE_SCORE_CONFIG.isHome
        ? (ev.homeScore - ev.awayScore) - (enterH - enterA)
        : (ev.awayScore - ev.homeScore) - (enterA - enterH);
      onCourt = false;
    }
    if (ev.playerInID === playerID && !onCourt) {
      enterH = ev.homeScore; enterA = ev.awayScore; onCourt = true;
    }
  }
  if (onCourt) {
    pm += LIVE_SCORE_CONFIG.isHome
      ? (curH - curA) - (enterH - enterA)
      : (curA - curH) - (enterA - enterH);
  }
  return pm;
}

function updatePMDisplay() {
  if (typeof LIVE_SCORE_CONFIG === 'undefined') return;
  document.querySelectorAll('.dragdrop').forEach(function(row) {
    var playerID = playerIDFromRow(row);
    var cell = document.getElementById('pm_' + playerID);
    if (!cell) return;
    var pm = computeLivePM(playerID);
    cell.textContent = pm > 0 ? '+' + pm : String(pm);
    cell.style.color = pm > 0 ? '#2e7d32' : pm < 0 ? '#c62828' : '';
  });
}

function playerIDFromRow(row) {
  return parseInt(row.id.replace(/\D/g, ''), 10);
}

function recordSub(outRow, inRow) {
  var myScore = parseInt(document.querySelector('.teamTotalPts').textContent) || 0;
  var homeScore, awayScore;
  if (typeof LIVE_SCORE_CONFIG !== 'undefined' && LIVE_SCORE_CONFIG.isHome) {
    homeScore = myScore;
    awayScore = currentScores.awayScore;
  } else {
    awayScore = myScore;
    homeScore = currentScores.homeScore;
  }
  subEvents.push({
    playerOutID: playerIDFromRow(outRow),
    playerInID:  playerIDFromRow(inRow),
    homeScore:   homeScore,
    awayScore:   awayScore,
    seq:         subEvents.length + 1
  });
  document.getElementById('subEventsInput').value = JSON.stringify(subEvents);
  updatePMDisplay();
}

// Multi-substitution functionality
let selectedPlayers = {
  starters: [],
  bench: [],
};

function updateSubButton() {
  const subButton = document.getElementById("subButton");
  const starterCount = selectedPlayers.starters.length;
  const benchCount = selectedPlayers.bench.length;

  if (starterCount > 0 && starterCount === benchCount) {
    subButton.style.display = "inline-block";
    subButton.textContent = `Sub (${starterCount})`;
  } else {
    subButton.style.display = "none";
  }
}

function isPlayerInBench(playerRow) {
  const benchToggle = document.getElementById("benchToggle");
  return benchToggle && playerRow.rowIndex > benchToggle.rowIndex;
}

// Handle player selection
document.addEventListener("click", function (e) {
  if (e.ctrlKey && e.target.closest(".dragdrop")) {
    e.preventDefault();
    const playerRow = e.target.closest(".dragdrop");
    const playerId = playerRow.id;
    const isSelected = playerRow.classList.contains("player-selected");
    const isBench = isPlayerInBench(playerRow);

    // Always remove the green highlight when Ctrl+clicking
    const playerBox = playerRow.querySelector(".playerBox");
    if (playerBox) {
      playerBox.classList.remove("playerHighlight");
    }

    if (isSelected) {
      // Deselect player
      playerRow.classList.remove("player-selected");
      if (isBench) {
        selectedPlayers.bench = selectedPlayers.bench.filter(
          (id) => id !== playerId,
        );
      } else {
        selectedPlayers.starters = selectedPlayers.starters.filter(
          (id) => id !== playerId,
        );
      }
    } else {
      // Select player
      playerRow.classList.add("player-selected");
      if (isBench) {
        selectedPlayers.bench.push(playerId);
      } else {
        selectedPlayers.starters.push(playerId);
      }
    }

    updateSubButton();
  }
});

// Handle substitution
document.addEventListener("DOMContentLoaded", function () {
  // Record which players started so computeLivePM can replay sub intervals correctly
  var benchToggle = document.getElementById('benchToggle');
  document.querySelectorAll('.dragdrop').forEach(function(row) {
    if (benchToggle && row.rowIndex < benchToggle.rowIndex) {
      initialStarters.add(playerIDFromRow(row));
    }
  });
  updatePMDisplay();

  // Serialize live +/- display values into the form before submission
  var gameForm = document.querySelector('form[name="gameLogForm"]');
  if (gameForm) {
    gameForm.addEventListener('submit', function() {
      var pmValues = {};
      document.querySelectorAll('[id^="pm_"]').forEach(function(cell) {
        var playerID = parseInt(cell.id.replace('pm_', ''), 10);
        pmValues[playerID] = parseInt(cell.textContent) || 0;
      });
      document.getElementById('plusMinusValuesInput').value = JSON.stringify(pmValues);
    });
  }

  const subButton = document.getElementById("subButton");
  if (subButton) {
    subButton.addEventListener("click", function () {
      if (selectedPlayers.starters.length !== selectedPlayers.bench.length) {
        return;
      }

      const tbody = document.querySelector(".statsAppTable tbody");
      const benchToggle = document.getElementById("benchToggle");

      // Get all selected rows
      const starterRows = selectedPlayers.starters.map((id) =>
        document.getElementById(id),
      );
      const benchRows = selectedPlayers.bench.map((id) =>
        document.getElementById(id),
      );

      // Record each sub pair silently before performing DOM moves
      starterRows.forEach(function(starterRow, index) {
        recordSub(starterRow, benchRows[index]);
      });

      // Perform the substitution by moving rows
      starterRows.forEach((starterRow, index) => {
        const benchRow = benchRows[index];

        // Insert starter after bench toggle
        tbody.insertBefore(starterRow, benchToggle.nextSibling);

        // Insert bench player at the beginning (before bench toggle)
        tbody.insertBefore(benchRow, benchToggle);
      });

      // Clear selections
      document.querySelectorAll(".player-selected").forEach((row) => {
        row.classList.remove("player-selected");
      });

      selectedPlayers.starters = [];
      selectedPlayers.bench = [];
      updateSubButton();
    });
  }
});

// Clear selections when clicking elsewhere (not Ctrl+click)
document.addEventListener("click", function (e) {
  if (!e.ctrlKey && !e.target.closest("#subButton")) {
    document.querySelectorAll(".player-selected").forEach((row) => {
      row.classList.remove("player-selected");
    });
    selectedPlayers.starters = [];
    selectedPlayers.bench = [];
    updateSubButton();
  }
});

/* ============================================================
 * Live Score Updates
 *
 * Fires a PATCH to the Node.js API to keep the mobile app
 * in sync during a game. Two things happen:
 *
 *   1. On page load — marks the game status as 'live' so the
 *      app shows a LIVE badge within its next 60s poll.
 *
 *   2. On every point change — a MutationObserver watches the
 *      teamTotalPts span (updated by addToValue in real time).
 *      Whenever it changes, the current team's score is sent.
 *      isHome determines whether to send homeScore or awayScore.
 *
 * Config is injected by StatsApp.cfm as LIVE_SCORE_CONFIG.
 * The block is skipped entirely for playoff games (config absent).
 * Status is set to 'final' by StatsApp-Save.cfm on form submit.
 * ============================================================ */
(function () {
  console.log(
    "LIVE_SCORE_CONFIG: ",
    typeof LIVE_SCORE_CONFIG === "undefined" ? "undefined" : LIVE_SCORE_CONFIG,
  );
  if (typeof LIVE_SCORE_CONFIG === "undefined") return;

  var cfg = LIVE_SCORE_CONFIG;
  var API_BASE = cfg.apiBase + "/api";

  function patchScore(body) {
    fetch(API_BASE + "/schedule/" + cfg.scheduleID + "/score", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "x-admin-key": cfg.adminKey,
      },
      body: JSON.stringify(body),
    });
  }

  // Track opponent score so recordSub can snapshot both sides
  if (window.gameSocket) {
    window.gameSocket.on('score:update', function(data) {
      if (data.homeScore != null) currentScores.homeScore = data.homeScore;
      if (data.awayScore != null) currentScores.awayScore = data.awayScore;
      updatePMDisplay();
    });
  }

  // Mark game as live on page load
  patchScore({ status: "live" });

  // Called directly by addToValue whenever PTS changes — avoids double-firing
  // that a MutationObserver caused because .html() generates two DOM mutations
  // (remove old text node, insert new one) per score update.
  window._rlUpdateScore = function (newScore) {
    var body = cfg.isHome ? { homeScore: newScore } : { awayScore: newScore };
    patchScore(body);
  };
})();
