$( document ).ready(function() {
	$('.bootstrap-switch-handle-on').text('Yes');
	$('.bootstrap-switch-handle-off').text('No');

	$('.waiverCheck').click(function(){
		var checkBoth = $('.waiverCheck:checkbox:checked').length;
		if(checkBoth == 2){
			$('.saveBtn').prop('disabled', false);
		}
		else{
			$('.saveBtn').prop('disabled', true);
		}
	});

	$('#phoneField').keyup(function(){
	    $(this).val($(this).val().replace(/(\d{3})\-?(\d{3})\-?(\d{4})/,'$1-$2-$3'))
	});

	// Custom Validation of form controls
	$('.saveBtn').click(function(){
		let highestLevel = $('input[name="highestLevel"]:checked').val();
		let FullyVaccinated = $('input[name="FullyVaccinated"]:checked').val();
		let position = $('input[name="position"]:checked').val();
		if(highestLevel && FullyVaccinated && position){
			$('.errorMessage').text("");
			return true;
		}
		else{
			$('.errorMessage').text("Please fill out Basketball Experience, COVID 19 Vaccination Status, and Position.");
			return false;
		}
	});

	
});