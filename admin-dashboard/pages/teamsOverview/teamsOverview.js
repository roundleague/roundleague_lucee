$(document).ready(function () {
  var activeTable = $("#teamsOverviewTable").DataTable();
  var pendingTable = $("#pendingTeamsTable").DataTable();
  var inactiveTable = $("#inactiveTeamsTable").DataTable();
  var rejectedTable = $("#rejectedTeamsTable").DataTable();

  // DataTables mis-sizes columns when initialized inside a hidden Bootstrap tab pane
  $('a[data-toggle="tab"]').on("shown.bs.tab", function () {
    activeTable.columns.adjust();
    pendingTable.columns.adjust();
    inactiveTable.columns.adjust();
    rejectedTable.columns.adjust();
  });

  $(document).on("change", ".statusSelect", function () {
    console.log("Update Status");

    /* Get and set form variables for ajax call */
    var newStatus = $(this).val();
    var teamID = $(this).data("value");

    console.log("newStatus", newStatus);
    console.log("teamID", teamID);

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=updateTeamStatus",
      cache: false,
      data: {
        status: newStatus,
        teamID: teamID,
      },
      success: function (data) {
        console.log("updateTeamStatus response:", data);
      },
      error: function (xhr, status, err) {
        console.error("updateTeamStatus failed:", status, err);
        alert("Failed to update team status. Check the console for details.");
      },
    });
  });

  var currentPendingID = null;

  function escapeHtml(value) {
    return $("<div>").text(value == null ? "" : value).html();
  }

  function renderCaptainMatches(matches) {
    $("#captainMatchLoading").hide();
    var $results = $("#captainMatchResults");

    var html = "";
    var createNewOption =
      '<label style="display:block; font-weight: normal;">' +
      '<input type="radio" name="captainLinkChoice" value="" checked> ' +
      "Create a new player record (no match / different person)</label>";

    if (matches && matches.length) {
      html +=
        '<div style="overflow-x: auto; max-width: 100%;">' +
        '<table class="table table-sm" style="font-size: 12px; margin-bottom: 0;"><thead><tr>' +
        "<th></th><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Team</th><th>Division</th>" +
        "</tr></thead><tbody>";
      matches.forEach(function (m) {
        html +=
          "<tr><td><input type=\"radio\" name=\"captainLinkChoice\" value=\"" +
          escapeHtml(m.PlayerID) +
          '"></td>' +
          "<td>" + escapeHtml(m.PlayerID) + "</td>" +
          "<td>" + escapeHtml(m.firstName) + " " + escapeHtml(m.lastName) + "</td>" +
          "<td>" + escapeHtml(m.Email) + "</td>" +
          "<td>" + escapeHtml(m.Phone) + "</td>" +
          "<td>" + escapeHtml(m.Status) + "</td>" +
          "<td>" + escapeHtml(m.Team) + "</td>" +
          "<td>" + escapeHtml(m.DivisionName) + "</td></tr>";
      });
      html += "</tbody></table></div>";
      html += '<div style="margin-top: 8px;">' + createNewOption + "</div>";
    } else {
      html += '<p class="text-muted">No matching players found.</p>';
      html += createNewOption;
    }

    $results.html(html).show();
  }

  $(document).on("click", ".approveBtn", function () {
    currentPendingID = $(this).data("pending-id");
    $("#approveTeamName").text($(this).data("team-name"));
    $("#approveDivisionSelect").val("");

    $("#captainMatchResults").hide().empty();
    $("#captainMatchLoading").show();

    $.ajax({
      type: "GET",
      url: "/library/teams.cfc?method=searchDuplicateCaptains",
      cache: false,
      data: {
        firstName: $(this).data("captain-first"),
        lastName: $(this).data("captain-last"),
        phone: $(this).data("captain-phone"),
        email: $(this).data("captain-email"),
      },
      success: function (data) {
        renderCaptainMatches(Array.isArray(data) ? data : []);
      },
      error: function (xhr, status, err) {
        console.error("searchDuplicateCaptains failed:", status, err);
        renderCaptainMatches([]);
      },
    });
  });

  $("#confirmApproveBtn").on("click", function () {
    var divisionID = $("#approveDivisionSelect").val();
    if (!divisionID) {
      alert("Please select a division before approving.");
      return;
    }

    var linkPlayerID = $('input[name="captainLinkChoice"]:checked').val() || 0;

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=approvePendingTeam",
      cache: false,
      data: {
        pendingTeamID: currentPendingID,
        divisionID: divisionID,
        seasonID: $("#approveSeasonID").val(),
        linkPlayerID: linkPlayerID,
      },
      success: function (data) {
        if (data === "Success") {
          location.reload();
        } else {
          alert("Approve failed: " + data);
        }
      },
      error: function (xhr, status, err) {
        console.error("approvePendingTeam failed:", status, err);
        alert("Failed to approve team. Check the console for details.");
      },
    });

    $("#approveTeamModal").modal("hide");
  });

  $(document).on("click", ".rejectBtn", function () {
    var pendingTeamID = $(this).data("pending-id");
    if (!confirm("Reject this registration? It will move to the Inactive tab for review.")) {
      return;
    }

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=rejectPendingTeam",
      cache: false,
      data: {
        pendingTeamID: pendingTeamID,
      },
      success: function (data) {
        if (data === "Success") {
          location.reload();
        } else {
          alert("Reject failed: " + data);
        }
      },
      error: function (xhr, status, err) {
        console.error("rejectPendingTeam failed:", status, err);
        alert("Failed to reject team. Check the console for details.");
      },
    });
  });

  $(document).on("click", ".restoreBtn", function () {
    var pendingTeamID = $(this).data("pending-id");
    if (!confirm("Restore this registration to Pending?")) {
      return;
    }

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=restorePendingTeam",
      cache: false,
      data: {
        pendingTeamID: pendingTeamID,
      },
      success: function (data) {
        if (data === "Success") {
          location.reload();
        } else {
          alert("Restore failed: " + data);
        }
      },
      error: function (xhr, status, err) {
        console.error("restorePendingTeam failed:", status, err);
        alert("Failed to restore registration. Check the console for details.");
      },
    });
  });

  $(document).on("click", ".deletePermanentlyBtn", function () {
    var pendingTeamID = $(this).data("pending-id");
    if (!confirm("Permanently delete this registration? This cannot be undone.")) {
      return;
    }

    $.ajax({
      type: "POST",
      url: "/library/teams.cfc?method=deletePendingTeam",
      cache: false,
      data: {
        pendingTeamID: pendingTeamID,
      },
      success: function (data) {
        if (data === "Success") {
          location.reload();
        } else {
          alert("Delete failed: " + data);
        }
      },
      error: function (xhr, status, err) {
        console.error("deletePendingTeam failed:", status, err);
        alert("Failed to delete registration. Check the console for details.");
      },
    });
  });
});
