$( document ).ready(function() {
	// Add a new season
	$('.saveSeasonsBtn').click(function(){
		$('#newSeasonsForm').submit();
	});

	// Progress to next season
	$('.progressionBtn').click(function(){
		const progressSeasonID = $('.progressSeasonBtn').data('value')
		$('.progressToSeasonId').val(progressSeasonID);
		$('#progressSeasonForm').submit();
	});
});