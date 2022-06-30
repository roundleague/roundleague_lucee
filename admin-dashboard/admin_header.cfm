<!--
=========================================================
* Paper Dashboard 2 - v2.0.1
=========================================================

* Product Page: https://www.creative-tim.com/product/paper-dashboard-2
* Copyright 2020 Creative Tim (https://www.creative-tim.com)

Coded by www.creative-tim.com

 =========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-->

<!--- Admin security check --->
<cfif !isDefined("session.adminLoggedIn")>
  Access Denied.<cfabort />
</cfif>

<!doctype html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <link rel="apple-touch-icon" sizes="76x76" href="/admin-dashboard/assets/img/apple-icon.png">
  <link rel="icon" type="image/png" href="/admin-dashboard/assets/img/favicon.png">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <title>
    The Round League
  </title>
  <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0, shrink-to-fit=no' name='viewport' />
  <!--     Fonts and icons     -->
  <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700,200" rel="stylesheet" />
  <link href="https://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css" rel="stylesheet">
  <!-- CSS Files -->
  <link href="/admin-dashboard/assets/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/admin-dashboard/assets/css/paper-dashboard.css?v=2.0.1" rel="stylesheet" />
  <!-- CSS Just for demo purpose, don't include it in your project -->
  <link href="/admin-dashboard/assets/demo/demo.css" rel="stylesheet" />
  <link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">
</head>

<body class="">
  <div class="wrapper ">
    <div class="sidebar" data-color="white" data-active-color="danger">
      <div class="logo">
        <a href="/admin-dashboard/dashboard.cfm" class="simple-text logo-normal">
        <img src="https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp" alt="The Round League Logo">
          <!-- <div class="logo-image-big">
            <img src="./admin-dashboard/assets/img/logo-big.png">
          </div> -->
        </a>
      </div>
      <div class="sidebar-wrapper">
        <ul class="nav">
          <li>
            <a href="javascript:;">
              <i class="nc-icon nc-ruler-pencil"></i>
              <p>StatsApp</p>
            </a>
          </li>
          <li>
            <a href="javascript:;">
              <i class="nc-icon nc-laptop"></i>
              <p>Scoreboard</p>
            </a>
          </li>
          <li <cfif findNoCase("playerLookUp", CGI.REQUEST_URL)>class="active"</cfif>>
            <a href="/admin-dashboard/pages/playerLookup/playerLookup.cfm">
              <i class="nc-icon nc-pin-3"></i>
              <p>Player Info Lookup</p>
            </a>
          </li>
          <li <cfif findNoCase("teamsOverview", CGI.REQUEST_URL)>class="active"</cfif>>
            <a href="/admin-dashboard/pages/teamsOverview/teamsOverview.cfm">
              <i class="nc-icon nc-bullet-list-67"></i>
              <p>Teams Overview</p>
            </a>
          </li>
          <li <cfif findNoCase("scheduler", CGI.REQUEST_URL)>class="active"</cfif>>
            <a href="/admin-dashboard/pages/scheduler/scheduler.cfm">
              <i class="nc-icon nc-paper"></i>
              <p>Season Scheduler</p>
            </a>
          </li>
          <li <cfif findNoCase("playoffs", CGI.REQUEST_URL)>class="active"</cfif>>
            <a href="/admin-dashboard/pages/playoffs/playoffs.cfm">
              <i class="nc-icon nc-trophy"></i>
              <p>Playoffs</p>
            </a>
          </li>
          <li <cfif findNoCase("ideas", CGI.REQUEST_URL)>class="active"</cfif>>
            <a href="/admin-dashboard/pages/ideas/ideas.cfm">
              <i class="nc-icon nc-settings"></i>
              <p>Future Ideas</p>
            </a>
          </li>
        </ul>
      </div>
    </div>

    <div class="main-panel">
      <!-- Navbar -->
      <nav class="navbar navbar-expand-lg navbar-absolute fixed-top navbar-transparent">
        <div class="container-fluid">
          <div class="navbar-wrapper">
            <div class="navbar-toggle">
              <button type="button" class="navbar-toggler">
                <span class="navbar-toggler-bar bar1"></span>
                <span class="navbar-toggler-bar bar2"></span>
                <span class="navbar-toggler-bar bar3"></span>
              </button>
            </div>
            <a class="navbar-brand" href="javascript:;">Welcome, Valued Round League Staff Member</a>
          </div>
          <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navigation" aria-controls="navigation-index" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-bar navbar-kebab"></span>
            <span class="navbar-toggler-bar navbar-kebab"></span>
            <span class="navbar-toggler-bar navbar-kebab"></span>
          </button>
          <div class="collapse navbar-collapse justify-content-end" id="navigation">
            <form>
              <div class="input-group no-border">
                <input type="text" value="" class="form-control" placeholder="Search...">
                <div class="input-group-append">
                  <div class="input-group-text">
                    <i class="nc-icon nc-zoom-split"></i>
                  </div>
                </div>
              </div>
            </form>
            <ul class="navbar-nav">
              <li class="nav-item btn-rotate dropdown">
                <a class="nav-link dropdown-toggle" href="http://example.com" id="navbarDropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                  <i class="nc-icon nc-bell-55"></i>
                  <p>
                    <span class="d-lg-none d-md-block">Some Actions</span>
                  </p>
                </a>
                <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdownMenuLink">
                  <a class="dropdown-item" href="#">Action</a>
                  <a class="dropdown-item" href="#">Another action</a>
                  <a class="dropdown-item" href="#">Something else here</a>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </nav>

      <!--- Header --->