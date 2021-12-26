// A $( document ).ready() block.
$( document ).ready(function() {

	var showSnackbar = true;

	$('.teamSelect').on('change', function() {
	  const scheduleId = $('.scheduleSelect').val();
	  if(scheduleId != null){
		$('.scheduleSelect')
		    .find('option')
		    .remove()
		    .end()
	  }
	  $('#mainForm').submit();
	});

	  /* Only show snackbar if no team selected (along with URL cfif) */
	  if($('#Team').val() == ''){
		  // Get the snackbar DIV
		  var x = document.getElementById("snackbar");

		  // Add the "show" class to DIV
		  x.className = "show";

		  // After 3 seconds, remove the show class from DIV
		  setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
	  }
});