<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="/pages/Stats/leagueLeaders.css" rel="stylesheet" />

<cfoutput>
<div class="main" style="background-color: white;">
    <div class="section text-center">
      <div class="container">

 <h2 id="title" style="color: black;">League Leaders</h2> 
<div class="hover-table-layout">
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/21.JPG">
            <img src="#imgPath#" alt="image">
              <div class="caption">
                <h1 class="noTopSpace catTitle">Points</h1>
              </div>
        </div>
        <div class="listing">
        	<h4 class="noTopSpace">1. James Harden - 25.6</h4>
            <h4 class="noTopSpace">2. Kevin Durant - 25.6</h4>
            <h4 class="noTopSpace">3. Kevin Love - 25.6</h4>
            <h4 class="noTopSpace">4. Ricky Rubio - 25.6</h4>
            <h4 class="noTopSpace">5. LeBron James - 25.6</h4>
            <h4 class="noTopSpace">6. Damian Lillard - 25.6</h4>
            <h4 class="noTopSpace">7. CJ McCollum - 25.6</h4>
            <h4 class="noTopSpace">8. Devin Booker - 25.6</h4>
            <h4 class="noTopSpace">9. Chris Paul - 25.6</h4>
            <h4 class="noTopSpace">10. Zion Williamson - 25.6</h4>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/116.JPG">
            <img src="#imgPath#" alt="image">
              <div class="caption">
                <h1 class="noTopSpace catTitle">Rebounds</h1>
              </div>
        </div>
        <div class="listing">
        	<h4 class="noTopSpace">1. James Harden - 25.6</h4>
            <h4 class="noTopSpace">2. Kevin Durant - 25.6</h4>
            <h4 class="noTopSpace">3. Kevin Love - 25.6</h4>
            <h4 class="noTopSpace">4. Ricky Rubio - 25.6</h4>
            <h4 class="noTopSpace">5. LeBron James - 25.6</h4>
            <h4 class="noTopSpace">6. Damian Lillard - 25.6</h4>
            <h4 class="noTopSpace">7. CJ McCollum - 25.6</h4>
            <h4 class="noTopSpace">8. Devin Booker - 25.6</h4>
            <h4 class="noTopSpace">9. Chris Paul - 25.6</h4>
            <h4 class="noTopSpace">10. Zion Williamson - 25.6</h4>
        </div>
    </div>
    <div class="listing-item">
        <div class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/114.JPG">
            <img src="#imgPath#" alt="image">
              <div class="caption">
                <h1 class="noTopSpace catTitle">Assists</h1>
              </div>
        </div>
        <div class="listing">
        	<h4 class="noTopSpace">1. James Harden - 25.6</h4>
            <h4 class="noTopSpace">2. Kevin Durant - 25.6</h4>
            <h4 class="noTopSpace">3. Kevin Love - 25.6</h4>
            <h4 class="noTopSpace">4. Ricky Rubio - 25.6</h4>
            <h4 class="noTopSpace">5. LeBron James - 25.6</h4>
            <h4 class="noTopSpace">6. Damian Lillard - 25.6</h4>
            <h4 class="noTopSpace">7. CJ McCollum - 25.6</h4>
            <h4 class="noTopSpace">8. Devin Booker - 25.6</h4>
            <h4 class="noTopSpace">9. Chris Paul - 25.6</h4>
            <h4 class="noTopSpace">10. Zion Williamson - 25.6</h4>
        </div>
    </div>
</div>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

