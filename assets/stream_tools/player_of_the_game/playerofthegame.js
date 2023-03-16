$( document ).ready(function() {

	$('.name').change(function() {
		var nameInput = $('.name').val();
		$('.player-name').text(nameInput);
	})

	$('.categoryName1').change(function() {
		var input = $('.categoryName1').val();
		$('.category1').text(input);
	})

	$('.categoryValue1').change(function() {
		var input = $('.categoryValue1').val();
		$('.cValue1').text(input);
	})

	$('.categoryName2').change(function() {
		var input = $('.categoryName2').val();
		$('.category2').text(input);
	})

	$('.categoryValue2').change(function() {
		var input = $('.categoryValue2').val();
		$('.cValue2').text(input);
	})

	$('.categoryName3').change(function() {
		var input = $('.categoryName3').val();
		$('.category3').text(input);
	})

	$('.categoryValue3').change(function() {
		var input = $('.categoryValue3').val();
		$('.cValue3').text(input);
	})
});