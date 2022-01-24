$( document ).ready(function() {

	var removePlayerID;

	$('.removeBtn').click(function(){
		var playerName = $(this).data("name");
		removePlayerID = $(this).data("playerid");
		$(".playerName").text(playerName);
	});

	$('.confirmRemoveBtn').click(function(){
		$(".editRosterForm").append("<input type='hidden' name='removePlayer' value='"+removePlayerID+"'>");
		$(".editRosterForm").submit();
	});

	  // Get the snackbar DIV
	  var x = document.getElementById("snackbar");

	  // Add the "show" class to DIV
	  x.className = "show";

	  // After 3 seconds, remove the show class from DIV
	  setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
});