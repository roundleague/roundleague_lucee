<!DOCTYPE html>
<html>
<head>
	<script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/purecss@3.0.0/build/pure-min.css" integrity="sha384-X38yfunGUhNzHpBaEBsWLO+A0HDYOQi8ufWDkZ0k9e0eXz/tH3II7uKZ9msv++Ls" crossorigin="anonymous">
	<link href="playerofthegame.css?v=1.0" rel="stylesheet">
	<script src="playerofthegame.js"></script>

	<title>NBA Statline Graphic</title>
</head>
<body>
	<div class="statline">
		<div class="player-info">
			<div class="player-name">LeBron James #3</div>
		</div>
		<div class="stats">
			<div class="stat">
				<div class="team-logo">
					<img src="/assets/img/Logos/6.png">
				</div>
			</div>
			<div class="stat">
				<div class="stat-header category1">Points</div>
				<div class="stat-value cValue1">30</div>
			</div>
			<div class="stat">
				<div class="stat-header category2">Rebounds</div>
				<div class="stat-value cValue2">10</div>
			</div>
			<div class="stat">
				<div class="stat-header category3">Assists</div>
				<div class="stat-value cValue3">8</div>
			</div>
		</div>
	</div>

	<form class="pure-form pure-form-stacked">
		<fieldset>
			<legend>Player of the Game Inputs</legend>
			<label for="stacked-email">Name</label>
			<input class="name" type="text" placeholder="First Name Last Name #3" />

			<label for="stacked-password">Stat 1</label>
			<input class="categoryName1" type="text" placeholder="Stats Category" />
			<input class="categoryValue1" type="text" placeholder="VALUE" />

			<label for="stacked-password">Stat 2</label>
			<input class="categoryName2" type="text" placeholder="Stats Category" />
			<input class="categoryValue2" type="text" placeholder="VALUE" />

			<label for="stacked-password">Stat 3</label>
			<input class="categoryName3" type="text" placeholder="Stats Category" />
			<input class="categoryValue3" type="text" placeholder="VALUE" />
		</fieldset>
	</form>

</body>
</html>
