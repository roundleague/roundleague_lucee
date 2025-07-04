component {
    this.name = "RoundLeague";
    this.datasource = "roundleague";
    this.sessionManagement = true;

    function onApplicationStart() {
        session.LoggedIn = false;

        // ✅ Load API keys into application scope
        include "api-keys.cfm";

        return true;
    }
}
