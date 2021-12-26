component {
    this.name = "RoundLeague";
    this.datasource = "roundleague";
    this.sessionManagement = true;

    // Need to come back to this
    function onApplicationStart() {
        session.LoggedIn = false;
    }
 }