// A $( document ).ready() block.
$( document ).ready(function() {

	$( ".button-success" ).click(function() {
		var playerID = $(this).closest('tr').attr('id');
		console.log("playerID" + playerID);
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").val());
		var newFieldValue = fieldValue + 1;
		fieldValueSpan.val(newFieldValue);

		if($(this).hasClass("FGM")){
			addToValue("FGA", 1, playerID);
			addToValue("PTS", 2, playerID);
		}
		else if($(this).hasClass("3FGM")){
			addToValue("FGM", 1, playerID);
			addToValue("FGA", 1, playerID);
			addToValue("3FGA", 1, playerID);
			addToValue("PTS", 3, playerID);
		}
		else if($(this).hasClass("3FGA")){
			addToValue("FGA", 1, playerID);
		}
		else if($(this).hasClass("FTM")){
			addToValue("PTS", 1, playerID);
			addToValue("FTA", 1, playerID);
		}
	});

	$( ".button-error" ).click(function() {
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").val());
		var newFieldValue = fieldValue - 1;
		if(newFieldValue >= 0) {
			fieldValueSpan.val(newFieldValue);

			if($(this).hasClass("FGM")){
				addToValue("PTS", -2);
			}
		}
	});

	function addToValue(id, addValue, playerID){
		var fieldValueSpan = $("#"+playerID).find("#"+id);
		console.log("playerID: " + playerID);
		console.log("id: " + id);
		console.log(fieldValueSpan);
		var fieldValue = parseInt(fieldValueSpan.val());
		var newFieldValue = fieldValue + addValue;
		fieldValueSpan.val(newFieldValue);
	}

});