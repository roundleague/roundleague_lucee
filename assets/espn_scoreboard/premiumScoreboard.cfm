<cfoutput>

<title>The Round League Scoreboard</title>
<link rel="stylesheet" href="scoreboard.css">

<script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" crossorigin="anonymous"></script>
<script src="https://kit.fontawesome.com/356f7c17e2.js" crossorigin="anonymous"></script>
<script src="scoreboard.js"></script>
<script src="timer.js"></script>

<div class="scoreboard">
   <div class="team team-a houston">
      <!-- <div class="team-logo">
         <img src="https://cdn.bleacherreport.net/images/team_logos/328x328/houston_rockets.png" width="50px" height="50px"/>
      </div> -->
      <div class="team-detail">
         <div class="team-nameandscore">
            <div class="team-name homeTeam">
               
            </div>
            <div class="team-score team1">0</div>
         </div>
         <!-- <div class="team-thisgame">
            <div class="team-times">
               TO: 6
            </div>
            <div class="team-bonus">
               BONUS
            </div>
         </div> -->
      </div>
   </div>
   <div class="team team-b dallas">
      <!-- <div class="team-logo">
         <img src="http://i.cdn.turner.com/nba/nba/.element/img/1.0/teamsites/logos/teamlogos_500x500/dal.png" width="50px" height="50px"/>
      </div> -->
      <div class="team-detail">
         <div class="team-nameandscore">
            <div class="team-name awayTeam">
               
            </div>
            <div class="team-score team2">0</div>
         </div>
         <!-- <div class="team-thisgame">
            <div class="team-times">
               TO: 4
            </div>
            <div class="team-bonus">
               BONUS
            </div>
         </div> -->
      </div>
   </div>
   <div class="timer">
      <div class="timer-container">
          <div class="quarter">
              <span class="halfNum">1st Half</span>
          </div>
          <div class="timeleft"><span id="time">25:00</span></div>
          <!-- <div class="shotclock">
              24
          </div> -->
      </div> 
   </div>
   <div class="logo">
      <img src="../img/Logos/10.png"/>
   </div>
</div>

<p>Clock Status: <span class="clockStatus"></span></p>
<button class="resetBtn">Reset Clock</button>
<button class="modifyBtn">Modify Clock</button>
<ul>
  <li>1: Red Score +1</li>
  <li>2: Blue Score +1</li>
  <li>3: Red Score -1</li>
  <li>4: Blue Score -1</li>
  <li>5: Pause Clock</li>
  <li>6: Start Clock</li>
  <li>7: Next Half</li>
</ul>
</cfoutput>