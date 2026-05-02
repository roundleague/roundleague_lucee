(function () {
    const pageSize = 10;
    let currentPage = 1;

    const rows = Array.from(document.querySelectorAll('#recentEventsTable tbody tr'));
    const totalPages = Math.ceil(rows.length / pageSize);
    const pageInfo = document.getElementById('pageInfo');
    const prevBtn  = document.getElementById('prevBtn');
    const nextBtn  = document.getElementById('nextBtn');

    function showPage(page) {
        currentPage = page;
        const start = (page - 1) * pageSize;
        const end   = start + pageSize;
        rows.forEach(function (row, i) {
            row.style.display = (i >= start && i < end) ? '' : 'none';
        });
        pageInfo.textContent = 'Page ' + page + ' of ' + totalPages;
        prevBtn.disabled = page === 1;
        nextBtn.disabled = page === totalPages;
    }

    prevBtn.addEventListener('click', function () { if (currentPage > 1) showPage(currentPage - 1); });
    nextBtn.addEventListener('click', function () { if (currentPage < totalPages) showPage(currentPage + 1); });

    showPage(1);
}());
