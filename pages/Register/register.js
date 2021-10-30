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
});