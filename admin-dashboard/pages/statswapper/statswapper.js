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
  var gameSelector = document.getElementById('gameSelector');
  gameSelector.innerHTML = '';

  // Make an AJAX request to fetch game data based on playerID
  $.ajax({
    url: 'getPlayerGames.cfm',
    method: 'GET',
    data: { playerID: playerID },
    dataType: 'json',
    success: function(response) {
      games = response.games || [];
      games.forEach(function(game) {
        var option = document.createElement('option');
        option.value = game.playerGameLogID;

        const dateOptions = {
          year: '2-digit',
          month: '2-digit',
          day: '2-digit'
        };

        const gameDate = new Date(game.date)
        const formattedDate = gameDate.toLocaleDateString('en-US', dateOptions);

        option.textContent = 'Week' + ' ' + game.week + ': ' + game.homeTeam + ' vs. ' + game.awayTeam + ' - ' + formattedDate;
        gameSelector.appendChild(option);

    // populate stats table
    var statsTable = document.querySelector('.statsTable');
    var pointsElement = statsTable.querySelector('.points');
    var reboundsElement = statsTable.querySelector('.rebounds');
    var assistsElement = statsTable.querySelector('.assists');
    pointsElement.textContent = game.points;
    reboundsElement.textContent = game.rebounds;
    assistsElement.textContent = game.assists;

    // populate statsConfirm table
    var statsTableConfirm = document.querySelector('.statsTableConfirm');
    var pointsElement = statsTableConfirm.querySelector('.points');
    var reboundsElement = statsTableConfirm.querySelector('.rebounds');
    var assistsElement = statsTableConfirm.querySelector('.assists');
    pointsElement.textContent = game.points;
    reboundsElement.textContent = game.rebounds;
    assistsElement.textContent = game.assists;
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

function populateStatsTable() {
  var gameSelector = document.getElementById('gameSelector');
  var selectedGameId = gameSelector.value;

  var selectedGame = findGameById(games, selectedGameId);

  if (selectedGame) {
    var statsTable = document.querySelector('.statsTable');
    var pointsElement = statsTable.querySelector('.points');
    var reboundsElement = statsTable.querySelector('.rebounds');
    var assistsElement = statsTable.querySelector('.assists');

    pointsElement.textContent = selectedGame.points;
    reboundsElement.textContent = selectedGame.rebounds;
    assistsElement.textContent = selectedGame.assists;

    // populate statsConfirm table
    var statsTableConfirm = document.querySelector('.statsTableConfirm');
    var pointsElement = statsTableConfirm.querySelector('.points');
    var reboundsElement = statsTableConfirm.querySelector('.rebounds');
    var assistsElement = statsTableConfirm.querySelector('.assists');
    pointsElement.textContent = selectedGame.points;
    reboundsElement.textContent = selectedGame.rebounds;
    assistsElement.textContent = selectedGame.assists;
  } else {
    // Handle the case when no matching game is found
    console.error('No matching game found for selectedGameID:', selectedGameId);
  }
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
  var playerFrom = $('#searchBox').val();
  var playerTo = $('#searchBoxTo').val();
  $('.playerFromConfirmText').text(playerFrom);
  $('.playerToConfirmText').text(playerTo);
});

// Confirm button clicked
$('.confirmBtn').click(function(){
      const playerFrom = $('#searchBox').data('playerid');
      const playerTo = $('#searchBoxTo').data('playerid');
      const playerGameLogID = $('#gameSelector').val();
      $('.fromPlayer').val(playerFrom);
      $('.toPlayer').val(playerTo);
      $('.playerGameLogID').val(playerGameLogID);
      $('.statSwapForm').submit();
});

// Get the snackbar DIV
var x = document.getElementById("snackbar");

// Add the "show" class to DIV
x.className = "show";

// After 3 seconds, remove the show class from DIV
setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);