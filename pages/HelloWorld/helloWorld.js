$('.helloWorldBtn_FE').click(function(){
	console.log("Hello World - FE");
	$('.textRender_FE').text("Hello World");
});

$('.helloWorldBtn_BE').click(function(){
	$.ajax({
	  type: "GET",
	  url: "/library/teams.cfc?method=getHelloWorld",
	  cache: false,
	  dataType: "JSON",
	  success: function(data){
	  	 console.log(data + " - BE");
		$('.textRender_BE').text(data);
	  }
	});
});