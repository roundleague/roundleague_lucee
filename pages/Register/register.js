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
		let gender = $('.gender').val();
		let seasonSelect = $('.seasonSelect').val();
		let registerTeam = $('.teamID').val();

		if(highestLevel && FullyVaccinated && position && gender.length && seasonSelect.length){
			$('.errorMessage').text("");
		}
		else{
			$('.errorMessage').text("Please fill out all required fields.");
			return false;
		}

		if(registerTeam == ""){
			$('.teamID').addClass('registerRequired');
			$('.teamID').focus();
			$('.errorMessage').text("Please select your team.");
			return false;
		}

		return true;
	});

	
});