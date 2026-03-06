document.addEventListener('DOMContentLoaded', function () {
  // Fade-in animation for stat rows
  var rows = document.querySelectorAll('.player-row');
  rows.forEach(function (row, i) {
    row.style.opacity = '0';
    row.style.transform = 'translateY(6px)';
    row.style.transition = 'opacity 0.35s ease ' + (i * 0.04) + 's, transform 0.35s ease ' + (i * 0.04) + 's';
    // Trigger on next frame
    requestAnimationFrame(function () {
      row.style.opacity = '1';
      row.style.transform = 'translateY(0)';
    });
  });

  // Clickable player rows -> navigate to player profile
  rows.forEach(function (row) {
    var link = row.querySelector('.player-link');
    if (link) {
      row.addEventListener('click', function (e) {
        if (e.target.closest('a')) return; // let direct link clicks work normally
        window.location.href = link.href;
      });
    }
  });
});
