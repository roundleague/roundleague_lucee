$( document ).ready(function() {

	 $(document).keydown(function(e) {
		switch (e.which) {
		 case 97:
		 case 49:
		 	addToValue("team1", 1); // 1
		   	break;
		 case 98:
		 case 50:
		   	addToValue("team2", 1); // 2
		   	break;
		 case 99:
		 case 51:
		 	addToValue("team1", -1); // 3
		   	break;
		 case 100:  	
		 case 52:
		   	addToValue("team2", -1); // 4
		   	break;
		 case 101:  	
		 case 53:
		   	pauseTimer(); // 5
		   	break;
		 case 102:  	
		 case 54:
		   	resumeTimer(); // 6
		   	break;
		 case 103:  	
		 case 55:
		   	addToValue("quarterNum", 1); // 7
		   	break;
		}
	 });

	function addToValue(className, addValue){
		var fieldValueSpan = $("."+className);
		var fieldValue = parseInt(fieldValueSpan.text());

		var newFieldValue = fieldValue + addValue;
		fieldValueSpan.text(newFieldValue);
	}

});