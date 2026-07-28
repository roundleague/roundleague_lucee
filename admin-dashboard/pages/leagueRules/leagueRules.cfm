<cfinclude template="/admin-dashboard/admin_header.cfm">

<link href="/admin-dashboard/pages/leagueRules/leagueRules.css" rel="stylesheet">
<link href="https://cdn.quilljs.com/1.3.7/quill.snow.css" rel="stylesheet">

<cfquery name="qRules" datasource="roundleague">
    SELECT contentHTML FROM site_content WHERE pageKey = 'league-rules'
</cfquery>

<cfset defaultRules = '<h1 class="ql-align-center">League Rules &amp; Regulations</h1>
        <p class="ql-align-center">The Round &mdash; 4145 SW Watson Ave, Beaverton, OR 97005</p>

        <div class="rules-section">
          <h2>1. General Information</h2>
          <ul>
            <li>Team Fee: $1,600 per team (recommended 7&ndash;8 players per roster)</li>
            <li>Jerseys: $20 per jersey (required)</li>
            <li>Season Format: 12 guaranteed regular season games with playoff eligibility</li>
            <li>Eligibility: All players must be 18 years of age or older</li>
            <li>Roster Policy: Players may compete for only one team per season</li>
            <li>League Fees Cover: Officials, scorekeepers, stat keepers, awards, videographers/photographers, and gym supervision</li>
            <li>The Round League is not responsible for lost, stolen, or unattended personal property</li>
          </ul>
        </div>

        <div class="rules-section">
          <h2>2. Liability &amp; Waiver</h2>
          <p>All participants compete at their own risk.</p>
          <p>The Round League, its ownership, staff, officials, and facility partners are not liable for injuries sustained before, during, or after league activities.</p>
          <p>All players must sign a participation waiver prior to competing. Failure to complete a waiver will result in ineligibility.</p>
        </div>

        <div class="rules-section">
          <h2>3. League Structure</h2>
          <p>The Round League consists of two divisions:</p>
          <ul>
            <li><strong>Premier Division</strong> &ndash; Highest level competition</li>
            <li><strong>Open Division</strong> &ndash; Intermediate / Recreational</li>
          </ul>
          <p>League administration reserves the right to adjust divisions for competitive balance.</p>
        </div>

        <div class="rules-section">
          <h2>4. Playoff Eligibility</h2>
          <p>Top half of teams in each division will advance to playoffs.</p>
          <p>Players must have played in at least one regular season game with their team in order to be eligible for playoffs.</p>
          <p>Teams must remain in good standing to qualify for playoffs. Good standing is determined by:</p>
          <ul>
            <li>Attendance reliability</li>
            <li>Sportsmanship</li>
            <li>Technical foul accumulation</li>
            <li>Conduct toward officials, staff, and opponents</li>
          </ul>
          <p>Teams on probation or accumulating 4 or more unsportsmanlike technical fouls during the regular season may be deemed ineligible for playoffs.</p>
          <h3>Playoff Roster Additions</h3>
          <ul>
            <li>Teams with fewer than 6 available players may add players to avoid forfeits</li>
            <li>Teams may only add players until reaching 6 active players</li>
            <li>Added players must not have played for another team during the current season</li>
            <li>League approval is required prior to tip-off</li>
          </ul>
        </div>

        <div class="rules-section">
          <h2>5. Game Rules</h2>
          <p>All divisions will follow the 2026&ndash;2027 NCAA Rulebook, except where modified below.</p>
          <h3>Game Format</h3>
          <ul>
            <li>Two 25-minute halves (running clock)</li>
            <li>2 timeouts per half (30 seconds each)</li>
            <li>Timeouts do not carry over</li>
          </ul>
          <h3>Clock Rules</h3>
          <ul>
            <li>Clock stops on all timeouts</li>
            <li>Clock stops during the final 2 minutes of the second half if the score differential is 10 points or fewer</li>
            <li>If the margin is 11 points or more, the clock continues to run</li>
            <li>Clock stops on made baskets and all dead balls within the final 30 seconds of each half</li>
          </ul>
          <h3>Advance Rule</h3>
          <p>One advance to half court permitted if a timeout is called within the final 30 seconds of the second half.</p>
          <h3>Fouls</h3>
          <ul>
            <li>6 personal fouls per player</li>
            <li>7 team fouls = single bonus</li>
            <li>10+ team fouls = double bonus</li>
          </ul>
          <h3>Minimum Players</h3>
          <p>Minimum of 4 players required to start a game.</p>
          <h3>Forfeits</h3>
          <ul>
            <li>A team that fails to appear for two games in one season may be removed from the current season and suspended from future participation</li>
            <li>Forfeit scores will be recorded as determined by league administration</li>
          </ul>
        </div>

        <div class="rules-section">
          <h2>6. Overtime</h2>
          <h3>First Overtime</h3>
          <ul>
            <li>2 minutes</li>
            <li>Stop clock</li>
            <li>1 timeout per team</li>
          </ul>
          <h3>Second Overtime</h3>
          <ul>
            <li>Sudden death (first basket wins)</li>
            <li>1 timeout per team</li>
          </ul>
        </div>

        <div class="rules-section">
          <h2>7. Technical Foul &amp; Discipline Policy</h2>
          <p>The Round League enforces strict sportsmanship standards.</p>
          <ul>
            <li>1 Technical Foul = Official warning</li>
            <li>2 Technical Fouls in the same game = Automatic ejection</li>
            <li>3+ Technical Fouls in a season = Subject to suspension review</li>
            <li>4+ Unsportsmanlike Technical Fouls (team total) = Possible playoff ineligibility</li>
          </ul>
          <div class="rules-note">Any physical altercation, aggressive behavior, or verbal threats toward players, staff, officials, or spectators may result in immediate suspension or expulsion without refund.</div>
          <p style="margin-top:12px;">League administration reserves the right to issue suspensions beyond automatic penalties.</p>
        </div>

        <div class="rules-section">
          <h2>8. Officials Authority</h2>
          <p>Game officials have full authority over gameplay and conduct.</p>
          <p>All referee decisions are final and are not subject to protest.</p>
        </div>

        <div class="rules-section">
          <h2>9. Protest Policy</h2>
          <p>No game protests will be accepted.</p>
          <p>The judgment of officials and league administration is final.</p>
        </div>

        <div class="rules-section">
          <h2>10. Tiebreaker Procedures</h2>
          <p>In the event of identical regular season records, playoff seeding will be determined by:</p>
          <ol>
            <li>Regular season record</li>
            <li>Point differential</li>
            <li>Points allowed</li>
          </ol>
        </div>

        <div class="rules-section">
          <h2>11. Makeup Games</h2>
          <p>Games canceled due to inclement weather or uncontrollable circumstances will be rescheduled.</p>
          <p>Makeup dates will be determined based on court availability.</p>
        </div>

        <div class="rules-section">
          <h2>12. Dress Code</h2>
          <ul>
            <li>Official Round League jerseys are required for all games</li>
            <li>All players must wear black shorts or pants</li>
            <li>Undershirts must be black or white</li>
            <li>No jewelry permitted</li>
            <li>No watches, wristbands, or hard accessories</li>
          </ul>
          <p>Failure to comply may result in removal from the game until corrected.</p>
        </div>

        <div class="rules-section">
          <h2>League Rights &amp; Discretion</h2>
          <p>The Round League reserves the right to:</p>
          <ul>
            <li>Modify schedules as necessary</li>
            <li>Enforce disciplinary measures</li>
            <li>Interpret rules in situations not explicitly covered</li>
            <li>Remove any participant deemed detrimental to the league environment</li>
          </ul>
          <p>All decisions made by league administration are final.</p>
        </div>'>

<cfoutput>
<div class="content">
    <a href="/admin-dashboard/pages/moreTools/moreTools.cfm" class="btn btn-default btn-sm" style="margin-bottom:14px;margin-left:2px;">
        <i class="nc-icon nc-minimal-left"></i> Back to More Tools
    </a>
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h4 class="card-title mb-0">League Rules Editor</h4>
                    <button id="saveBtn" class="btn btn-primary btn-sm">Save Rules</button>
                </div>
                <div class="card-body">

                    <cfif isDefined("url.saved") AND url.saved EQ 1>
                        <div class="alert alert-success alert-dismissible" role="alert">
                            Rules saved successfully.
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                        </div>
                    </cfif>
                    <cfif isDefined("url.error") AND url.error EQ 1>
                        <div class="alert alert-danger alert-dismissible" role="alert">
                            An error occurred while saving. Please try again.
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                        </div>
                    </cfif>

                    <p class="text-muted lr-hint">Changes made here will appear immediately on the public <a href="/pages/Rules/league-rules.cfm" target="_blank">League Rules page</a>.</p>

                    <form id="rulesForm" method="POST" action="/admin-dashboard/pages/leagueRules/saveLeagueRules.cfm">
                        <input type="hidden" name="rulesContent" id="rulesContent">
                        <div id="rulesEditor"></div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.quilljs.com/1.3.7/quill.min.js"></script>
<script>
    var quill = new Quill('##rulesEditor', {
        theme: 'snow',
        modules: {
            toolbar: [
                [{ 'header': [1, 2, 3, false] }],
                ['bold', 'italic', 'underline'],
                [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                ['clean']
            ]
        }
    });

    var existingContent = <cfif qRules.recordCount>#serializeJSON(qRules.contentHTML)#<cfelse>#serializeJSON(defaultRules)#</cfif>;
    quill.clipboard.dangerouslyPasteHTML(existingContent);

    document.getElementById('saveBtn').addEventListener('click', function() {
        document.getElementById('rulesContent').value = quill.root.innerHTML;
        document.getElementById('rulesForm').submit();
    });
</script>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
