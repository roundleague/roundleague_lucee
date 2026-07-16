$( document ).ready(function() {
  var modal = $('#editGameModal');
  var swapModal = $('#swapConfirmModal');
  var form = modal.find('form');
  var scheduleData = window.scheduleData || [];
  var current = {};
  var pendingSwap = null;

  modal.on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);

    current = {
      scheduleID: button.data('scheduleid'),
      week: button.data('week'),
      homeTeamID: button.data('hometeamid'),
      awayTeamID: button.data('awayteamid'),
      homeName: button.data('homeName'),
      awayName: button.data('awayName')
    };

    modal.find('#editScheduleID').val(current.scheduleID);
    modal.find('#editHomeTeamID').val(current.homeTeamID);
    modal.find('#editAwayTeamID').val(current.awayTeamID);
    modal.find('#editDate').val(button.data('date'));
    modal.find('#editTime').val(button.data('time'));

    modal.find('#swapScheduleID').val('');
    modal.find('#swapSide').val('');
    modal.find('#swapOriginalTeamID').val('');
  });

  // Finds another game this week (not the one being edited) that already has teamID in a slot
  function findConflict(teamID) {
    for (var i = 0; i < scheduleData.length; i++) {
      var g = scheduleData[i];
      if (g.scheduleID === current.scheduleID || g.week !== current.week) continue;
      if (g.homeTeamID === teamID) return { game: g, side: 'home' };
      if (g.awayTeamID === teamID) return { game: g, side: 'away' };
    }
    return null;
  }

  function formatDateLabel(isoDate) {
    var parts = isoDate.split('-');
    return parts.length === 3 ? (parts[1] + '/' + parts[2]) : isoDate;
  }

  function formatTimeLabel(time24) {
    var parts = time24.split(':');
    if (parts.length < 2) return time24;
    var h = parseInt(parts[0], 10);
    var ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h === 0) h = 12;
    return h + ':' + parts[1] + ' ' + ampm;
  }

  form.on('submit', function(e) {
    if (form.data('swapConfirmed')) {
      form.data('swapConfirmed', false);
      return true;
    }

    var newHome = parseInt(modal.find('#editHomeTeamID').val(), 10);
    var newAway = parseInt(modal.find('#editAwayTeamID').val(), 10);
    var newHomeName = modal.find('#editHomeTeamID option:selected').text();
    var newAwayName = modal.find('#editAwayTeamID option:selected').text();

    var conflict = null;
    var originalTeamID = null;
    var originalTeamName = null;

    if (newHome !== current.homeTeamID) {
      conflict = findConflict(newHome);
      if (conflict) {
        originalTeamID = current.homeTeamID;
        originalTeamName = current.homeName;
      }
    }
    if (!conflict && newAway !== current.awayTeamID) {
      conflict = findConflict(newAway);
      if (conflict) {
        originalTeamID = current.awayTeamID;
        originalTeamName = current.awayName;
      }
    }

    if (!conflict) {
      return true;
    }

    e.preventDefault();

    var conflictTeamName = conflict.side === 'home' ? conflict.game.homeName : conflict.game.awayName;
    var opponentName = conflict.side === 'home' ? conflict.game.awayName : conflict.game.homeName;

    // Game B keeps its own date/time; only the conflicting slot's team changes
    var gameBHomeName = conflict.side === 'home' ? originalTeamName : conflict.game.homeName;
    var gameBAwayName = conflict.side === 'away' ? originalTeamName : conflict.game.awayName;

    swapModal.find('#swapConfirmIntro').text(
      conflictTeamName + ' is already scheduled this week (vs ' + opponentName + ', ' +
      conflict.game.dateLabel + ' ' + conflict.game.timeLabel + '). Swap the teams?'
    );

    swapModal.find('#cancelSwapBtn').text('No, just update for ' + conflictTeamName);

    var editDate = modal.find('#editDate').val();
    var editTime = modal.find('#editTime').val();

    swapModal.find('#swapConfirmPreview').empty()
      .append($('<li>').text(
        newHomeName + ' vs ' + newAwayName + ' — ' + formatDateLabel(editDate) + ' ' + formatTimeLabel(editTime)
      ))
      .append($('<li>').text(
        gameBHomeName + ' vs ' + gameBAwayName + ' — ' + conflict.game.dateLabel + ' ' + conflict.game.timeLabel
      ));

    pendingSwap = {
      scheduleID: conflict.game.scheduleID,
      side: conflict.side,
      originalTeamID: originalTeamID
    };

    swapModal.modal('show');
  });

  swapModal.on('click', '#confirmSwapBtn', function() {
    if (!pendingSwap) return;

    modal.find('#swapScheduleID').val(pendingSwap.scheduleID);
    modal.find('#swapSide').val(pendingSwap.side);
    modal.find('#swapOriginalTeamID').val(pendingSwap.originalTeamID);

    swapModal.modal('hide');
    form.data('swapConfirmed', true);
    form.submit();
  });

  // Proceed with the plain edit as selected, leaving the conflicting game untouched (double-booking allowed)
  swapModal.on('click', '#cancelSwapBtn', function() {
    modal.find('#swapScheduleID').val('');
    modal.find('#swapSide').val('');
    modal.find('#swapOriginalTeamID').val('');

    swapModal.modal('hide');
    form.data('swapConfirmed', true);
    form.submit();
  });
});
