// A $( document ).ready() block.
$( document ).ready(function() {
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
});