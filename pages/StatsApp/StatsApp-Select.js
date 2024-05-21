// A $( document ).ready() block.
$(document).ready(function() {

    var showSnackbar = true;

    $('.teamSelect').on('change', function() {
        const scheduleId = $('.scheduleSelect').val();
        if (scheduleId != null) {
            $('.scheduleSelect')
                .find('option')
                .remove()
                .end()
        }
        $('#mainForm').submit();
    });

    function updateBracketInfo() {
        var selectedOption = $('.scheduleSelect').find(':selected');
        var isPlayoffs = selectedOption.data('playoffs');
        $('.isPlayoffsValue').val(isPlayoffs);

        var BracketGameID = selectedOption.data('bracketgameid');
        $('.BracketGameID').val(BracketGameID);

        var BracketRoundID = selectedOption.data('bracketroundid');
        $('.BracketRoundID').val(BracketRoundID);

        var Playoffs_BracketID = selectedOption.data('bracketid');
        $('.Playoffs_BracketID').val(Playoffs_BracketID);
    }

    // Call the function on page load
    updateBracketInfo();

    // Call the function on change event
    $('.scheduleSelect').on('change', function() {
        updateBracketInfo();
    });

    /* Only show snackbar if no team selected (along with URL cfif) */
    if ($('#Team').val() == '') {
        // Get the snackbar DIV
        var x = document.getElementById("snackbar");

        // Add the "show" class to DIV
        x.className = "show";

        // After 3 seconds, remove the show class from DIV
        setTimeout(function() { x.className = x.className.replace("show", ""); }, 3000);
    }
});