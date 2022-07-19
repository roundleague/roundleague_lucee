<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<script src="/pages/Sponsors/sponsors.js"></script>
<link href="../Sponsors/sponsors.css?v=1.0" rel="stylesheet">

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
        <iframe onload="resizeIframe(this)" class="IframeContainer"scrolling="no" id="livePreviewFrame" src="/pages/Sponsors/sponsor_page.html" style="width:100%; border: 0px"></iframe>
      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

