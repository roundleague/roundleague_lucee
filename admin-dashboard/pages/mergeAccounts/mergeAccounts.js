var keepPlayer = null;
var mergePlayer = null;

// --- Autocomplete for KEEP player ---
document.getElementById('searchKeep').addEventListener('input', function() {
  searchPlayer(this.value, 'keep');
});

// --- Autocomplete for MERGE player ---
document.getElementById('searchMerge').addEventListener('input', function() {
  searchPlayer(this.value, 'merge');
});

function searchPlayer(query, role) {
  var dropdownId = role === 'keep' ? 'dropdownKeep' : 'dropdownMerge';
  var dropdown = document.getElementById(dropdownId);

  if (query.length < 2) {
    dropdown.innerHTML = '';
    return;
  }

  $.ajax({
    url: 'getPlayerSearch.cfm',
    method: 'GET',
    data: { q: query },
    dataType: 'json',
    success: function(response) {
      dropdown.innerHTML = '';
      if (!response.players || response.players.length === 0) {
        dropdown.innerHTML = '<div class="autocomplete-result" style="color:#999;">No players found</div>';
        return;
      }
      response.players.forEach(function(player) {
        var div = document.createElement('div');
        div.className = 'autocomplete-result';
        div.innerHTML = '<strong>' + escapeHtml(player.playerName) + '</strong> <span style="color:#888;font-size:12px;">' + escapeHtml(player.email) + '</span>';
        div.addEventListener('click', function() {
          selectPlayer(player, role);
        });
        dropdown.appendChild(div);
      });
    }
  });
}

function selectPlayer(player, role) {
  var dropdownId = role === 'keep' ? 'dropdownKeep' : 'dropdownMerge';
  var searchId   = role === 'keep' ? 'searchKeep'   : 'searchMerge';
  var badgeId    = role === 'keep' ? 'badgeKeep'     : 'badgeMerge';
  var badgeText  = role === 'keep' ? 'badgeKeepText' : 'badgeMergeText';

  document.getElementById(dropdownId).innerHTML = '';
  document.getElementById(searchId).value = '';

  if (role === 'keep') {
    keepPlayer = player;
  } else {
    mergePlayer = player;
  }

  var badge = document.getElementById(badgeId);
  document.getElementById(badgeText).textContent = player.playerName + ' (' + player.email + ')';
  badge.classList.add('show');

  checkBothSelected();
}

function clearPlayer(role) {
  var searchId = role === 'keep' ? 'searchKeep' : 'searchMerge';
  var badgeId  = role === 'keep' ? 'badgeKeep'  : 'badgeMerge';

  if (role === 'keep') {
    keepPlayer = null;
  } else {
    mergePlayer = null;
  }

  document.getElementById(searchId).value = '';
  document.getElementById(badgeId).classList.remove('show');
  checkBothSelected();
}

function checkBothSelected() {
  var btn = document.getElementById('previewBtn');
  if (keepPlayer && mergePlayer) {
    btn.style.display = 'inline-block';
    if (keepPlayer.playerID === mergePlayer.playerID) {
      btn.disabled = true;
      btn.title = 'Cannot merge a player into themselves';
    } else {
      btn.disabled = false;
      btn.title = '';
    }
  } else {
    btn.style.display = 'none';
  }
}

// --- Preview merge ---
document.getElementById('previewBtn').addEventListener('click', function() {
  if (!keepPlayer || !mergePlayer) return;
  loadPreview(keepPlayer.playerID, mergePlayer.playerID);
  $('#mergeModal').modal('show');
});

function loadPreview(keepID, mergeID) {
  $('#previewContent').html('<div class="text-center" style="padding:30px;"><i class="fa fa-spinner fa-spin"></i> Loading...</div>');
  $('#swapSection').hide();
  $('#confirmMergeBtn').hide();

  $.ajax({
    url: 'mergeAccounts-preview.cfm',
    method: 'GET',
    data: { keepPlayerID: keepID, mergePlayerID: mergeID },
    success: function(html) {
      $('#previewContent').html(html);
      $('#swapSection').show();
      $('#confirmMergeBtn').show();
      // Reset swap radios
      document.getElementById('swapNo').checked = true;
    },
    error: function() {
      $('#previewContent').html('<div class="alert alert-danger">Failed to load preview.</div>');
    }
  });
}

// --- Swap players ---
$('input[name="swapPlayers"]').on('change', function() {
  if (this.value === 'yes') {
    // Swap in memory
    var tmp = keepPlayer;
    keepPlayer = mergePlayer;
    mergePlayer = tmp;
    loadPreview(keepPlayer.playerID, mergePlayer.playerID);
    // Reset radio after reload
    setTimeout(function() {
      document.getElementById('swapNo').checked = true;
    }, 100);
  }
});

// --- Confirm merge ---
document.getElementById('confirmMergeBtn').addEventListener('click', function() {
  if (!keepPlayer || !mergePlayer) return;

  var btn = this;
  btn.disabled = true;
  btn.textContent = 'Merging...';

  $.ajax({
    url: 'mergeAccounts-save.cfm',
    method: 'POST',
    data: {
      keepPlayerID:  keepPlayer.playerID,
      mergePlayerID: mergePlayer.playerID
    },
    dataType: 'json',
    success: function(response) {
      if (response.success) {
        $('#mergeModal').modal('hide');
        showToast('Accounts merged successfully!');
        // Clear both selections
        clearPlayer('keep');
        clearPlayer('merge');
        keepPlayer = null;
        mergePlayer = null;
        document.getElementById('previewBtn').style.display = 'none';
      } else {
        $('#previewContent').prepend('<div class="alert alert-danger"><strong>Error:</strong> ' + escapeHtml(response.message || 'Unknown error') + '</div>');
      }
    },
    error: function() {
      $('#previewContent').prepend('<div class="alert alert-danger">Server error. Please try again.</div>');
    },
    complete: function() {
      btn.disabled = false;
      btn.textContent = 'Confirm Merge';
    }
  });
});

function showToast(message) {
  var snackbar = document.getElementById('snackbar');
  snackbar.textContent = message;
  snackbar.className = 'show';
  setTimeout(function() {
    snackbar.className = snackbar.className.replace('show', '');
  }, 3500);
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Close dropdowns when clicking outside
document.addEventListener('click', function(e) {
  if (!e.target.closest('#searchKeep') && !e.target.closest('#dropdownKeep')) {
    document.getElementById('dropdownKeep').innerHTML = '';
  }
  if (!e.target.closest('#searchMerge') && !e.target.closest('#dropdownMerge')) {
    document.getElementById('dropdownMerge').innerHTML = '';
  }
});
