$( document ).ready(function() {
	$(".registerBtn").click(function(){
		var createPassword = $('.createPassword').val();
		var confirmPassword = $('.confirmPassword').val();
		if(createPassword != confirmPassword){
			$('.invalidMsg').text('Passwords do not match!');
			return false;
		}
	});
});