<script>
    document.addEventListener("DOMContentLoaded", function() {
        const bannerKey = "roundLeagueMerchBannerDismissed";
        const banner = document.getElementById("merch-banner");

        if (!localStorage.getItem(bannerKey)) {
            banner.style.display = "block";
        }

        document.getElementById("dismiss-banner").addEventListener("click", function() {
            banner.style.display = "none";
            localStorage.setItem(bannerKey, "true");
        });
    });
</script>

<style>
    @media (min-width: 768px) {
        #dismiss-banner {
            font-size: 24px !important; /* Larger font size for desktop */
        }
    }
</style>

<div id="merch-banner" style="display: none; background-color: #cce5ff; color: #004085; padding: 10px; margin-bottom: 15px; border: 1px solid #b8daff; border-radius: 5px; position: relative;">
    <strong><i class="fa fa-info-circle" style="margin-right: 5px;"></i>Check out our new Round League Merch Store!</strong>
    <a href="/pages/store/store.cfm" style="text-decoration: underline; color: #004085;" target="_blank">Shop Now</a>
    <button id="dismiss-banner" style="position: absolute; top: -3px; right: 3px; background: none; border: none; color: #004085; font-size: 16px; cursor: pointer;">&times;</button>
</div>
