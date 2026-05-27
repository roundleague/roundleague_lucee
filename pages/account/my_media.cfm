<cfinclude template="/header.cfm">

<link href="/pages/captain/captain_home.css" rel="stylesheet" />
<link href="/pages/account/account_home.css?v=0.1" rel="stylesheet" />
<link href="/pages/account/my_media.css?v=1.0" rel="stylesheet" />

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
            <div class="media-grid">
                <cfloop array="#photos#" item="photo">
                    <div class="media-thumb-wrap" onclick="openLightbox('#JSStringFormat(photo.photoURL)#')">
                        <img src="#photo.photoURL#" alt="#htmlEditFormat(photo.filename)#" class="media-thumb" loading="lazy">
                    </div>
                </cfloop>
            </div>
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
    <img id="lightbox-img" src="" alt="Photo" onclick="event.stopPropagation()">
</div>

</div>
</div>
</div>
</cfoutput>

<script>
function openLightbox(src) {
    document.getElementById('lightbox-img').src = src;
    document.getElementById('lightbox').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}
function closeLightbox() {
    document.getElementById('lightbox').style.display = 'none';
    document.getElementById('lightbox-img').src = '';
    document.body.style.overflow = '';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeLightbox();
});
</script>

<cfinclude template="/footer.cfm">
