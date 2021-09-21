// A $( document ).ready() block.
$( document ).ready(function() {

	$( ".button-success" ).click(function() {
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").text());
		var newFieldValue = fieldValue + 1;
		fieldValueSpan.text(newFieldValue);
	});

	$( ".button-error" ).click(function() {
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").text());
		var newFieldValue = fieldValue - 1;
		if(newFieldValue >= 0) {
			fieldValueSpan.text(newFieldValue);
		}
	});

});