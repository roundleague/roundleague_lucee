<cfinclude template="/header.cfm">

<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />
<link href="/pages/account/my_media.css?v=1.1" rel="stylesheet" />

<cfparam name="url.playerID" default="0">

<cfoutput>
<cfinclude template="account_header.cfm">

<cfif getPlayerData.recordCount GT 0>
    <cfhttp method="GET" url="#application.apiBase#/api/photos/team/#getPlayerData.teamID#" result="photosResult" timeout="10">
    </cfhttp>

    <cfset photos = []>
    <cfif photosResult.statusCode contains "200" AND isJSON(photosResult.fileContent)>
        <cfset photos = deserializeJSON(photosResult.fileContent)>
    </cfif>

    <div class="media-section">
        <h3 class="media-title"><i class="fa-solid fa-photo-film"></i> #getPlayerData.teamName# Photos</h3>

        <cfif arrayLen(photos) GT 0>
            <script>
            var PHOTOS = [
            <cfloop array="#photos#" item="photo">
                { url: '#JSStringFormat(photo.photoURL)#', filename: '#JSStringFormat(photo.filename)#' },
            </cfloop>
            ];
            </script>
            <div class="media-grid" id="mediaGrid"></div>
            <div id="mediaPageControls" class="media-page-controls"></div>
        <cfelse>
            <div class="no-media-message">
                <i class="fa-solid fa-camera"></i>
                <p>No photos yet this season. Check back after your next game!</p>
            </div>
        </cfif>
    </div>
<cfelse>
    <div class="no-media-message">
        <i class="fa-solid fa-people-group"></i>
        <p>Join a team to see your team's photos here.</p>
    </div>
</cfif>

<!--- Lightbox overlay --->
<div id="lightbox" onclick="closeLightbox()">
    <span class="lightbox-close">&times;</span>
    <button class="lb-arrow lb-prev" id="lb-prev" onclick="lightboxPrev(); event.stopPropagation()"><i class="fa-solid fa-chevron-left"></i></button>
    <img id="lightbox-img" src="" alt="Photo" onclick="event.stopPropagation()">
    <button class="lb-arrow lb-next" id="lb-next" onclick="lightboxNext(); event.stopPropagation()"><i class="fa-solid fa-chevron-right"></i></button>
</div>

</div>
</div>
</div>
</cfoutput>

<script>
var PAGE_SIZE = 24;
var _mediaPage = 0;
var _lightboxIndex = -1;

function renderMediaPage() {
    var grid = document.getElementById('mediaGrid');
    if (!grid || typeof PHOTOS === 'undefined') return;

    var start = _mediaPage * PAGE_SIZE;
    var end = Math.min(start + PAGE_SIZE, PHOTOS.length);

    grid.innerHTML = '';
    for (var i = start; i < end; i++) {
        var wrap = document.createElement('div');
        wrap.className = 'media-thumb-wrap';
        wrap.onclick = (function(idx) { return function() { openLightbox(idx); }; })(i);
        var img = document.createElement('img');
        img.src = PHOTOS[i].url;
        img.alt = PHOTOS[i].filename;
        img.className = 'media-thumb';
        img.loading = 'lazy';
        wrap.appendChild(img);
        grid.appendChild(wrap);
    }

    renderMediaPageControls();
}

function renderMediaPageControls() {
    var container = document.getElementById('mediaPageControls');
    if (!container) return;

    var totalPages = Math.ceil(PHOTOS.length / PAGE_SIZE);
    if (totalPages <= 1) { container.innerHTML = ''; return; }

    var html = '<div class="page-controls">';
    html += '<button class="page-ctrl-btn" onclick="goToMediaPage(' + (_mediaPage - 1) + ')"' + (_mediaPage === 0 ? ' disabled' : '') + '><i class="fa-solid fa-chevron-left"></i></button>';
    for (var i = 0; i < totalPages; i++) {
        html += '<button class="page-ctrl-btn' + (i === _mediaPage ? ' active' : '') + '" onclick="goToMediaPage(' + i + ')">' + (i + 1) + '</button>';
    }
    html += '<button class="page-ctrl-btn" onclick="goToMediaPage(' + (_mediaPage + 1) + ')"' + (_mediaPage === totalPages - 1 ? ' disabled' : '') + '><i class="fa-solid fa-chevron-right"></i></button>';
    html += '</div>';

    container.innerHTML = html;
}

function goToMediaPage(page) {
    if (typeof PHOTOS === 'undefined') return;
    var totalPages = Math.ceil(PHOTOS.length / PAGE_SIZE);
    if (page < 0 || page >= totalPages) return;
    _mediaPage = page;
    renderMediaPage();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function openLightbox(idx) {
    _lightboxIndex = idx;
    document.getElementById('lightbox-img').src = PHOTOS[idx].url;
    document.getElementById('lightbox').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    updateLightboxArrows();
}

function updateLightboxArrows() {
    var prev = document.getElementById('lb-prev');
    var next = document.getElementById('lb-next');
    if (prev) prev.style.display = _lightboxIndex > 0 ? '' : 'none';
    if (next) next.style.display = _lightboxIndex < PHOTOS.length - 1 ? '' : 'none';
}

function lightboxPrev() {
    if (_lightboxIndex > 0) openLightbox(_lightboxIndex - 1);
}

function lightboxNext() {
    if (_lightboxIndex < PHOTOS.length - 1) openLightbox(_lightboxIndex + 1);
}

function closeLightbox() {
    document.getElementById('lightbox').style.display = 'none';
    document.getElementById('lightbox-img').src = '';
    document.body.style.overflow = '';
    _lightboxIndex = -1;
}

document.addEventListener('keydown', function(e) {
    if (document.getElementById('lightbox').style.display === 'flex') {
        if (e.key === 'ArrowLeft') lightboxPrev();
        else if (e.key === 'ArrowRight') lightboxNext();
        else if (e.key === 'Escape') closeLightbox();
    }
});

if (typeof PHOTOS !== 'undefined' && PHOTOS.length) {
    renderMediaPage();
}
</script>

<cfinclude template="/footer.cfm">
