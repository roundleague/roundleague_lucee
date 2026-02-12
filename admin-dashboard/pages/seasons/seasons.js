$(document).ready(function () {
  var newDivisionCounter = 0;

  // Add a new season
  $(".saveSeasonsBtn").click(function () {
    $("#newSeasonsForm").submit();
  });

  // Toggle division mapping section based on checkbox
  $("#copyDivisions").on("change", function () {
    if ($(this).is(":checked")) {
      $("#divisionMappingSection").show();
    } else {
      $("#divisionMappingSection").hide();
    }
  });

  // Add new division button
  $("#addNewDivisionBtn").on("click", function () {
    newDivisionCounter++;
    var newRow =
      '<div class="new-division-row" style="display: flex; align-items: center; margin-bottom: 8px;" data-new-id="' +
      newDivisionCounter +
      '">' +
      '<input type="text" class="form-control new-division-name" placeholder="New Division Name" style="flex: 1; font-size: 14px; padding: 5px;">' +
      '<button type="button" class="btn btn-sm btn-link remove-new-division" style="color: #dc3545;">&times;</button>' +
      "</div>";
    $("#newDivisionsList").append(newRow);
  });

  // Remove new division
  $(document).on("click", ".remove-new-division", function () {
    $(this).closest(".new-division-row").remove();
  });

  // Progress to next season
  $(".progressionBtn").click(function () {
    const progressSeasonID = $(".progressSeasonBtn").data("value");
    $(".progressToSeasonId").val(progressSeasonID);

    // Copy the checkbox value to the hidden field
    const copyDivisions = $("#copyDivisions").is(":checked") ? "1" : "0";
    $(".copyDivisionsField").val(copyDivisions);

    // Collect division mappings
    if (copyDivisions === "1") {
      var mappings = {
        existingDivisions: [],
        newDivisions: [],
      };

      // Collect existing divisions (only if copy checkbox is checked)
      $(".division-row").each(function () {
        var $row = $(this);
        var $checkbox = $row.find(".division-copy-checkbox");
        var $nameInput = $row.find(".division-new-name");

        if ($checkbox.is(":checked")) {
          mappings.existingDivisions.push({
            divisionID: $checkbox.data("division-id"),
            originalName: $nameInput.data("original-name"),
            newName: $nameInput.val().trim(),
            copy: true,
          });
        } else {
          mappings.existingDivisions.push({
            divisionID: $checkbox.data("division-id"),
            originalName: $nameInput.data("original-name"),
            newName: "",
            copy: false,
          });
        }
      });

      // Collect new divisions to create
      $(".new-division-name").each(function () {
        var name = $(this).val().trim();
        if (name) {
          mappings.newDivisions.push({
            newName: name,
          });
        }
      });

      $("#divisionMappingsField").val(JSON.stringify(mappings));
    }

    $("#progressSeasonForm").submit();
  });
});
