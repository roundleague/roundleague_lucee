<cfquery name="getUnresolvedBugs" datasource="roundleague">
    SELECT br.bugID, br.errorType, br.errorFile, br.errorLine, br.occurrenceCount,
           DATE_FORMAT(br.firstSeenAt, '%b %d') AS firstSeenShort,
           DATE_FORMAT(br.lastSeenAt,  '%b %d') AS lastSeenShort,
           (SELECT COUNT(DISTINCT userName) FROM bug_occurrences bo
             WHERE bo.bugID = br.bugID AND bo.userName IS NOT NULL AND bo.userName <> '') AS uniqueUsers
    FROM bug_reports br
    WHERE br.resolved = 0
    ORDER BY br.lastSeenAt DESC
</cfquery>

<cfquery name="getResolvedBugs" datasource="roundleague">
    SELECT br.bugID, br.errorType, br.errorFile, br.errorLine, br.occurrenceCount,
           DATE_FORMAT(br.firstSeenAt, '%b %d') AS firstSeenShort,
           DATE_FORMAT(br.lastSeenAt,  '%b %d') AS lastSeenShort,
           (SELECT COUNT(DISTINCT userName) FROM bug_occurrences bo
             WHERE bo.bugID = br.bugID AND bo.userName IS NOT NULL AND bo.userName <> '') AS uniqueUsers
    FROM bug_reports br
    WHERE br.resolved = 1
    ORDER BY br.lastSeenAt DESC
</cfquery>

<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/messages/messages.css?v=1.0" rel="stylesheet">
<link href="/admin-dashboard/pages/bugLogger/bugLogger.css?v=1.0" rel="stylesheet">

<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h4 class="card-title mb-0">
                        Unresolved Bugs
                        <cfoutput><span class="badge badge-danger ml-2">#getUnresolvedBugs.recordCount#</span></cfoutput>
                    </h4>
                </div>
                <div class="card-body p-0">
                    <div class="bug-list" id="unresolvedList">
                        <cfif getUnresolvedBugs.recordCount EQ 0>
                            <div class="bug-empty">
                                <i class="fa fa-bug"></i>
                                <p>No unresolved bugs. Nice.</p>
                            </div>
                        <cfelse>
                            <cfoutput query="getUnresolvedBugs">
                            <div class="bug-row" data-id="#bugID#" data-resolved="0" onclick="viewBug(#bugID#, event)">
                                <div class="bug-status"><span class="bug-dot"></span></div>
                                <div class="bug-type">#htmlEditFormat(errorType)#</div>
                                <div class="bug-location">#htmlEditFormat(listLast(errorFile, "\/"))#:#errorLine#</div>
                                <div class="bug-meta">
                                    <span class="bug-count">#occurrenceCount# occurrence<cfif occurrenceCount NEQ 1>s</cfif><cfif uniqueUsers GT 0> &middot; #uniqueUsers# user<cfif uniqueUsers NEQ 1>s</cfif></cfif></span>
                                    <span class="bug-date">#firstSeenShort# &ndash; #lastSeenShort#</span>
                                </div>
                                <div class="bug-actions" onclick="event.stopPropagation()">
                                    <button class="btn btn-sm btn-outline-success" onclick="setResolved(#bugID#, true)">Resolve</button>
                                    <button class="btn btn-sm btn-primary" onclick="createJiraPlaceholder(event)">
                                        <i class="fa fa-bug"></i> Create Jira Ticket
                                    </button>
                                </div>
                            </div>
                            </cfoutput>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h4 class="card-title mb-0">
                        Resolved Bugs
                        <cfoutput><span class="badge badge-secondary ml-2">#getResolvedBugs.recordCount#</span></cfoutput>
                    </h4>
                </div>
                <div class="card-body p-0">
                    <div class="bug-list" id="resolvedList">
                        <cfif getResolvedBugs.recordCount EQ 0>
                            <div class="bug-empty">
                                <i class="fa fa-bug"></i>
                                <p>No resolved bugs yet.</p>
                            </div>
                        <cfelse>
                            <cfoutput query="getResolvedBugs">
                            <div class="bug-row bug-row-resolved" data-id="#bugID#" data-resolved="1" onclick="viewBug(#bugID#, event)">
                                <div class="bug-status"></div>
                                <div class="bug-type">#htmlEditFormat(errorType)#</div>
                                <div class="bug-location">#htmlEditFormat(listLast(errorFile, "\/"))#:#errorLine#</div>
                                <div class="bug-meta">
                                    <span class="bug-count">#occurrenceCount# occurrence<cfif occurrenceCount NEQ 1>s</cfif><cfif uniqueUsers GT 0> &middot; #uniqueUsers# user<cfif uniqueUsers NEQ 1>s</cfif></cfif></span>
                                    <span class="bug-date">#firstSeenShort# &ndash; #lastSeenShort#</span>
                                </div>
                                <div class="bug-actions" onclick="event.stopPropagation()">
                                    <button class="btn btn-sm btn-outline-secondary" onclick="setResolved(#bugID#, false)">Unresolve</button>
                                    <button class="btn btn-sm btn-primary" onclick="createJiraPlaceholder(event)">
                                        <i class="fa fa-bug"></i> Create Jira Ticket
                                    </button>
                                </div>
                            </div>
                            </cfoutput>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bug Detail Modal -->
<div class="modal fade" id="bugModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <div style="flex:1; min-width:0;">
                    <h5 class="modal-title mb-0" id="modalErrorType"></h5>
                    <small class="text-muted" id="modalLocation"></small>
                </div>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="bug-modal-stats" id="modalStats"></div>
                <div id="modalMessage" class="bug-modal-body"></div>
                <div class="bug-modal-occurrences">
                    <h6>Recent Occurrences</h6>
                    <div id="modalOccurrences"></div>
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <div>
                    <button class="btn btn-sm" id="modalResolveBtn" onclick="modalToggleResolved()"></button>
                </div>
                <div>
                    <button class="btn btn-sm btn-primary" onclick="createJiraPlaceholder(event)">
                        <i class="fa fa-bug"></i> Create Jira Ticket
                    </button>
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
var currentBugID = null;
var currentResolved = false;

function viewBug(id, evt) {
    if (evt && evt.target.closest('.bug-actions')) return;
    currentBugID = id;

    fetch('/admin-dashboard/pages/bugLogger/actions/getBug.cfm?bugID=' + id)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success) { alert('Could not load bug.'); return; }
            var b = data.bug;

            currentResolved = (b.resolved == 1);

            document.getElementById('modalErrorType').textContent = b.errorType;
            document.getElementById('modalLocation').textContent = b.errorFile + ':' + b.errorLine + ' (requested via ' + b.pageURL + ')';
            document.getElementById('modalMessage').textContent = b.errorMessage;

            var statsParts = [
                b.occurrenceCount + ' occurrence' + (b.occurrenceCount == 1 ? '' : 's'),
                b.uniqueUsers > 0 ? (b.uniqueUsers + ' user' + (b.uniqueUsers == 1 ? '' : 's')) : null,
                'First seen ' + b.firstSeenAt,
                'Last seen ' + b.lastSeenAt
            ].filter(Boolean);
            document.getElementById('modalStats').textContent = statsParts.join(' - ');

            var occContainer = document.getElementById('modalOccurrences');
            occContainer.innerHTML = '';
            if (!b.recentOccurrences || b.recentOccurrences.length === 0) {
                occContainer.innerHTML = '<p class="text-muted mb-0">No occurrence details recorded.</p>';
            } else {
                b.recentOccurrences.forEach(function(occ) {
                    var row = document.createElement('div');
                    row.className = 'bug-occurrence-row';
                    row.textContent = occ.occurredAt + ' - ' + occ.userName + ' - ' + occ.deployVersion + ' - URL: ' + occ.pageURL;
                    occContainer.appendChild(row);
                });
            }

            var resolveBtn = document.getElementById('modalResolveBtn');
            if (currentResolved) {
                resolveBtn.textContent = 'Unresolve';
                resolveBtn.className = 'btn btn-sm btn-outline-secondary';
            } else {
                resolveBtn.textContent = 'Resolve';
                resolveBtn.className = 'btn btn-sm btn-outline-success';
            }

            $('#bugModal').modal('show');
        });
}

function modalToggleResolved() {
    if (!currentBugID) return;
    setResolved(currentBugID, !currentResolved, function() {
        $('#bugModal').modal('hide');
    });
}

function setResolved(id, resolve, callback) {
    fetch('/admin-dashboard/pages/bugLogger/actions/resolveBug.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=' + (resolve ? 'resolve' : 'unresolve') + '&bugID=' + id
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (!data.success) { alert('Could not update bug.'); return; }
        moveRow(id, resolve);
        if (callback) callback();
    });
}

function moveRow(id, resolve) {
    var row = document.querySelector('.bug-row[data-id="' + id + '"]');
    if (!row) return;

    var sourceList = row.parentElement;
    var destList = document.getElementById(resolve ? 'resolvedList' : 'unresolvedList');
    if (!destList) return;

    row.setAttribute('data-resolved', resolve ? '1' : '0');
    row.classList.toggle('bug-row-resolved', resolve);
    row.querySelector('.bug-status').innerHTML = resolve ? '' : '<span class="bug-dot"></span>';

    var actionBtn = row.querySelector('.bug-actions button:first-child');
    if (resolve) {
        actionBtn.textContent = 'Unresolve';
        actionBtn.className = 'btn btn-sm btn-outline-secondary';
        actionBtn.setAttribute('onclick', 'setResolved(' + id + ', false)');
    } else {
        actionBtn.textContent = 'Resolve';
        actionBtn.className = 'btn btn-sm btn-outline-success';
        actionBtn.setAttribute('onclick', 'setResolved(' + id + ', true)');
    }

    var destEmpty = destList.querySelector('.bug-empty');
    if (destEmpty) destEmpty.remove();

    destList.insertBefore(row, destList.firstChild);

    if (sourceList && sourceList !== destList && sourceList.querySelectorAll('.bug-row').length === 0 && !sourceList.querySelector('.bug-empty')) {
        var emptyMsg = document.createElement('div');
        emptyMsg.className = 'bug-empty';
        emptyMsg.innerHTML = '<i class="fa fa-bug"></i><p>' + (sourceList.id === 'unresolvedList' ? 'No unresolved bugs. Nice.' : 'No resolved bugs yet.') + '</p>';
        sourceList.appendChild(emptyMsg);
    }

    refreshCounts();
}

function refreshCounts() {
    var unresolvedCount = document.querySelectorAll('.bug-row[data-resolved="0"]').length;
    var resolvedCount = document.querySelectorAll('.bug-row[data-resolved="1"]').length;
    document.querySelectorAll('.card-header .badge')[0].textContent = unresolvedCount;
    document.querySelectorAll('.card-header .badge')[1].textContent = resolvedCount;
}

function createJiraPlaceholder(evt) {
    if (evt) evt.stopPropagation();
    alert('Jira integration coming soon.');
}
</script>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
