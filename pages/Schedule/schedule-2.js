(function () {
  var API_BASE = (window.SCHEDULE_API_BASE || 'https://round-league-api.onrender.com') + '/api';

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  function initLiveClocks() {
    var clockEls = document.querySelectorAll('.liveClockEl[data-schedule-id]');
    if (!clockEls.length) return;

    var clocks = {};

    clockEls.forEach(function (el) {
      var id = el.getAttribute('data-schedule-id');
      if (!clocks[id]) clocks[id] = { els: [], remainingSeconds: 0, period: 1, ticker: null };
      clocks[id].els.push(el);
    });

    function render(id) {
      var c = clocks[id];
      var m = Math.floor(c.remainingSeconds / 60);
      var s = c.remainingSeconds % 60;
      var text = pad(m) + ':' + pad(s) + ' H' + c.period;
      c.els.forEach(function (el) { el.textContent = text; });
    }

    function sync(id) {
      fetch(API_BASE + '/schedule/' + id + '/clock')
        .then(function (r) { return r.json(); })
        .then(function (data) {
          var c = clocks[id];
          c.remainingSeconds = Math.max(0, parseInt(data.clock_display_seconds, 10) || 0);
          c.period = data.clock_period || 1;
          var running = data.clock_status === 'running';
          render(id);
          if (c.ticker) { clearInterval(c.ticker); c.ticker = null; }
          if (running) {
            c.ticker = setInterval(function () {
              if (c.remainingSeconds > 0) {
                c.remainingSeconds--;
                render(id);
              } else {
                clearInterval(c.ticker);
                c.ticker = null;
              }
            }, 1000);
          }
        })
        .catch(function () {});
    }

    Object.keys(clocks).forEach(function (id) {
      sync(id);
      setInterval(function () { sync(id); }, 15000);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLiveClocks);
  } else {
    initLiveClocks();
  }
})();

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
      var away = tr[i].getElementsByTagName("td")[2];
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
