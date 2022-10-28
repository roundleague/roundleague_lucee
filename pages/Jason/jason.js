$( document ).ready(function() {
	console.log("Sheeeeeeeeeeeesh");

	$('.deleteBtn').click(function(){
		var dataValue = $(this).data('value');
		console.log("dataValue", dataValue);
		$('.deletePlayerID').val(dataValue);
	})

	$('.updateBtn').click(function(){
		var updateValue = $(this).data('value');
		console.log("dataValue", updateValue);
		$('.updatePlayerID').val(updateValue);
	})
});