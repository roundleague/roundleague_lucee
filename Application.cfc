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

    function onError(exception, eventName) {
        var errType = structKeyExists(exception, "type") ? left(exception.type, 200) : "Unknown";
        var errMsg  = structKeyExists(exception, "message") ? exception.message : "";
        var pageURL = CGI.SCRIPT_NAME;

        try {
            queryExecute(
                "INSERT INTO bug_reports (errorType, errorMessage, pageURL) VALUES (:errorType, :errorMessage, :pageURL)",
                {
                    errorType:    { value: errType, cfsqltype: "cf_sql_varchar" },
                    errorMessage: { value: errMsg,  cfsqltype: "cf_sql_longvarchar" },
                    pageURL:      { value: pageURL, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "roundleague" }
            );
        } catch (any e) {}

        try {
            if (NOT (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1")) {
                cfmail(
                    from = "mailadmin@theroundleague.com",
                    to = "huynt553@gmail.com,rosasmoses9@gmail.com,evelyn.cooper.lhs@gmail.com",
                    subject = "RoundLeague Error: " & errType,
                    type = "text"
                ) {
                    writeOutput("An error occurred on The Round League site." & chr(10) & chr(10) &
                        "Type: " & errType & chr(10) &
                        "Page: " & pageURL & chr(10) &
                        "Time: " & dateFormat(now(), "mmm d, yyyy") & " " & timeFormat(now(), "h:mm tt") & chr(10) & chr(10) &
                        "Message:" & chr(10) & left(errMsg, 500));
                }
            }
        } catch (any e) {}

        writeOutput("<!DOCTYPE html><html><head><title>Something went wrong</title></head>" &
            "<body style=""font-family:sans-serif;text-align:center;padding:80px 20px;"">" &
            "<h1>Something went wrong</h1><p>Our team has been notified and is looking into it.</p>" &
            "<p><a href=""/"">Return to homepage</a></p></body></html>");
    }
}
