component {
    this.name = "RoundLeague";
    this.datasource = "roundleague";
    this.sessionManagement = true;

    // Under construction splash logic for prod
    function onRequestStart(targetPage) {
        // If bypass param is present, set session var
        if (structKeyExists(url, "bypass") && url.bypass EQ "1") {
            session.bypassUnderConstruction = true;
        }
        var bypass = structKeyExists(session, "bypassUnderConstruction") && session.bypassUnderConstruction;
        var isSplash = listLast(cgi.script_name, "/") EQ "under-construction.html";
        if (!bypass && !isSplash) {
            // Redirect all requests to splash page
            location("/under-construction.html");
            return false;
        }
        return true;
    }

    function onApplicationStart() {
        session.LoggedIn = false;

        // ✅ Load API keys into application scope
        include "api-keys.cfm";

        return true;
    }
}
