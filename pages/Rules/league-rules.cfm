<cfquery name="qRules" datasource="roundleague">
    SELECT contentHTML FROM site_content WHERE pageKey = 'league-rules'
</cfquery>

<cfinclude template="/header.cfm">

<style>
  .rules-page { background-color: #fff; margin-top: 70px; padding-bottom: 60px; }
  .rules-page h1 { font-size: 2rem; font-weight: 700; margin-bottom: 4px; }
  .rules-page .subtitle { color: #888; margin-bottom: 40px; font-size: 0.95rem; }
  .rules-section { margin-bottom: 36px; }
  .rules-section h2 { font-size: 1.1rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: #c0392b; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px; margin-bottom: 16px; }
  .rules-section h3 { font-size: 0.95rem; font-weight: 700; margin-top: 18px; margin-bottom: 8px; color: #111; }
  .rules-section p, .rules-section li { font-size: 0.92rem; color: #111; line-height: 1.7; }
  .rules-section ul, .rules-section ol { padding-left: 20px; }
  .rules-section li { margin-bottom: 4px; }
  .rules-note { background: #fafafa; border-left: 3px solid #c0392b; padding: 12px 16px; border-radius: 0 4px 4px 0; font-size: 0.88rem; color: #111; margin-top: 10px; }
  /* styles for Quill-generated content */
  .lr-dynamic-content h1 { font-size: 2rem; font-weight: 700; margin-bottom: 4px; margin-top: 30px; text-align: center; }
  .lr-dynamic-content h2 { font-size: 1.1rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: #c0392b; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px; margin-bottom: 16px; margin-top: 36px; }
  .lr-dynamic-content h3 { font-size: 0.95rem; font-weight: 700; margin-top: 18px; margin-bottom: 8px; color: #111; }
  .lr-dynamic-content p, .lr-dynamic-content li { font-size: 0.92rem; color: #111; line-height: 1.7; }
  .lr-dynamic-content ul, .lr-dynamic-content ol { padding-left: 20px; }
  .lr-dynamic-content li { margin-bottom: 4px; }
  .lr-dynamic-content .ql-align-center { text-align: center; }
  .lr-dynamic-content p.ql-align-center:first-of-type { color: #888; font-size: 0.95rem; margin-bottom: 40px; }
</style>

<cfif qRules.recordCount>
<div class="rules-page">
  <div class="container">
    <div class="row">
      <div class="col-md-8 ml-auto mr-auto lr-dynamic-content">
        <cfoutput>#qRules.contentHTML#</cfoutput>
      </div>
    </div>
  </div>
</div>
<cfelse>
<cfoutput>
<div class="rules-page">
  <div class="container">
    <div class="row">
      <div class="col-md-8 ml-auto mr-auto">

        <h1 class="text-center" style="margin-top:30px;">League Rules &amp; Regulations</h1>
        <p class="text-center subtitle">The Round &mdash; 4145 SW Watson Ave, Beaverton, OR 97005</p>

        <!--- 1. General Information --->
        <div class="rules-section">
          <h2>1. General Information</h2>
          <ul>
            <li>Team Fee: $1,600 per team (recommended 7-8 players per roster)</li>
            <li>Jerseys: $20 per jersey (required)</li>
            <li>Season Format: 12 guaranteed regular season games with playoff eligibility</li>
            <li>Eligibility: All players must be 18 years of age or older</li>
            <li>Roster Policy: Players may compete for only one team per season</li>
            <li>League Fees Cover: Officials, scorekeepers, stat keepers, awards, videographers/photographers, and gym supervision</li>
            <li>The Round League is not responsible for lost, stolen, or unattended personal property</li>
          </ul>
        </div>

        <!--- 2. Liability & Waiver --->
        <div class="rules-section">
          <h2>2. Liability &amp; Waiver</h2>
          <p>All participants compete at their own risk.</p>
          <p>The Round League, its ownership, staff, officials, and facility partners are not liable for injuries sustained before, during, or after league activities.</p>
          <p>All players must sign a participation waiver prior to competing. Failure to complete a waiver will result in ineligibility.</p>
        </div>

        <!--- 3. League Structure --->
        <div class="rules-section">
          <h2>3. League Structure</h2>
          <p>The Round League consists of two divisions:</p>
          <ul>
            <li><strong>Premier Division</strong> &ndash; Highest level competition</li>
            <li><strong>Open Division</strong> &ndash; Intermediate / Recreational</li>
          </ul>
          <p>League administration reserves the right to adjust divisions for competitive balance.</p>
        </div>

        <!--- 4. Playoff Eligibility --->
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

        <!--- 5. Game Rules --->
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

        <!--- 6. Overtime --->
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

        <!--- 7. Technical Foul & Discipline --->
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

        <!--- 8. Officials Authority --->
        <div class="rules-section">
          <h2>8. Officials Authority</h2>
          <p>Game officials have full authority over gameplay and conduct.</p>
          <p>All referee decisions are final and are not subject to protest.</p>
        </div>

        <!--- 9. Protest Policy --->
        <div class="rules-section">
          <h2>9. Protest Policy</h2>
          <p>No game protests will be accepted.</p>
          <p>The judgment of officials and league administration is final.</p>
        </div>

        <!--- 10. Tiebreaker Procedures --->
        <div class="rules-section">
          <h2>10. Tiebreaker Procedures</h2>
          <p>In the event of identical regular season records, playoff seeding will be determined by:</p>
          <ol>
            <li>Regular season record</li>
            <li>Point differential</li>
            <li>Points allowed</li>
          </ol>
        </div>

        <!--- 11. Makeup Games --->
        <div class="rules-section">
          <h2>11. Makeup Games</h2>
          <p>Games canceled due to inclement weather or uncontrollable circumstances will be rescheduled.</p>
          <p>Makeup dates will be determined based on court availability.</p>
        </div>

        <!--- 12. Dress Code --->
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

        <!--- League Rights --->
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
        </div>

      </div>
    </div>
  </div>
</div>
</cfoutput>
</cfif>

<cfinclude template="/footer.cfm">
