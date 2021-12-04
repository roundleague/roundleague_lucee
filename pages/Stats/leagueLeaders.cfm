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
        <figure class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/21.JPG">
            <img src="#imgPath#" alt="image">
            <figcaption>
              <div class="caption">
                <h1 class="noTopSpace">Points Leaders</h1>
                <p>James Harden</p>
                </div>
            </figcaption>
        </figure>
        <div class="listing">
            <h4 class="noTopSpace">2. Kevin Durant</h4>
            <h4 class="noTopSpace">3. Kevin Love</h4>
            <h4 class="noTopSpace">4. Ricky Rubio</h4>
            <h4 class="noTopSpace">5. LeBron James</h4>
            <h4 class="noTopSpace">6. Damian Lillard</h4>
            <h4 class="noTopSpace">7. CJ McCollum</h4>
            <h4 class="noTopSpace">8. Devin Booker</h4>
            <h4 class="noTopSpace">9. Chris Paul</h4>
            <h4 class="noTopSpace">10. Zion Williamson</h4>
        </div>
    </div>
    <div class="listing-item">
        <figure class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/116.JPG">
            <img src="#imgPath#" alt="image">
            <figcaption>
              <div class="caption">
                <h1 class="noTopSpace">Points Leaders</h1>
                <p>James Harden</p>
                </div>
            </figcaption>
        </figure>
        <div class="listing">
            <h4 class="noTopSpace">2. Kevin Durant</h4>
            <h4 class="noTopSpace">3. Kevin Love</h4>
            <h4 class="noTopSpace">4. Ricky Rubio</h4>
            <h4 class="noTopSpace">5. LeBron James</h4>
            <h4 class="noTopSpace">6. Damian Lillard</h4>
            <h4 class="noTopSpace">7. CJ McCollum</h4>
            <h4 class="noTopSpace">8. Devin Booker</h4>
            <h4 class="noTopSpace">9. Chris Paul</h4>
            <h4 class="noTopSpace">10. Zion Williamson</h4>
        </div>
    </div>
    <div class="listing-item">
        <figure class="image">
        	<cfset imgPath = "/assets/img/PlayerProfiles/114.JPG">
            <img src="#imgPath#" alt="image">
            <figcaption>
              <div class="caption">
                <h1 class="noTopSpace">Points Leaders</h1>
                <p>James Harden</p>
                </div>
            </figcaption>
        </figure>
        <div class="listing">
            <h4 class="noTopSpace">2. Kevin Durant</h4>
            <h4 class="noTopSpace">3. Kevin Love</h4>
            <h4 class="noTopSpace">4. Ricky Rubio</h4>
            <h4 class="noTopSpace">5. LeBron James</h4>
            <h4 class="noTopSpace">6. Damian Lillard</h4>
            <h4 class="noTopSpace">7. CJ McCollum</h4>
            <h4 class="noTopSpace">8. Devin Booker</h4>
            <h4 class="noTopSpace">9. Chris Paul</h4>
            <h4 class="noTopSpace">10. Zion Williamson</h4>
        </div>
    </div>
</div>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">

