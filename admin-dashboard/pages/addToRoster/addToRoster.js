function fetchResults() {
  var searchBox = document.getElementById('searchBox');
  var query = searchBox.value.toLowerCase();
  var autocompleteResults = document.getElementById('autocompleteResults');

  if (query.length > 2) {
    var filteredResults = playerList.filter(function(player) {
      return player.playerName.toLowerCase().indexOf(query) !== -1;
    });

    showResults(filteredResults);
  } else {
    clearResults();
  }
}


function showResults(results) {
  var autocompleteResults = document.getElementById('autocompleteResults');
  autocompleteResults.innerHTML = '';

  results.forEach(function(result) {
    var div = document.createElement('div');
    div.textContent = result.playerName + ' - ' + result.playerTeam;
    div.className = 'autocomplete-result';
    div.addEventListener('click', function() {
      selectResult(div.textContent, result.playerID);
    });
    autocompleteResults.appendChild(div);
  });
}


function selectResult(playerNameTeam, playerID) {
  document.getElementById('searchBox').value = playerNameTeam;
  document.getElementById('searchBox').setAttribute('data-playerid', playerID);
  $('.selectGame').show();
  $('.statsTableWrapper').show();
  clearResults();
  populateGameSelector(playerID);
}

function clearResults() {
  var autocompleteResults = document.getElementById('autocompleteResults');
  autocompleteResults.innerHTML = '';
}

var games = [];

function populateGameSelector(playerID) {
  var gameSelector = document.getElementById('teamSelector');
  gameSelector.innerHTML = '';

  // Make an AJAX request to fetch game data based on playerID
  $.ajax({
    url: 'getActiveTeams.cfm',
    method: 'GET',
    data: { playerID: playerID },
    dataType: 'json',
    success: function(response) {
      games = response.games || [];
      games.forEach(function(game) {
        var option = document.createElement('option');
        option.value = game.teamID;

        option.textContent = game.teamName;
        gameSelector.appendChild(option);
      });
    },
    error: function(xhr, status, error) {
      console.error('Error fetching game data:', error);
    }
  });
}

function findGameById(games, playerGameLogID) {
  return games.find(function(game) {
    return game.playerGameLogID == playerGameLogID;
  });
}

// Function to fetch results for the "Player to move stats to" input
function fetchResultsTo() {
  var searchBoxTo = document.getElementById('searchBoxTo');
  var autocompleteResultsTo = document.getElementById('autocompleteResultsTo');
  var inputValue = searchBoxTo.value.trim();

  if (inputValue !== '') {
    var filteredResults = playerList.filter(function(player) {
      return player.playerName.toLowerCase().includes(inputValue.toLowerCase());
    });

    showResultsTo(filteredResults);
  } else {
    clearResultsTo();
  }
}

// Function to show autocomplete results for the specified input element
function showResultsTo(results) {
  var autocompleteResults = document.getElementById('autocompleteResultsTo');
  autocompleteResults.innerHTML = '';

  results.forEach(function(result) {
    var div = document.createElement('div');
    div.textContent = result.playerName + ' - ' + result.playerTeam;
    div.className = 'autocomplete-result';
    div.addEventListener('click', function() {
      selectResultTo(div.textContent, result.playerID);
    });
    autocompleteResults.appendChild(div);
  });
}

function clearResultsTo() {
  var autocompleteResults = document.getElementById('autocompleteResultsTo');
  autocompleteResults.innerHTML = '';
}

function selectResultTo(playerNameTeam, playerID) {
  document.getElementById('searchBoxTo').value = playerNameTeam;
  document.getElementById('searchBoxTo').setAttribute('data-playerid', playerID);
  clearResultsTo();
} 

$('.modalBtn').click(function(){
  $('.errorMsg').hide();
  var playerFrom = $('#searchBox').val();

  var selectElement = document.getElementById("teamSelector");
  var teamName = selectElement.options[selectElement.selectedIndex].text;

  $('.playerFromConfirmText').text(playerFrom);
  $('.teamToConfirm').text(teamName);
});

// Confirm button clicked
$('.confirmBtn').click(function(){
  const playerFrom = $('#searchBox').data('playerid');
  var selectElement = document.getElementById("teamSelector");
  var teamID = selectElement.value;

  if(!playerFrom || !teamID) {
    $('.errorMsg').show();
    return false;
  }

  const playerGameLogID = $('#teamSelector').val();
  $('.playerID').val(playerFrom);
  $('.newTeamID').val(teamID);
  $('.addToRosterForm').submit();
});

// Get the snackbar DIV
var x = document.getElementById("snackbar");

// Add the "show" class to DIV
if(x){
  x.className = "show";
  // After 3 seconds, remove the show class from DIV
  setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
}