$(document).ready(function () {
    // Check if the element with ID "playerGameLogTable" exists
    if ($('#playerGameLogTable').length) {
        // If the element exists, perform the animation
        $('html, body').animate({
            scrollTop: $('#playerGameLogTable').offset().top
        }, 'slow');
    }
    
    // Career Stats Toggle Functionality
    $('#toggleSeasonsBtn').on('click', function() {
        var hiddenRows = $('.season-row-hidden');
        var visibleRows = $('.season-row-visible');
        var toggleText = $('#toggleText');
        var toggleIcon = $('#toggleIcon');
        
        if (hiddenRows.length > 0) {
            // Show additional seasons - remove hidden class and add visible class
            hiddenRows.removeClass('season-row-hidden').addClass('season-row-visible');
            toggleText.text('Show Less');
            toggleIcon.addClass('rotated');
        } else if (visibleRows.length > 0) {
            // Hide additional seasons - remove visible class and add hidden class
            visibleRows.removeClass('season-row-visible').addClass('season-row-hidden');
            toggleText.text('Show All Seasons');
            toggleIcon.removeClass('rotated');
        }
    });
});
