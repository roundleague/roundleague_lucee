$(document).ready(function () {
    // Check if the element with ID "playerGameLogTable" exists
    if ($('#playerGameLogTable').length) {
        // If the element exists, perform the animation
        $('html, body').animate({
            scrollTop: $('#playerGameLogTable').offset().top
        }, 'slow');
    }
});
