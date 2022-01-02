<!--- <cfif FindNoCase("testing.theroundleague.com", CGI.REQUEST_URL)>
  <cfif !FindNoCase("50.126.101.19", CGI.remote_addr)>
    <cfdump var="Access Denied." /><cfabort />
  </cfif>
</cfif> --->

<!DOCTYPE html>

<html lang="en">

<!--- Session / Application Variables --->
<cfquery name="currentSeason" datasource="roundleague">
  SELECT SeasonID
  FROM Seasons
  Where Status = 'Active'
</cfquery>
<cfset session.currentSeasonID = currentSeason.seasonID>
<head>
  <meta charset="utf-8" />
  <link rel="apple-touch-icon" sizes="76x76" href="/assets/img//apple-icon.png">
  <link rel="icon" type="image/png" href="/assets/img/Logos/favicon.png">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <title>
    Portland's Premiere Basketball League | The Round League
  </title>
  <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0, shrink-to-fit=no' name='viewport' />
  <!--     Fonts and icons     -->
  <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700,200" rel="stylesheet" />
  <link href="https://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css" rel="stylesheet">
  <!-- CSS Files -->
  <link href="/assets/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/assets/css/paper-kit.css?v=2.2.0" rel="stylesheet" />
  <link href="/assets/css/shared/responsive_tables.css" rel="stylesheet" />
  <!-- CSS Just for demo purpose, don't include it in your project -->
  <link href="/assets/demo/demo.css" rel="stylesheet" />
  <link href="/pages/landing-page.css" rel="stylesheet" />
</head>
<body class="landing-page sidebar-collapse">
  <!-- Navbar -->
  <cfif findNoCase("landing-page", CGI.path_translated)>
    <nav class="navbar navbar-expand-lg fixed-top navbar-transparent " color-on-scroll="300">
  <cfelse>
    <nav class="navbar navbar-expand-lg fixed-top">
  </cfif>
    <div class="container">
      <div class="navbar-translate">
        <a class="navbar-brand" href="https://demos.creative-tim.com/paper-kit/index.html" rel="tooltip" title="Coded by Creative Tim" data-placement="bottom" target="_blank">
          The Round League
        </a>
        <button class="navbar-toggler navbar-toggler" type="button" data-toggle="collapse" data-target="##navigation" aria-controls="navigation-index" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-bar bar1"></span>
          <span class="navbar-toggler-bar bar2"></span>
          <span class="navbar-toggler-bar bar3"></span>
        </button>
      </div>
      <div class="collapse navbar-collapse justify-content-end" id="navigation">
        <ul class="navbar-nav">
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" title="Follow us on Twitter" data-placement="bottom" href="/pages/landing-page.cfm">
              Home
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" title="Like us on Facebook" data-placement="bottom" href="/pages/Standings/standings.cfm">
              Standings
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" data-placement="bottom" href="/pages/schedule/schedule-2.cfm">
              Schedule
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" data-placement="bottom" href="/pages/teams/teams-2.cfm">
              Teams
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" data-placement="bottom" href="/pages/register/register.cfm">
              Register
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" rel="tooltip" data-placement="bottom" href="https://docs.google.com/document/d/e/2PACX-1vSAgkeAcc_34PTnJmDjb6HyDuPRYyNfGmLdywFtEB_ePATrRs0ficHVOlW50n8SiPUvApGp1OV6Kaw4/pub" target="_blank">
              League Rules
            </a>
          </li>
            <div class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" data-toggle="dropdown" id="dropdownMenuButton" href="##pk" role="button" aria-haspopup="true" aria-expanded="false">More</a>
              <ul class="dropdown-menu dropdown-info" aria-labelledby="dropdownMenuButton">
                <li class="dropdown-header">Stats</li>
                <a class="dropdown-item" href="/pages/stats/leagueLeaders.cfm">League Leaders</a>
                <div class="dropdown-divider"></div>
                <a class="dropdown-item" href="/pages/Contact/contact.cfm">Contact</a>
                <div class="dropdown-divider"></div>
                <a target="_blank" class="dropdown-item" href="/pages/login/login.cfm">StatsApp</a>
                <cfif !FindNoCase("testing.theroundleague.com", CGI.REQUEST_URL)>
                  <div class="dropdown-divider"></div>
                  <a class="dropdown-item" href="/assets/espn_scoreboard/scoreboard.html">Scoreboard</a>
                </cfif>
              </ul>
            </div>
        </ul>
      </div>
    </div>
  </nav>