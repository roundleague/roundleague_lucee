$(document).ready(function () {
	$('#teamPhoneField').keyup(function () {
		$(this).val($(this).val().replace(/(\d{3})\-?(\d{3})\-?(\d{4})/, '$1-$2-$3'));
	});

	$('.referralRadio').on('change', function () {
		if ($(this).val() === 'Other' && $(this).is(':checked')) {
			$('#referralOtherItem').show();
		} else {
			$('#referralOtherItem').hide();
			$('#referralOtherInput').val('');
		}
	});

	$('.saveBtn').closest('form').on('submit', function () {
		var missing = [];

		if (!$('input[name="selectedDivision"]:checked').length) missing.push('League');
		if (!$('input[name="allPlayersOver18"]:checked').length) missing.push('Over 18 confirmation');
		if (!$('input[name="playerCountEstimate"]:checked').length) missing.push('Player Count');
		if (!$('input[name="highestLevel"]:checked').length) missing.push('Level of Experience');
		if (!$('input[name="referralSource"]:checked').length) missing.push('How you heard about us');

		if (missing.length) {
			$('.errorMessage').text('Please fill out all required fields: ' + missing.join(', '));
			return false;
		}

		$('.errorMessage').text('');
		return true;
	});
});
