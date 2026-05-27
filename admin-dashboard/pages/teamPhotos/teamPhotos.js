var _objectURLs = [];
var _currentTeamID = null;

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
  var countEl = document.getElementById('galleryCount');

  grid.innerHTML = '<p class="text-muted">Loading...</p>';
  card.style.display = 'block';

  try {
    var res = await fetch(API_BASE + '/api/photos/team/' + teamID + '?seasonID=' + SEASON_ID);
    var photos = await res.json();

    grid.innerHTML = '';

    if (!photos.length) {
      countEl.textContent = 'No photos uploaded yet.';
      document.getElementById('deleteAllBtn').style.display = 'none';
      return;
    }

    countEl.textContent = photos.length + ' photo' + (photos.length !== 1 ? 's' : '');
    document.getElementById('deleteAllBtn').style.display = '';

    photos.forEach(function(photo) {
      grid.appendChild(makeGalleryThumb(photo));
    });
  } catch (err) {
    grid.innerHTML = '<p class="text-danger">Failed to load photos.</p>';
  }
}

function makeGalleryThumb(photo) {
  var wrap = document.createElement('div');
  wrap.className = 'gallery-thumb-wrap';
  wrap.dataset.photoId = photo.photoID;

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
  btn.onclick = function(e) {
    e.stopPropagation();
    deletePhoto(photo.photoID, wrap);
  };

  overlay.appendChild(btn);
  wrap.appendChild(img);
  wrap.appendChild(overlay);
  return wrap;
}

// ── Delete individual ────────────────────────────────────────────────────────

async function deletePhoto(photoID, thumbEl) {
  if (!confirm('Delete this photo?')) return;

  try {
    var res = await fetch(API_BASE + '/api/photos/' + photoID, {
      method: 'DELETE',
      headers: { 'x-admin-key': ADMIN_KEY }
    });

    if (!res.ok) throw new Error('Delete failed');

    thumbEl.remove();

    // Update count
    var remaining = document.querySelectorAll('#galleryGrid .gallery-thumb-wrap').length;
    var countEl = document.getElementById('galleryCount');
    if (remaining === 0) {
      countEl.textContent = 'No photos uploaded yet.';
      document.getElementById('deleteAllBtn').style.display = 'none';
    } else {
      countEl.textContent = remaining + ' photo' + (remaining !== 1 ? 's' : '');
    }
  } catch (err) {
    alert('Could not delete photo: ' + err.message);
  }
}

// ── Delete all ───────────────────────────────────────────────────────────────

async function deleteAll() {
  var thumbs = document.querySelectorAll('#galleryGrid .gallery-thumb-wrap');
  if (!thumbs.length) return;
  if (!confirm('Delete all ' + thumbs.length + ' photo' + (thumbs.length !== 1 ? 's' : '') + ' for this team?')) return;

  document.getElementById('deleteAllBtn').disabled = true;

  var ids = Array.from(thumbs).map(function(el) { return el.dataset.photoId; });
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
  loadGallery(_currentTeamID);

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
      (i + 1) + ' / ' + files.length + ' — ' + file.name;

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

  // Clean up
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
