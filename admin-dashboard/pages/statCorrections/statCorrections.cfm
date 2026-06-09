<cfinclude template="/admin-dashboard/admin_header.cfm">

<cfparam name="url.tab" default="pending">
<cfset activeTab = (listFindNoCase("pending,approved,rejected", url.tab) ? url.tab : "pending")>

<!--- Handle approve/reject actions --->
<cfif isDefined("form.action") AND isDefined("form.requestID")>
  <cfset requestID = val(form.requestID)>

  <cfif form.action EQ "approve" AND requestID GT 0>
    <!--- Delegate entirely to the API — it updates playergamelog, recalcs playerstats, and sends push notification --->
    <cftry>
      <cfhttp url="#application.apiBase#/api/stat-corrections/admin/#requestID#/approve"
              method="PATCH"
              timeout="10"
              result="approveResult">
        <cfhttpparam type="header" name="x-admin-key" value="#application.adminApiKey#">
        <cfhttpparam type="header" name="Content-Type" value="application/json">
        <cfhttpparam type="body" value="{}">
      </cfhttp>
      <cfif left(approveResult.statusCode, 3) EQ "200">
        <cfset successMsg = "Stat correction approved and stats updated.">
      <cfelse>
        <cfset errorMsg = "Error approving request (status #approveResult.statusCode#). Please try again.">
      </cfif>
      <cfcatch>
        <cfset errorMsg = "Could not connect to the API. Please try again.">
      </cfcatch>
    </cftry>

  <cfelseif form.action EQ "reject" AND requestID GT 0>
    <cfset adminNote = isDefined("form.adminNote") ? trim(form.adminNote) : "">

    <cfquery datasource="roundleague">
      UPDATE stat_correction_requests
      SET status = 'rejected',
          adminNote = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#left(adminNote, 500)#" null="#adminNote EQ ''#">,
          resolvedAt = NOW()
      WHERE requestID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#requestID#">
      AND status = 'pending'
    </cfquery>

    <cfset successMsg = "Request rejected.">
  </cfif>

  <cfif isDefined("successMsg")>
    <cflocation url="/admin-dashboard/pages/statCorrections/statCorrections.cfm?tab=#(activeTab EQ 'pending' AND form.action EQ 'approve' ? 'approved' : activeTab)#&msg=#URLEncodedFormat(successMsg)#" addtoken="false">
  <cfelse>
    <cflocation url="/admin-dashboard/pages/statCorrections/statCorrections.cfm?tab=#activeTab#&err=#URLEncodedFormat(isDefined('errorMsg') ? errorMsg : 'Unknown error')#" addtoken="false">
  </cfif>
</cfif>

<!--- Fetch counts for tab badges --->
<cfquery name="qCounts" datasource="roundleague">
  SELECT status, COUNT(*) AS cnt
  FROM stat_correction_requests
  GROUP BY status
</cfquery>
<cfset counts = { pending=0, approved=0, rejected=0 }>
<cfloop query="qCounts">
  <cfset counts[qCounts.status] = qCounts.cnt>
</cfloop>

<!--- Fetch requests for active tab --->
<cfquery name="qRequests" datasource="roundleague">
  SELECT
    r.requestID, r.playerID, r.scheduleID, r.status,
    r.playerNote, r.adminNote, r.createdAt, r.resolvedAt,
    CONCAT(p.firstName, ' ', p.lastName) AS playerName,
    s.date AS gameDate,
    t.teamName AS opponent,
    r.orig_points, r.orig_rebounds, r.orig_assists, r.orig_steals, r.orig_blocks,
    r.orig_turnovers, r.orig_fouls, r.orig_FGM, r.orig_FGA,
    r.orig_3FGM, r.orig_3FGA, r.orig_FTM, r.orig_FTA,
    r.req_points, r.req_rebounds, r.req_assists, r.req_steals, r.req_blocks,
    r.req_turnovers, r.req_fouls, r.req_FGM, r.req_FGA,
    r.req_3FGM, r.req_3FGA, r.req_FTM, r.req_FTA
  FROM stat_correction_requests r
  JOIN players p ON r.playerID = p.playerID
  JOIN schedule s ON r.scheduleID = s.scheduleID
  JOIN playergamelog gl ON gl.playerID = r.playerID AND gl.scheduleID = r.scheduleID
  JOIN teams t ON (CASE WHEN s.homeTeamID = gl.teamID THEN s.awayTeamID ELSE s.homeTeamID END = t.teamID)
  WHERE r.status = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#activeTab#">
  ORDER BY r.createdAt DESC
</cfquery>

<cfoutput>

<style>
  .scr-page { padding: 20px; }
  .scr-tabs { display: flex; gap: 8px; margin-bottom: 20px; }
  .scr-tab { padding: 8px 18px; border-radius: 20px; border: 1.5px solid ##dee2e6; background: ##fff;
             color: ##555; font-weight: 600; font-size: 13px; text-decoration: none; cursor: pointer; }
  .scr-tab.active { background: ##1a1a2e; color: ##fff; border-color: ##1a1a2e; }
  .scr-tab .badge { background: ##e94560; color: ##fff; border-radius: 10px;
                    padding: 1px 7px; font-size: 11px; margin-left: 6px; }
  .scr-table { width: 100%; border-collapse: collapse; background: ##fff;
               border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
  .scr-table th { background: ##f7f8fc; padding: 11px 14px; font-size: 12px; font-weight: 700;
                  color: ##6b7080; text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid ##e2e4ea; }
  .scr-table td { padding: 12px 14px; border-bottom: 1px solid ##f0f1f5; font-size: 14px; vertical-align: middle; }
  .scr-table tr:last-child td { border-bottom: none; }
  .scr-table tr:hover td { background: ##fafafc; }
  .diff-table { width: 100%; border-collapse: collapse; font-size: 13px; margin: 10px 0; }
  .diff-table th { background: ##f0f1f5; padding: 7px 10px; font-weight: 700; color: ##6b7080; font-size: 11px; }
  .diff-table td { padding: 7px 10px; border-bottom: 1px solid ##f0f1f5; }
  .diff-table tr.changed td { background: ##fffbe6; font-weight: 700; }
  .diff-table .orig { color: ##9ea2af; }
  .diff-table .req  { color: ##1a1a2e; }
  .diff-arrow { color: ##e94560; margin: 0 4px; }
  .badge-pending  { background: ##fff8e1; color: ##f5a623; border-radius: 12px; padding: 3px 10px; font-size: 12px; font-weight: 700; }
  .badge-approved { background: ##e8faf0; color: ##00c853; border-radius: 12px; padding: 3px 10px; font-size: 12px; font-weight: 700; }
  .badge-rejected { background: ##fdeaec; color: ##e63946; border-radius: 12px; padding: 3px 10px; font-size: 12px; font-weight: 700; }
  .btn-approve { background: ##1a1a2e; color: ##fff; border: none; border-radius: 8px;
                 padding: 7px 16px; font-size: 13px; font-weight: 600; cursor: pointer; }
  .btn-approve:hover { background: ##2e3240; }
  .btn-reject  { background: ##fff; color: ##e63946; border: 1.5px solid ##e63946; border-radius: 8px;
                 padding: 7px 16px; font-size: 13px; font-weight: 600; cursor: pointer; margin-left: 8px; }
  .btn-reject:hover { background: ##fdeaec; }
  .player-note { background: ##f7f8fc; border-left: 3px solid ##7ec8e3; padding: 8px 12px;
                 border-radius: 0 6px 6px 0; font-size: 13px; color: ##484d5c; margin-top: 6px; font-style: italic; }
  .empty-state { text-align: center; padding: 48px 20px; color: ##9ea2af; font-size: 15px; }
</style>

<div class="content scr-page">
  <h3 class="description">Stat Correction Requests</h3>

  <cfif isDefined("url.msg") AND len(trim(url.msg))>
    <div style="background:##e8faf0;border:1px solid ##00c85344;border-radius:8px;padding:12px 16px;margin-bottom:16px;color:##007a33;font-weight:600;font-size:14px;">
      #HTMLEditFormat(url.msg)#
    </div>
  </cfif>
  <cfif isDefined("url.err") AND len(trim(url.err))>
    <div style="background:##fdeaec;border:1px solid ##e6394644;border-radius:8px;padding:12px 16px;margin-bottom:16px;color:##e63946;font-weight:600;font-size:14px;">
      #HTMLEditFormat(url.err)#
    </div>
  </cfif>

  <!--- Tab navigation --->
  <div class="scr-tabs">
    <a href="?tab=pending"  class="scr-tab #(activeTab EQ 'pending'  ? 'active' : '')#">
      Pending <cfif counts.pending GT 0><span class="badge">#counts.pending#</span></cfif>
    </a>
    <a href="?tab=approved" class="scr-tab #(activeTab EQ 'approved' ? 'active' : '')#">
      Approved <cfif counts.approved GT 0><span class="badge" style="background:##00c853">#counts.approved#</span></cfif>
    </a>
    <a href="?tab=rejected" class="scr-tab #(activeTab EQ 'rejected' ? 'active' : '')#">
      Rejected <cfif counts.rejected GT 0><span class="badge" style="background:##9ea2af">#counts.rejected#</span></cfif>
    </a>
  </div>

  <cfif qRequests.recordCount EQ 0>
    <div class="empty-state">No #activeTab# requests.</div>
  <cfelse>
    <table class="scr-table">
      <thead>
        <tr>
          <th>Player</th>
          <th>Game</th>
          <th>Submitted</th>
          <th>Changes Requested</th>
          <cfif activeTab EQ "pending"><th>Actions</th></cfif>
          <cfif activeTab NEQ "pending"><th>Resolved</th></cfif>
        </tr>
      </thead>
      <tbody>
        <cfloop query="qRequests">
          <tr>
            <td><strong>#playerName#</strong></td>
            <td>
              vs #opponent#<br>
              <small style="color:##9ea2af">#DateFormat(gameDate, "mmm d, yyyy")#</small>
            </td>
            <td><small>#DateFormat(createdAt, "mmm d")#</small></td>
            <td>
              <!--- Diff table showing only requested changes --->
              <table class="diff-table">
                <tr>
                  <th>Stat</th><th>Original</th><th></th><th>Requested</th>
                </tr>
                <cfset statDefs = [
                  {label="Points",       orig=orig_points,    req=req_points},
                  {label="Rebounds",     orig=orig_rebounds,  req=req_rebounds},
                  {label="Assists",      orig=orig_assists,   req=req_assists},
                  {label="Steals",       orig=orig_steals,    req=req_steals},
                  {label="Blocks",       orig=orig_blocks,    req=req_blocks},
                  {label="Turnovers",    orig=orig_turnovers, req=req_turnovers},
                  {label="Fouls",        orig=orig_fouls,     req=req_fouls},
                  {label="FG Made",      orig=orig_FGM,       req=req_FGM},
                  {label="FG Att",       orig=orig_FGA,       req=req_FGA},
                  {label="3PT Made",     orig=orig_3FGM,      req=req_3FGM},
                  {label="3PT Att",      orig=orig_3FGA,      req=req_3FGA},
                  {label="FT Made",      orig=orig_FTM,       req=req_FTM},
                  {label="FT Att",       orig=orig_FTA,       req=req_FTA}
                ]>
                <cfloop array="#statDefs#" index="sd">
                  <cfif NOT isNull(sd.req)>
                    <tr class="changed">
                      <td>#sd.label#</td>
                      <td class="orig">#sd.orig#</td>
                      <td><span class="diff-arrow">&rarr;</span></td>
                      <td class="req">#sd.req#</td>
                    </tr>
                  </cfif>
                </cfloop>
              </table>
              <cfif NOT isNull(playerNote) AND len(trim(playerNote))>
                <div class="player-note">"#HTMLEditFormat(playerNote)#"</div>
              </cfif>
              <cfif activeTab EQ "rejected" AND NOT isNull(adminNote) AND len(trim(adminNote))>
                <div style="margin-top:6px;font-size:12px;color:##e63946">Admin note: #HTMLEditFormat(adminNote)#</div>
              </cfif>
            </td>

            <!--- Pending: approve/reject buttons --->
            <cfif activeTab EQ "pending">
              <td style="white-space:nowrap">
                <form method="POST" style="display:inline" onsubmit="return confirm('Approve this stat correction? Stats will be updated immediately.')">
                  <input type="hidden" name="action" value="approve">
                  <input type="hidden" name="requestID" value="#requestID#">
                  <button type="submit" class="btn-approve">Approve</button>
                </form>
                <button type="button" class="btn-reject" onclick="openRejectModal(#requestID#)">Reject</button>
              </td>
            </cfif>

            <!--- Approved/rejected: show resolved date --->
            <cfif activeTab NEQ "pending">
              <td>
                <span class="badge-#status#">#UCase(Left(status,1)) & Mid(status,2,Len(status))#</span><br>
                <cfif NOT isNull(resolvedAt)>
                  <small style="color:##9ea2af">#DateFormat(resolvedAt, "mmm d")#</small>
                </cfif>
              </td>
            </cfif>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </cfif>
</div>

<!--- Reject modal --->
<div id="rejectModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:##fff;border-radius:12px;padding:28px;width:420px;max-width:90vw;">
    <h5 style="margin:0 0 16px;font-size:17px;font-weight:700;color:##1a1a2e">Reject Request</h5>
    <form method="POST" id="rejectForm">
      <input type="hidden" name="action" value="reject">
      <input type="hidden" name="requestID" id="rejectRequestID" value="">
      <label style="font-size:13px;font-weight:600;color:##6b7080;display:block;margin-bottom:6px">
        Admin note <span style="font-weight:400">(optional — shown to player)</span>
      </label>
      <textarea name="adminNote" rows="3" maxlength="500"
        style="width:100%;border:1.5px solid ##dee2e6;border-radius:8px;padding:10px;font-size:14px;resize:none;color:##1a1a2e"
        placeholder="e.g. Stats verified against scoresheet, original values are correct."></textarea>
      <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:16px">
        <button type="button" onclick="closeRejectModal()"
          style="background:##fff;border:1.5px solid ##dee2e6;border-radius:8px;padding:8px 18px;font-size:13px;font-weight:600;cursor:pointer">
          Cancel
        </button>
        <button type="submit" class="btn-reject" style="margin:0">Reject Request</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openRejectModal(requestID) {
    document.getElementById('rejectRequestID').value = requestID;
    var modal = document.getElementById('rejectModal');
    modal.style.display = 'flex';
  }
  function closeRejectModal() {
    document.getElementById('rejectModal').style.display = 'none';
  }
  document.getElementById('rejectModal').addEventListener('click', function(e) {
    if (e.target === this) closeRejectModal();
  });
</script>

</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
