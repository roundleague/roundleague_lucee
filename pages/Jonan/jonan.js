$( document ).ready(function() {
	console.log("ggs");
	$('.deleteBtn').click(function(){
		var dataValue = $(this).data('value');
		console.log("dataValue", dataValue);
		$('.deletePlayerID').val(dataValue);
	})
	$('.updateBtn').click(function(){
		var updateValue = $(this).data('value');
		console.log("updateValue", updateValue);
		$('.updatePlayerID').val(updateValue);

	})
	
});
