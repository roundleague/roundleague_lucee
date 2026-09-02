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
        trackApiKeysFile();

        setApiBase();
        setDeployVersion();

        return true;
    }

    function onRequestStart() {
        // Self-heal if application scope was cleared (e.g. server restart without onApplicationStart firing)
        if (NOT isDefined("application.apiBase")) {
            include "api-keys.cfm";
            trackApiKeysFile();
            setApiBase();
        }
        if (NOT isDefined("application.deployVersion")) {
            setDeployVersion();
        }

        // Pick up api-keys.cfm edits (e.g. rotated secrets) without a manual app reload.
        // Throttled so we're not stat()-ing the file on every single request.
        if (NOT isDefined("application.apiKeysCheckedAt") OR dateDiff("s", application.apiKeysCheckedAt, now()) GT 30) {
            application.apiKeysCheckedAt = now();
            var currentMTime = getFileInfo(expandPath("/api-keys.cfm")).dateLastModified;
            if (NOT isDefined("application.apiKeysMTime") OR currentMTime NEQ application.apiKeysMTime) {
                include "api-keys.cfm";
                application.apiKeysMTime = currentMTime;
            }
        }
    }

    private function trackApiKeysFile() {
        application.apiKeysMTime = getFileInfo(expandPath("/api-keys.cfm")).dateLastModified;
        application.apiKeysCheckedAt = now();
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
        var isLocal = (CGI.SERVER_NAME contains "localhost" OR CGI.SERVER_NAME contains "127.0.0.1");
        var errType = structKeyExists(exception, "type") ? left(exception.type, 200) : "Unknown";
        var errMsg  = structKeyExists(exception, "message") ? exception.message : "";
        var pageURL = CGI.SCRIPT_NAME & (len(CGI.QUERY_STRING) ? "?" & CGI.QUERY_STRING : "");
        var errLine = 0;
        if (structKeyExists(exception, "tagContext") AND isArray(exception.tagContext) AND arrayLen(exception.tagContext)) {
            var topContext = exception.tagContext[1];
            if (structKeyExists(topContext, "line")) errLine = topContext.line;
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

        var fingerprint = createObject("component", "library.bugLogger").logBug(exception, pageURL);

        try {
            if (NOT isLocal) {
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

        if (isLocal) {
            writeOutput("<!DOCTYPE html><html><head><title>Lucee Error (local)</title></head><body style=""font-family:sans-serif;padding:20px;"">");
            writeOutput("<h1 style=""color:##b00020;"">" & errType & "</h1>");
            writeOutput("<p><strong>Message:</strong> " & encodeForHTML(errMsg) & "</p>");
            if (structKeyExists(exception, "detail") AND len(exception.detail)) {
                writeOutput("<p><strong>Detail:</strong> " & encodeForHTML(exception.detail) & "</p>");
            }
            writeOutput("<p><strong>Page:</strong> " & encodeForHTML(pageURL) & " (line " & errLine & ")</p>");
            writeDump(var: exception, label: "Full Exception");
            writeOutput("</body></html>");
            return;
        }

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
