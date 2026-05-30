var _objectURLs = [];
var _currentTeamID = null;
var _galleryPhotos = [];
var _currentPage = 0;
var _lightboxIndex = -1;
var PAGE_SIZE = 24;

// ── Keyboard nav ─────────────────────────────────────────────────────────────

document.addEventListener('keydown', function(e) {
  var lb = document.getElementById('adminLightbox');
  if (lb && lb.style.display === 'flex') {
    if (e.key === 'ArrowLeft') lightboxPrev();
    else if (e.key === 'ArrowRight') lightboxNext();
    else if (e.key === 'Escape') closeLightbox();
  }
});

// ── Team dropdown ────────────────────────────────────────────────────────────

function onTeamChange(teamID) {
  _currentTeamID = teamID || null;
  resetUploadState();
  if (teamID) {
    loadGallery(teamID);
  } else {
    document.getElementById('galleryCard').style.display = 'none';
  }
}

// ── Gallery load ─────────────────────────────────────────────────────────────

async function loadGallery(teamID) {
  var card = document.getElementById('galleryCard');
  var grid = document.getElementById('galleryGrid');

  grid.innerHTML = '<p class="text-muted">Loading...</p>';
  document.getElementById('galleryPageControls').innerHTML = '';
  card.style.display = 'block';

  try {
    var res = await fetch(API_BASE + '/api/photos/team/' + teamID + '?seasonID=' + SEASON_ID);
    _galleryPhotos = await res.json();
    _currentPage = 0;
    renderGalleryPage();
  } catch (err) {
    grid.innerHTML = '<p class="text-danger">Failed to load photos.</p>';
  }
}

function renderGalleryPage() {
  var grid = document.getElementById('galleryGrid');
  var countEl = document.getElementById('galleryCount');
  var total = _galleryPhotos.length;

  grid.innerHTML = '';

  if (!total) {
    countEl.textContent = 'No photos uploaded yet.';
    document.getElementById('deleteAllBtn').style.display = 'none';
    document.getElementById('galleryPageControls').innerHTML = '';
    return;
  }

  countEl.textContent = total + ' photo' + (total !== 1 ? 's' : '');
  document.getElementById('deleteAllBtn').style.display = '';

  var start = _currentPage * PAGE_SIZE;
  var end = Math.min(start + PAGE_SIZE, total);
  for (var i = start; i < end; i++) {
    grid.appendChild(makeGalleryThumb(_galleryPhotos[i], i));
  }

  renderPageControls();
}

function renderPageControls() {
  var container = document.getElementById('galleryPageControls');
  var totalPages = Math.ceil(_galleryPhotos.length / PAGE_SIZE);

  if (totalPages <= 1) {
    container.innerHTML = '';
    return;
  }

  var html = '<div class="page-controls">';
  html += '<button class="btn btn-sm btn-default btn-round page-ctrl-btn" onclick="goToPage(' + (_currentPage - 1) + ')"' + (_currentPage === 0 ? ' disabled' : '') + '><i class="fa fa-chevron-left"></i></button>';
  for (var i = 0; i < totalPages; i++) {
    html += '<button class="btn btn-sm ' + (i === _currentPage ? 'btn-primary' : 'btn-default') + ' btn-round page-ctrl-btn" onclick="goToPage(' + i + ')">' + (i + 1) + '</button>';
  }
  html += '<button class="btn btn-sm btn-default btn-round page-ctrl-btn" onclick="goToPage(' + (_currentPage + 1) + ')"' + (_currentPage === totalPages - 1 ? ' disabled' : '') + '><i class="fa fa-chevron-right"></i></button>';
  html += '</div>';

  container.innerHTML = html;
}

function goToPage(page) {
  var totalPages = Math.ceil(_galleryPhotos.length / PAGE_SIZE);
  if (page < 0 || page >= totalPages) return;
  _currentPage = page;
  renderGalleryPage();
}

function makeGalleryThumb(photo, index) {
  var wrap = document.createElement('div');
  wrap.className = 'gallery-thumb-wrap';
  wrap.dataset.photoId = photo.photoID;
  wrap.onclick = (function(idx) { return function() { openLightbox(idx); }; })(index);

  var img = document.createElement('img');
  img.src = photo.photoURL;
  img.className = 'photo-thumb';
  img.loading = 'lazy';

  var overlay = document.createElement('div');
  overlay.className = 'gallery-thumb-overlay';

  var btn = document.createElement('button');
  btn.className = 'btn btn-danger btn-sm delete-btn';
  btn.innerHTML = '<i class="fa fa-trash"></i>';
  btn.title = 'Delete photo';
  btn.onclick = (function(pid, idx) {
    return function(e) {
      e.stopPropagation();
      deletePhoto(pid, idx);
    };
  })(photo.photoID, index);

  overlay.appendChild(btn);
  wrap.appendChild(img);
  wrap.appendChild(overlay);
  return wrap;
}

// ── Lightbox ─────────────────────────────────────────────────────────────────

function openLightbox(index) {
  _lightboxIndex = index;
  var lb = document.getElementById('adminLightbox');
  document.getElementById('adminLightbox-img').src = _galleryPhotos[index].photoURL;
  lb.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  updateLightboxArrows();
}

function closeLightbox() {
  document.getElementById('adminLightbox').style.display = 'none';
  document.getElementById('adminLightbox-img').src = '';
  document.body.style.overflow = '';
  _lightboxIndex = -1;
}

function lightboxPrev() {
  if (_lightboxIndex > 0) openLightbox(_lightboxIndex - 1);
}

function lightboxNext() {
  if (_lightboxIndex < _galleryPhotos.length - 1) openLightbox(_lightboxIndex + 1);
}

function updateLightboxArrows() {
  var prev = document.getElementById('lb-prev');
  var next = document.getElementById('lb-next');
  if (prev) prev.style.display = _lightboxIndex > 0 ? '' : 'none';
  if (next) next.style.display = _lightboxIndex < _galleryPhotos.length - 1 ? '' : 'none';
}

// ── Delete individual ────────────────────────────────────────────────────────

async function deletePhoto(photoID, index) {
  if (!confirm('Delete this photo?')) return;

  try {
    var res = await fetch(API_BASE + '/api/photos/' + photoID, {
      method: 'DELETE',
      headers: { 'x-admin-key': ADMIN_KEY }
    });
    if (!res.ok) throw new Error('Delete failed');

    _galleryPhotos.splice(index, 1);

    var totalPages = Math.ceil(_galleryPhotos.length / PAGE_SIZE);
    if (_currentPage >= totalPages && _currentPage > 0) _currentPage--;

    renderGalleryPage();
  } catch (err) {
    alert('Could not delete photo: ' + err.message);
  }
}

// ── Delete all ───────────────────────────────────────────────────────────────

async function deleteAll() {
  var total = _galleryPhotos.length;
  if (!total) return;
  if (!confirm('Delete all ' + total + ' photo' + (total !== 1 ? 's' : '') + ' for this team?')) return;

  document.getElementById('deleteAllBtn').disabled = true;

  var ids = _galleryPhotos.map(function(p) { return p.photoID; });
  var failed = 0;

  for (var i = 0; i < ids.length; i++) {
    try {
      var res = await fetch(API_BASE + '/api/photos/' + ids[i], {
        method: 'DELETE',
        headers: { 'x-admin-key': ADMIN_KEY }
      });
      if (!res.ok) failed++;
    } catch (e) {
      failed++;
    }
  }

  document.getElementById('deleteAllBtn').disabled = false;
  _galleryPhotos = [];
  _currentPage = 0;
  renderGalleryPage();

  if (failed > 0) alert(failed + ' photo(s) could not be deleted.');
}

// ── File selection & upload ──────────────────────────────────────────────────

function onFilesSelected(input) {
  _objectURLs.forEach(function(url) { URL.revokeObjectURL(url); });
  _objectURLs = [];

  var files = input.files;
  var previewSection = document.getElementById('previewSection');
  var previewGrid = document.getElementById('previewGrid');
  var uploadBtn = document.getElementById('uploadBtn');

  document.getElementById('errorMsg').style.display = 'none';
  document.getElementById('successMsg').style.display = 'none';

  if (files.length === 0) {
    previewSection.style.display = 'none';
    uploadBtn.disabled = true;
    return;
  }

  previewGrid.innerHTML = '';
  for (var i = 0; i < files.length; i++) {
    var url = URL.createObjectURL(files[i]);
    _objectURLs.push(url);
    var img = document.createElement('img');
    img.src = url;
    img.className = 'photo-thumb';
    img.title = files[i].name;
    previewGrid.appendChild(img);
  }

  document.getElementById('previewLabel').textContent =
    files.length + ' photo' + (files.length !== 1 ? 's' : '') + ' selected';
  previewSection.style.display = 'block';
  uploadBtn.disabled = false;
}

async function startUpload() {
  var teamID = document.getElementById('teamSelect').value;
  var files = document.getElementById('photoFiles').files;

  if (!teamID) { showError('Please select a team.'); return; }
  if (files.length === 0) { showError('Please select at least one photo.'); return; }

  document.getElementById('uploadBtn').disabled = true;
  document.getElementById('errorMsg').style.display = 'none';
  document.getElementById('successMsg').style.display = 'none';
  document.getElementById('progressArea').style.display = 'block';

  var uploaded = 0;

  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    document.getElementById('progressText').textContent =
      (i + 1) + ' / ' + files.length + ' -- ' + file.name;

    try {
      var presignRes = await fetch(API_BASE + '/api/photos/presign', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-admin-key': ADMIN_KEY },
        body: JSON.stringify({
          teamID: parseInt(teamID),
          seasonID: SEASON_ID,
          filename: file.name,
          contentType: file.type || 'image/jpeg'
        })
      });
      if (!presignRes.ok) {
        var e = await presignRes.json().catch(function() { return {}; });
        throw new Error(e.error || 'Presign failed for ' + file.name);
      }
      var pd = await presignRes.json();

      var putRes = await fetch(pd.presignedUrl, {
        method: 'PUT',
        headers: { 'Content-Type': file.type || 'image/jpeg' },
        body: file
      });
      if (!putRes.ok) throw new Error('S3 upload failed for ' + file.name);

      var saveRes = await fetch(API_BASE + '/api/photos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-admin-key': ADMIN_KEY },
        body: JSON.stringify({
          teamID: parseInt(teamID),
          seasonID: SEASON_ID,
          s3Key: pd.s3Key,
          photoURL: pd.photoURL,
          filename: file.name
        })
      });
      if (!saveRes.ok) {
        var se = await saveRes.json().catch(function() { return {}; });
        throw new Error(se.error || 'Save failed for ' + file.name);
      }

      uploaded++;
    } catch (err) {
      showError('Upload error: ' + err.message);
      document.getElementById('progressArea').style.display = 'none';
      document.getElementById('uploadBtn').disabled = false;
      return;
    }
  }

  document.getElementById('progressArea').style.display = 'none';
  document.getElementById('previewSection').style.display = 'none';
  document.getElementById('photoFiles').value = '';
  document.getElementById('uploadBtn').disabled = true;
  _objectURLs.forEach(function(url) { URL.revokeObjectURL(url); });
  _objectURLs = [];

  showSuccess(uploaded + ' photo' + (uploaded !== 1 ? 's' : '') + ' uploaded successfully.');
  loadGallery(teamID);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function resetUploadState() {
  document.getElementById('photoFiles').value = '';
  document.getElementById('uploadBtn').disabled = true;
  document.getElementById('previewSection').style.display = 'none';
  document.getElementById('previewGrid').innerHTML = '';
  document.getElementById('progressArea').style.display = 'none';
  document.getElementById('successMsg').style.display = 'none';
  document.getElementById('errorMsg').style.display = 'none';
  _objectURLs.forEach(function(url) { URL.revokeObjectURL(url); });
  _objectURLs = [];
}

function showError(msg) {
  document.getElementById('errorText').textContent = msg;
  document.getElementById('errorMsg').style.display = 'block';
}

function showSuccess(msg) {
  document.getElementById('successText').textContent = msg;
  document.getElementById('successMsg').style.display = 'block';
}
