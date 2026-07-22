$( document ).ready(function() {
	$('.bootstrap-switch-handle-on').text('Yes');
	$('.bootstrap-switch-handle-off').text('No');
	$('.bootstrap-switch-label').html('<i class="fa-solid fa-basketball slider-basketball-icon"></i>');

	function updateSubmitState() {
		var waiverCount = $('.waiverCheck:checked').length;
		var isUnder18 = !$('[name="over18"]').is(':checked');
		var guardianOk = !isUnder18 || $('#guardianAck').is(':checked');
		$('.saveBtn').prop('disabled', !(waiverCount === 2 && guardianOk));
	}

	$('.waiverCheck, #guardianAck').on('click', updateSubmitState);

	$('[name="over18"]').on('switchChange.bootstrapSwitch', function(event, state) {
		if (!state) {
			$('#guardianAckItem').show();
		} else {
			$('#guardianAckItem').hide();
			$('#guardianAck').prop('checked', false);
		}
		updateSubmitState();
	});

	$('#phoneField').keyup(function(){
	    $(this).val($(this).val().replace(/(\d{3})\-?(\d{3})\-?(\d{4})/,'$1-$2-$3'))
	});

	// Custom Validation of form controls
	$('.saveBtn').click(function(){
		let highestLevel = $('input[name="highestLevel"]:checked').val();
		let position = $('input[name="position"]:checked').val();
		let gender = $('.gender').val();
		let seasonSelect = $('.seasonSelect').val();
		let registerTeam = $('.teamID').val();

		if(highestLevel && position && gender.length && seasonSelect.length){
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