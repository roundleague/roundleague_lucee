$(document).ready(function() {
    var removePlayerID;

    $(document).on('click', '.removeBtn', function() {
        var playerName = $(this).data("name");
        removePlayerID = $(this).data("playerid");
        $(".playerName").text(playerName);
    });

    $(document).on('click', '.confirmRemoveBtn', function() {
        $(".editRosterForm").append("<input type='hidden' name='removePlayer' value='" + removePlayerID + "'>");
        $(".editRosterForm").submit();
    });

    $(document).on('click', '#editHeaderBtn', function() {
        var $headerText = $('#headerTextValue');
        var headerText = $headerText.text();
        var $headerInput = $('<input id="headerInput" type="text">');
        var $editHeaderBtn = $(this); // Reference to the edit button
        $headerInput.val(headerText);
        $headerInput.css('text-align', 'center'); // Add this line to center-align the text in the input box
        $headerText.replaceWith($headerInput);
        $editHeaderBtn.hide(); // Hide the edit button when the input box appears
        $headerInput.focus();

        $headerInput.keypress(function(e) {
            if (e.which === 13) {
                e.preventDefault();
                $headerInput.blur();
            }
        });

        $headerInput.blur(function() {
            var newHeaderText = $(this).val();
            $headerInput.replaceWith('<span id="headerTextValue">' + newHeaderText + '</span>');
            $editHeaderBtn.show(); // Show the edit button after editing the text
        });
    });

    $(window).on('load', function() {
        var $snackbar = $('#snackbar');
        if ($snackbar.length) {
            $snackbar.addClass("show");
            setTimeout(function() {
                $snackbar.removeClass("show");
            }, 3000);
        }
    });
});
