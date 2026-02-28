function myFunction() {
  var input, filter, table, tr, i, txtValue, txtValue2;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();

  // --- Desktop table filtering ---
  table = document.getElementById("myTable");
  if (table) {
    tr = table.getElementsByTagName("tr");
    for (i = 0; i < tr.length; i++) {
      var home = tr[i].getElementsByTagName("td")[0];
      var away = tr[i].getElementsByTagName("td")[1];
      if (home && away && !tr[i].classList.contains("weekRow")) {
        txtValue = home.textContent || home.innerText;
        txtValue2 = away.textContent || away.innerText;
        if (
          txtValue.toUpperCase().indexOf(filter) > -1 ||
          txtValue2.toUpperCase().indexOf(filter) > -1
        ) {
          tr[i].style.display = "";
        } else {
          tr[i].style.display = "none";
        }
      }
    }
    // Show/hide week header rows based on whether any games in that week are visible
    var weekRows = table.querySelectorAll(".weekRow");
    weekRows.forEach(function (weekRow) {
      var next = weekRow.nextElementSibling;
      var hasVisible = false;
      while (next && !next.classList.contains("weekRow")) {
        if (next.style.display !== "none") hasVisible = true;
        next = next.nextElementSibling;
      }
      weekRow.style.display = hasVisible || filter.length === 0 ? "" : "none";
    });
  }

  // --- Mobile card filtering ---
  var mobileWrap = document.querySelector(".scheduleMobileWrap");
  if (mobileWrap) {
    var cards = mobileWrap.querySelectorAll(".gameCardItem");
    cards.forEach(function (card) {
      var homeAttr = (card.getAttribute("data-home") || "").toUpperCase();
      var awayAttr = (card.getAttribute("data-away") || "").toUpperCase();
      var text = (card.textContent || "").toUpperCase();
      if (
        homeAttr.indexOf(filter) > -1 ||
        awayAttr.indexOf(filter) > -1 ||
        text.indexOf(filter) > -1
      ) {
        card.style.display = "";
      } else {
        card.style.display = "none";
      }
    });
    // Show/hide mobile week headers
    var mobileHeaders = mobileWrap.querySelectorAll(".weekRowMobile");
    mobileHeaders.forEach(function (hdr) {
      var next = hdr.nextElementSibling;
      var hasVisible = false;
      while (next && !next.classList.contains("weekRowMobile")) {
        if (
          next.style.display !== "none" &&
          next.classList.contains("gameCardItem")
        )
          hasVisible = true;
        next = next.nextElementSibling;
      }
      hdr.style.display = hasVisible || filter.length === 0 ? "" : "none";
    });
  }
}
