$( document ).ready(function() {
	$('#signPlayerTable').DataTable();

	/* Snackbar */
	  var x = document.getElementById("snackbar");

	  // Add the "show" class to DIV
	  if(x){
		  x.className = "show";

		  // After 3 seconds, remove the show class from DIV
		  setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
	  }
});