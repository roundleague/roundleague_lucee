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
        setDeployVersion();

        return true;
    }

    function onRequestStart() {
        // Self-heal if application scope was cleared (e.g. server restart without onApplicationStart firing)
        if (NOT isDefined("application.apiBase")) {
            include "api-keys.cfm";
            setApiBase();
        }
        if (NOT isDefined("application.deployVersion")) {
            setDeployVersion();
        }
    }

    private function setApiBase() {
        if (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1") {
            application.apiBase = "http://localhost:3001";
        } else {
            application.apiBase = "https://round-league-api.onrender.com";
        }
    }

    private function setDeployVersion() {
        var versionFile = expandPath("/version.txt");
        if (fileExists(versionFile)) {
            try {
                application.deployVersion = trim(fileRead(versionFile));
            } catch (any e) {
                application.deployVersion = "unknown";
            }
        } else {
            application.deployVersion = "dev-local";
        }
    }

    function onError(exception, eventName) {
        var errType = structKeyExists(exception, "type") ? left(exception.type, 200) : "Unknown";
        var errMsg  = structKeyExists(exception, "message") ? exception.message : "";
        var pageURL = CGI.SCRIPT_NAME;

        // Actual template/line the error was thrown from (may differ from pageURL
        // when the error is inside an included template).
        var errFile = pageURL;
        var errLine = 0;
        if (structKeyExists(exception, "tagContext") AND isArray(exception.tagContext) AND arrayLen(exception.tagContext)) {
            var topContext = exception.tagContext[1];
            if (structKeyExists(topContext, "template")) errFile = left(topContext.template, 500);
            if (structKeyExists(topContext, "line"))     errLine = topContext.line;
        }

        // Try to reuse the real site header (nav bar) for a consistent look. Falls back
        // to a bare page below if header.cfm itself throws (e.g. the DB is down, which
        // could be the very reason onError() fired in the first place).
        var headerHTML = "";
        var headerRendered = false;
        try {
            savecontent variable="headerHTML" {
                include "/header.cfm";
            }
            headerRendered = true;
        } catch (any e) {
            headerRendered = false;
        }

        try {
            var fingerprint   = hash(errType & "|" & errFile & "|" & errLine, "MD5");
            var userName      = (isDefined("session.userName") AND len(trim(session.userName))) ? session.userName : "";
            var deployVersion = isDefined("application.deployVersion") ? application.deployVersion : "unknown";
            var upsertResult  = "";

            queryExecute(
                "INSERT INTO bug_reports
                    (fingerprintHash, errorType, errorFile, errorLine, errorMessage, pageURL, occurrenceCount, firstSeenAt, lastSeenAt, resolved)
                 VALUES
                    (:fingerprintHash, :errorType, :errorFile, :errorLine, :errorMessage, :pageURL, 1, NOW(), NOW(), 0)
                 ON DUPLICATE KEY UPDATE
                    bugID = LAST_INSERT_ID(bugID),
                    occurrenceCount = occurrenceCount + 1,
                    lastSeenAt = NOW(),
                    resolved = 0",
                {
                    fingerprintHash: { value: fingerprint, cfsqltype: "cf_sql_varchar" },
                    errorType:       { value: errType,     cfsqltype: "cf_sql_varchar" },
                    errorFile:       { value: errFile,     cfsqltype: "cf_sql_varchar" },
                    errorLine:       { value: errLine,     cfsqltype: "cf_sql_integer" },
                    errorMessage:    { value: errMsg,      cfsqltype: "cf_sql_longvarchar" },
                    pageURL:         { value: pageURL,     cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "roundleague", result: "upsertResult" }
            );

            var bugID = upsertResult.generatedKey;

            queryExecute(
                "INSERT INTO bug_occurrences (bugID, occurredAt, userName, deployVersion, pageURL)
                 VALUES (:bugID, NOW(), :userName, :deployVersion, :pageURL)",
                {
                    bugID:         { value: bugID,         cfsqltype: "cf_sql_integer" },
                    userName:      { value: userName,      cfsqltype: "cf_sql_varchar", null: (len(userName) EQ 0) },
                    deployVersion: { value: deployVersion, cfsqltype: "cf_sql_varchar" },
                    pageURL:       { value: pageURL,       cfsqltype: "cf_sql_varchar" }
                },
                { datasource: "roundleague" }
            );
        } catch (any e) {}

        try {
            if (NOT (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1")) {
                var mailGate = createObject("component", "api.RateLimiter").check("bugmail_" & fingerprint, 1, 3600);
                if (mailGate.allowed) {
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
            }
        } catch (any e) {}

        var errorCard = "<div style=""font-family:sans-serif;text-align:center;padding:80px 20px;"">" &
            "<img src=""/assets/img/Logos/4_trimmed.png"" alt=""The Round League"" style=""max-width:220px;width:100%;height:auto;margin-bottom:28px;"">" &
            "<h1>Something went wrong</h1><p>Our team has been notified and is looking into it.</p>" &
            "<p><a href=""/"">Return to homepage</a></p></div>";

        if (headerRendered) {
            writeOutput(headerHTML);
            writeOutput(errorCard);
            writeOutput("</body></html>");
        } else {
            writeOutput("<!DOCTYPE html><html><head><title>Something went wrong</title></head><body>" &
                errorCard &
                "</body></html>");
        }
    }
}
