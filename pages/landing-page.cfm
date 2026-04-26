<cfinclude template="/header.cfm">

<cfoutput>
  <div class="page-header video-container">
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
  <!--- ====== APP PROMO SECTION ====== --->
  <div class="main">
</cfoutput>
<style>
    .rl-app-promo {
      background: #0d0d0d;
      color: #fff;
      padding: 72px 20px 64px;
      text-align: center;
      position: relative;
      overflow: hidden;
    }
    .rl-app-promo::before {
      content: '';
      position: absolute;
      inset: 0;
      background: radial-gradient(ellipse 80% 60% at 50% 0%, rgba(220,0,0,0.18) 0%, transparent 70%);
      pointer-events: none;
    }
    .rl-promo-inner {
      position: relative;
      max-width: 1040px;
      margin: 0 auto;
    }
    .rl-promo-logo {
      display: block;
      margin: 0 auto 20px;
      height: 160px;
      width: auto;
    }
    .rl-promo-title {
      font-size: clamp(32px, 6vw, 64px);
      font-weight: 900;
      line-height: 1.05;
      text-transform: uppercase;
      letter-spacing: -0.01em;
      margin: 0 0 6px;
      color: #fff;
    }
    .rl-promo-title-red {
      display: block;
      color: #dc0000;
      font-style: italic;
      font-size: clamp(44px, 9vw, 96px);
      line-height: 0.95;
      letter-spacing: -0.02em;
    }
    .rl-promo-sub {
      font-size: clamp(11px, 1.6vw, 14px);
      font-weight: 700;
      letter-spacing: 0.18em;
      text-transform: uppercase;
      color: #ccc;
      margin: 18px 0 48px;
    }
    .rl-phones {
      display: flex;
      align-items: flex-end;
      justify-content: center;
      gap: 24px;
      margin: 0 auto 52px;
      padding: 20px 0 50px;
      position: relative;
    }
    .rl-phones::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 10%;
      right: 10%;
      height: 80px;
      background: radial-gradient(ellipse 70% 100% at 50% 100%, rgba(220,0,0,0.14) 0%, transparent 70%);
      pointer-events: none;
    }
    .rl-phone {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 14px;
    }
    .rl-phone--left {
      transform: rotate(-7deg) translateY(48px);
    }
    .rl-phone--right {
      transform: rotate(7deg) translateY(48px);
    }
    .rl-phone-frame {
      border-radius: 38px;
      overflow: hidden;
      border: 1.5px solid rgba(255,255,255,0.10);
      box-shadow:
        0 30px 70px rgba(0,0,0,0.75),
        0 0 0 1px rgba(255,255,255,0.03);
      width: 185px;
    }
    .rl-phone--center .rl-phone-frame {
      width: 220px;
      border-color: rgba(220,0,0,0.35);
      box-shadow:
        0 30px 80px rgba(0,0,0,0.8),
        0 0 55px rgba(220,0,0,0.20),
        0 0 0 1px rgba(220,0,0,0.12);
    }
    .rl-phone-frame img {
      width: 100%;
      display: block;
    }
    .rl-phone-label {
      font-size: 10px;
      font-weight: 800;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: #444;
      margin: 0;
    }
    .rl-phone--center .rl-phone-label {
      color: #dc0000;
    }
    @media (max-width: 860px) {
      .rl-phone-frame { width: 145px; border-radius: 30px; }
      .rl-phone--center .rl-phone-frame { width: 170px; border-radius: 30px; }
      .rl-phone--left { transform: rotate(-5deg) translateY(32px); }
      .rl-phone--right { transform: rotate(5deg) translateY(32px); }
      .rl-phones { gap: 16px; }
    }
    @media (max-width: 560px) {
      .rl-phones { gap: 8px; padding-bottom: 40px; }
      .rl-phone-frame { width: 100px; border-radius: 22px; }
      .rl-phone--center .rl-phone-frame { width: 120px; border-radius: 24px; }
      .rl-phone--left { transform: rotate(-5deg) translateY(28px); }
      .rl-phone--right { transform: rotate(5deg) translateY(28px); }
      .rl-phone-label { font-size: 9px; }
    }
    @media (max-width: 380px) {
      .rl-phone-frame { width: 85px; border-radius: 18px; }
      .rl-phone--center .rl-phone-frame { width: 105px; border-radius: 20px; }
    }
    .rl-appstore-btn {
      display: inline-flex;
      align-items: center;
      gap: 12px;
      background: #fff;
      color: #000;
      text-decoration: none;
      padding: 14px 28px;
      border-radius: 12px;
      font-weight: 700;
      font-size: 16px;
      transition: background 0.15s, transform 0.15s;
      margin-bottom: 24px;
    }
    .rl-appstore-btn:hover {
      background: #f0f0f0;
      color: #000;
      text-decoration: none;
      transform: translateY(-2px);
    }
    .rl-appstore-btn svg {
      width: 22px;
      height: 22px;
      flex-shrink: 0;
    }
    .rl-appstore-btn-text { text-align: left; line-height: 1.2; }
    .rl-appstore-btn-text small { display: block; font-size: 10px; font-weight: 500; color: #555; letter-spacing: 0.04em; }
    .rl-promo-footer-text {
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: #555;
    }
    .rl-promo-divider {
      color: #dc0000;
      margin: 0 8px;
    }
    .rl-promo-used {
      margin-top: 10px;
      font-size: 12px;
      color: #888;
      font-weight: 600;
    }
    .rl-promo-used strong { color: #dc0000; }
</style>
<cfoutput>

  <section class="rl-app-promo">
    <div class="rl-promo-inner">
      <h2 class="rl-promo-title">
        The Round League
        <span class="rl-promo-title-red">App Is Here</span>
      </h2>
      <p class="rl-promo-sub">Live Stats &nbsp;&bull;&nbsp; Real-Time Scores &nbsp;&bull;&nbsp; All In One App</p>

      <div class="rl-phones">
        <div class="rl-phone rl-phone--left">
          <div class="rl-phone-frame">
            <img src="/assets/img/mobile-app-promo/app_schedule.png" alt="Schedule">
          </div>
          <span class="rl-phone-label">Schedules</span>
        </div>
        <div class="rl-phone rl-phone--center">
          <div class="rl-phone-frame">
            <img src="/assets/img/mobile-app-promo/app_playerprofile.png" alt="Player Profile">
          </div>
          <span class="rl-phone-label">Player Profiles</span>
        </div>
        <div class="rl-phone rl-phone--right">
          <div class="rl-phone-frame">
            <img src="/assets/img/mobile-app-promo/app_standings.png" alt="Standings">
          </div>
          <span class="rl-phone-label">Standings</span>
        </div>
      </div>

      <a href="https://apps.apple.com/app/the-round-league/id6743745800" class="rl-appstore-btn" target="_blank" rel="noopener">
        <i class="fa-brands fa-apple" style="font-size:22px;"></i>
        <span class="rl-appstore-btn-text">
          <small>Download on the</small>
          App Store
        </span>
      </a>

      <div class="rl-promo-footer-text">
        Free to Download
        <span class="rl-promo-divider">|</span>
        Updated Weekly During the Season
      </div>
      <div class="rl-promo-used">Used by <strong>400+ players</strong> in The Round League</div>
    </div>
  </section>

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
