<cfinclude template="/header.cfm">

<cfoutput>


  <div class="page-header video-container" data-parallax="true">
    <video playsinline autoplay muted loop>
        <source src="/assets/video/roundleague_promo.mp4" type="video/mp4" />
    </video>
    <div class="filter"></div>
    <div class="container">
      <div class="motto text-center">
        <!--- <h1 class="presentation-title">The Round League</h1> --->
        <img src="https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp" alt="The Round League Logo">
        <h2 class="presentation-subtitle text-center">Official Home of The Round League</h2>
        <br />
        <!--- <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" class="btn btn-outline-neutral btn-round"><i class="fa fa-play"></i>Watch video</a>
        <button type="button" class="btn btn-outline-neutral btn-round">Download</button> --->
      </div>
    </div>
  </div>
  <div class="main">
    <div class="section text-center">
      <div class="container">
        <div class="row">
          <div class="col-md-8 ml-auto mr-auto">
            <h2 class="title">A Higher Quality League</h2>
            <h5 class="description">We provide a high-quality interactive basketball experience to participants of all levels accompanied by comprehensive stat tracking, social media coverage, championship trophies, individual and team awards, and much more.</h5>
            <br>
            <!--- <a href="##paper-kit" class="btn btn-danger btn-round">See Details</a> --->
          </div>
        </div>
        <br/>
        <br/>
        <div class="row">
          <div class="col-md-3">
            <div class="info">
              <div class="icon icon-danger">
                <i class="nc-icon nc-circle-10"></i>
              </div>
              <div class="description">
                <h4 class="info-title">Team Profiles</h4>
                <p class="description">Show off your roster with team pages that list each player profile along with professional photography headshots.</p>
                <!--- <a href="javascript:;" class="btn btn-link btn-danger">See more</a> --->
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="info">
              <div class="icon icon-danger">
                <i class="nc-icon nc-bulb-63"></i>
              </div>
              <div class="description">
                <h4 class="info-title">Innovation</h4>
                <p>A league that strives to bring new fresh ideas to provide the best basketball league experience possible. You're the pro now.</p>
                <!--- <a href="javascript:;" class="btn btn-link btn-danger">See more</a> --->
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="info">
              <div class="icon icon-danger">
                <i class="nc-icon nc-chart-bar-32"></i>
              </div>
              <div class="description">
                <h4 class="info-title">Statistics</h4>
                <p>Get in-depth player and team statistics. View box scores, player averages, schedules, all in one place.</p>
                <!--- <a href="javascript:;" class="btn btn-link btn-danger">See more</a> --->
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="info">
              <div class="icon icon-danger">
                <i class="nc-icon nc-trophy"></i>
              </div>
              <div class="description">
                <h4 class="info-title">Awards</h4>
                <p>Play for something worth holding onto. Assists Leader. Rebounds Leader. Scoring Champ. League MVP. The Championship Trophy. All come with a physical trophy to take home and store in your trophy case.</p>
                <!--- <a href="javascript:;" class="btn btn-link btn-danger">See more</a> --->
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <cfinclude template="socialMediaFeed.cfm">
  </div>
</cfoutput>
<cfinclude template="/footer.cfm">
