component {
    this.name = "RoundLeague";
    this.datasource = "roundleague";
    this.sessionManagement = true;
    this.restEnabled = true;
    this.restSettings = {
        cfclocation = "/",
        skipCFCWithError = true
    };

    function onApplicationStart() {
        session.LoggedIn = false;

        // ✅ Load API keys into application scope
        include "api-keys.cfm";

        setApiBase();

        return true;
    }

    function onRequestStart() {
        // Self-heal if application scope was cleared (e.g. server restart without onApplicationStart firing)
        if (NOT isDefined("application.apiBase")) {
            include "api-keys.cfm";
            setApiBase();
        }
    }

    private function setApiBase() {
        if (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1") {
            application.apiBase = "http://localhost:3001";
        } else {
            application.apiBase = "https://round-league-api.onrender.com";
        }
    }
}
