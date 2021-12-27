/* Are you sure window when navigating away */
window.onbeforeunload = function (e) {
	var homeScore = $('input[name="homeScore"]').val();
	console.log('homeScore', homeScore);
	if(homeScore == 0){
	    e = e || window.event;

	    // For IE and Firefox prior to version 4
	    if (e) {
	        e.returnValue = 'Any string';
	    }

	    // For Safari
	    return 'Any string';
	}
};