<cfquery name="getMessages" datasource="roundleague">
    SELECT messageID, senderEmail, senderPhone, subject,
           LEFT(messageBody, 80) AS preview,
           isRead,
           DATE_FORMAT(createdAt, '%b %d') AS shortDate,
           jiraKey, jiraURL
    FROM contact_messages
    ORDER BY isRead ASC, createdAt DESC
</cfquery>

<cfquery name="getUnreadCount" datasource="roundleague">
    SELECT COUNT(*) AS cnt FROM contact_messages WHERE isRead = 0
</cfquery>

<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/messages/messages.css?v=1.0" rel="stylesheet">

<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h4 class="card-title mb-0">
                        Messages
                        <cfoutput>
                        <cfif getUnreadCount.cnt GT 0>
                            <span class="badge badge-danger ml-2">#getUnreadCount.cnt# unread</span>
                        </cfif>
                        </cfoutput>
                    </h4>
                </div>
                <div class="card-body p-0">

                    <div class="msg-bulk-bar">
                        <label class="msg-select-label">
                            <input type="checkbox" id="selectAll"> Select All
                        </label>
                        <button class="btn btn-sm btn-outline-secondary" onclick="bulkAction('markRead')">
                            <i class="nc-icon nc-email-85"></i> Mark Read
                        </button>
                        <button class="btn btn-sm btn-outline-secondary" onclick="bulkAction('markUnread')">
                            Mark Unread
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="bulkAction('delete')">
                            <i class="nc-icon nc-simple-remove"></i> Delete
                        </button>
                    </div>

                    <cfif getMessages.recordCount EQ 0>
                        <div class="msg-empty">
                            <i class="nc-icon nc-email-85"></i>
                            <p>No messages yet.</p>
                        </div>
                    <cfelse>
                        <div class="msg-list">
                            <cfoutput query="getMessages">
                            <div class="msg-row #iif(NOT isRead, de('msg-unread'), de(''))#" data-id="#messageID#" onclick="viewMessage(#messageID#, event)">
                                <div class="msg-check" onclick="event.stopPropagation()">
                                    <input type="checkbox" class="msg-checkbox" value="#messageID#">
                                </div>
                                <div class="msg-status">
                                    <cfif NOT isRead><span class="msg-dot"></span></cfif>
                                </div>
                                <div class="msg-sender">
                                    #htmlEditFormat(senderEmail)#
                                    <span class="msg-email">#htmlEditFormat(subject)#</span>
                                </div>
                                <div class="msg-preview">
                                    #htmlEditFormat(preview)#...
                                </div>
                                <div class="msg-meta">
                                    <cfif len(trim(jiraKey))>
                                        <a href="#jiraURL#" target="_blank" class="msg-jira-badge" onclick="event.stopPropagation()">
                                            <i class="nc-icon nc-badge"></i> #jiraKey#
                                        </a>
                                    </cfif>
                                    <span class="msg-date">#shortDate#</span>
                                </div>
                            </div>
                            </cfoutput>
                        </div>
                    </cfif>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- View Message Modal -->
<div class="modal fade" id="messageModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <div style="flex:1; min-width:0;">
                    <h5 class="modal-title mb-0" id="modalSubject"></h5>
                    <small class="text-muted" id="modalSenderEmail"></small>
                    &nbsp;&middot;&nbsp;
                    <small class="text-muted" id="modalSenderPhone"></small>
                </div>
                <span class="msg-modal-date ml-3 mr-3" id="modalDate"></span>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div id="modalConsent" class="mb-3" style="font-size:0.85rem;"></div>
                <div id="modalBody" class="msg-modal-body"></div>
            </div>
            <div class="modal-footer justify-content-between">
                <div>
                    <button class="btn btn-sm btn-outline-secondary" onclick="modalMarkUnread()">Mark Unread</button>
                    <button class="btn btn-sm btn-danger" onclick="modalDelete()">Delete</button>
                </div>
                <div>
                    <button class="btn btn-sm btn-primary" id="modalJiraBtn" onclick="openJiraModal()">
                        <i class="nc-icon nc-badge"></i> Create Jira Ticket
                    </button>
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Jira Ticket Modal -->
<div class="modal fade" id="jiraModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="nc-icon nc-badge"></i> Create Jira Ticket</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Summary</label>
                    <input type="text" class="form-control" id="jiraSummary">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea class="form-control" id="jiraDescription" rows="7"></textarea>
                </div>
                <div id="jiraError" class="alert alert-danger mt-2" style="display:none;"></div>
                <div id="jiraSuccess" class="alert alert-success mt-2" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="jiraSubmitBtn" onclick="submitJiraTicket()">
                    Create Ticket
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var currentMessageID = null;
var currentJiraURL = null;

function viewMessage(id, evt) {
    if (evt && (evt.target.type === 'checkbox' || evt.target.closest('.msg-check'))) return;
    currentMessageID = id;

    fetch('/admin-dashboard/pages/messages/actions/getMessage.cfm?messageID=' + id)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success) { alert('Could not load message.'); return; }
            var m = data.message;

            document.getElementById('modalSubject').textContent = m.subject;
            document.getElementById('modalSenderEmail').textContent = m.senderEmail;
            document.getElementById('modalSenderPhone').textContent = m.senderPhone || '';
            document.getElementById('modalDate').textContent = m.createdAt;
            document.getElementById('modalBody').textContent = m.messageBody;

            var consentEl = document.getElementById('modalConsent');
            if (m.consentToContact == 1) {
                consentEl.innerHTML = '<span style="color:#4caf50;font-weight:600;">&#10003; Sender consented to be contacted back</span>';
            } else {
                consentEl.innerHTML = '<span style="color:#aaa;">&#8212; Sender did not consent to be contacted back</span>';
            }

            var jiraBtn = document.getElementById('modalJiraBtn');
            currentJiraURL = m.jiraURL || null;
            if (m.jiraKey && m.jiraKey.length > 0) {
                jiraBtn.innerHTML = '<i class="nc-icon nc-badge"></i> View: ' + m.jiraKey;
                jiraBtn.onclick = function() { window.open(m.jiraURL, '_blank'); };
            } else {
                jiraBtn.innerHTML = '<i class="nc-icon nc-badge"></i> Create Jira Ticket';
                jiraBtn.onclick = openJiraModal;
            }

            document.getElementById('jiraSummary').value = 'Contact Form: ' + m.subject;
            document.getElementById('jiraDescription').value =
                'From: ' + m.senderEmail +
                (m.senderPhone ? ' | Phone: ' + m.senderPhone : '') +
                '\n\n' + m.messageBody;

            var row = document.querySelector('.msg-row[data-id="' + id + '"]');
            if (row) {
                row.classList.remove('msg-unread');
                var dot = row.querySelector('.msg-dot');
                if (dot) dot.remove();
            }

            $('#messageModal').modal('show');
        });
}

function modalMarkUnread() {
    if (!currentMessageID) return;
    sendBulkAction('markUnread', [currentMessageID], function() {
        var row = document.querySelector('.msg-row[data-id="' + currentMessageID + '"]');
        if (row) {
            row.classList.add('msg-unread');
            var statusDiv = row.querySelector('.msg-status');
            if (statusDiv && !statusDiv.querySelector('.msg-dot')) {
                statusDiv.innerHTML = '<span class="msg-dot"></span>';
            }
        }
        $('#messageModal').modal('hide');
    });
}

function modalDelete() {
    if (!currentMessageID || !confirm('Delete this message?')) return;
    sendBulkAction('delete', [currentMessageID], function() {
        var row = document.querySelector('.msg-row[data-id="' + currentMessageID + '"]');
        if (row) row.remove();
        $('#messageModal').modal('hide');
    });
}

function openJiraModal() {
    document.getElementById('jiraError').style.display = 'none';
    document.getElementById('jiraSuccess').style.display = 'none';
    document.getElementById('jiraSubmitBtn').disabled = false;
    document.getElementById('jiraSubmitBtn').textContent = 'Create Ticket';
    $('#messageModal').modal('hide');
    setTimeout(function() { $('#jiraModal').modal('show'); }, 350);
}

function submitJiraTicket() {
    var summary = document.getElementById('jiraSummary').value.trim();
    var description = document.getElementById('jiraDescription').value.trim();

    if (!summary) {
        document.getElementById('jiraError').textContent = 'Summary is required.';
        document.getElementById('jiraError').style.display = 'block';
        return;
    }

    var btn = document.getElementById('jiraSubmitBtn');
    btn.disabled = true;
    btn.textContent = 'Creating...';
    document.getElementById('jiraError').style.display = 'none';

    var params = 'messageID=' + encodeURIComponent(currentMessageID) +
                 '&summary=' + encodeURIComponent(summary) +
                 '&description=' + encodeURIComponent(description);

    fetch('/admin-dashboard/pages/messages/actions/createJiraTicket.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        btn.disabled = false;
        btn.textContent = 'Create Ticket';
        if (data.success) {
            document.getElementById('jiraSuccess').textContent = 'Ticket created: ' + data.ticketKey;
            document.getElementById('jiraSuccess').style.display = 'block';

            var row = document.querySelector('.msg-row[data-id="' + currentMessageID + '"]');
            if (row) {
                var meta = row.querySelector('.msg-meta');
                var dateSpan = meta.querySelector('.msg-date');
                var badge = '<a href="' + data.ticketURL + '" target="_blank" class="msg-jira-badge" onclick="event.stopPropagation()">' +
                            '<i class="nc-icon nc-badge"></i> ' + data.ticketKey + '</a>';
                dateSpan.insertAdjacentHTML('beforebegin', badge);
            }

            setTimeout(function() { $('#jiraModal').modal('hide'); }, 2200);
        } else {
            document.getElementById('jiraError').textContent = data.message || 'Failed to create ticket.';
            document.getElementById('jiraError').style.display = 'block';
        }
    })
    .catch(function() {
        btn.disabled = false;
        btn.textContent = 'Create Ticket';
        document.getElementById('jiraError').textContent = 'Network error. Please try again.';
        document.getElementById('jiraError').style.display = 'block';
    });
}

function sendBulkAction(action, ids, callback) {
    fetch('/admin-dashboard/pages/messages/actions/bulkAction.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=' + action + '&ids=' + ids.join(',')
    })
    .then(function(r) { return r.json(); })
    .then(function(data) { if (data.success && callback) callback(); });
}

function getSelectedIDs() {
    return Array.from(document.querySelectorAll('.msg-checkbox:checked')).map(function(c) { return c.value; });
}

function bulkAction(action) {
    var ids = getSelectedIDs();
    if (ids.length === 0) { alert('Please select at least one message.'); return; }
    if (action === 'delete' && !confirm('Delete ' + ids.length + ' message(s)?')) return;

    sendBulkAction(action, ids, function() {
        ids.forEach(function(id) {
            var row = document.querySelector('.msg-row[data-id="' + id + '"]');
            if (!row) return;
            if (action === 'delete') {
                row.remove();
            } else if (action === 'markRead') {
                row.classList.remove('msg-unread');
                var dot = row.querySelector('.msg-dot');
                if (dot) dot.remove();
            } else if (action === 'markUnread') {
                row.classList.add('msg-unread');
                var statusDiv = row.querySelector('.msg-status');
                if (statusDiv && !statusDiv.querySelector('.msg-dot')) {
                    statusDiv.innerHTML = '<span class="msg-dot"></span>';
                }
            }
        });
        document.getElementById('selectAll').checked = false;
    });
}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('selectAll').addEventListener('change', function() {
        document.querySelectorAll('.msg-checkbox').forEach(function(cb) {
            cb.checked = document.getElementById('selectAll').checked;
        });
    });
});
</script>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
