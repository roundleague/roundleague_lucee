
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfsavecontent variable="htmlEmail">
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" integrity="sha512-7m/EwMxK0ABDm0gxtYzUKbAaE0WTzr7aBUh/Rka2kHwGx8j+DpMSn6oEGYbFddDjpE67nsFzRSLgxJyktj+CTw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <title>Basketball League Newsletter</title>
    <style>
        /* Reset styles to ensure consistent rendering across email clients */
        body, p, h1, h2, h3, h4, h5, h6 {
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, sans-serif;
            background-color: #f2f2f2;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }

        .header {
            text-align: center;
            margin-bottom: 20px;
        }

        .header img {
            max-width: 200px;
        }

        .content {
            padding: 20px;
        }

        .content img {
            max-width: 100%;
            height: auto;
            margin-bottom: 20px;
        }

        .title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .subtitle {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .text {
            font-size: 16px;
            margin-bottom: 20px;
        }

        .cta-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #ffaa00;
            color: #ffffff;
            font-size: 18px;
            text-decoration: none;
            border-radius: 5px;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
        }

        .footer p {
            font-size: 12px;
        }

        .footer img {
            max-width: 50px;
            margin-top: 10px;
        }

        .socialMediaIcons {
            padding: 5px;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <img src="https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp" alt="Basketball League Logo">
        <h1>Captain's Notice</h1>
    </div>
    <div class="content">
        <h2 class="title">Team Size Reminder</h2>
        <img src="https://embedsocial.com/admin/media/feed-media/17980/17980164305026657/image_0_large.jpeg" alt="Latest News Image">
        <p class="text">
            Hello, captain! <br><br>
            We are excited to start the upcoming Spring 2023 season with you. Your team is currently over the 
            maximum roster limit (12). <br><br>
            Please log into your captains portal remove any players that are no longer on the team. You can do so by pressing the link below. <br><br>
            If you have forgotten your email / password, please email theroundleague@gmail.com to reset your account.
        </p>
        <a target="_blank" href="https://www.theroundleague.com/pages/login/captains_login.cfm" class="cta-button">Captain's Login</a>
    </div>
    <div class="footer">
        <p>Follow us on social media for more updates:</p>
        <a class="socialMediaIcons" href="https://www.instagram.com/theroundleague/" target="_blank"><i class="fa fa-instagram" aria-hidden="true"></i></a>
        <a class="socialMediaIcons" href="https://www.youtube.com/channel/UCOlYUrGXE-S_dxK1mjCW8Gw" target="_blank"><i class="fa fa-youtube" aria-hidden="true"></i></a>
        <a class="socialMediaIcons" href="https://www.linkedin.com/company/the-round-league/" target="_blank"><i class="fa fa-linkedin" aria-hidden="true"></i></a>
        <br>
        <a href="https://goo.gl/maps/tUs7Jvvfgn4hi4HY8" target="_blank">4150 SW Watson Ave, Beaverton, OR 97005</a>
    </div>

</div>
</body>
</html>
</cfsavecontent>

<!--- Query Section --->
<cfquery name="getTeamsAboveRosterLimit"  datasource="roundleague">
    SELECT COUNT(playerID) AS teamSize, t.teamName
    FROM roster r
    JOIN teams t ON r.teamID = t.teamID
    WHERE t.status = 'Active'
    AND r.seasonID = 9
    GROUP BY r.teamID
    HAVING COUNT(playerID) > 12
</cfquery>

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <cfset toEmail = 'huynt553@gmail.com'>
      <h3 class="description">Email Test - sending to #toEmail#</h3>

        <!--- <cfmail
          from="mailadmin@theroundleague.com"
          to="#toEmail#"
          subject="Email Test"
          type="HTML">
        
        #htmlEmail#

        </cfmail> --->

        <h2>Email Preview</h2>
        #htmlEmail#


    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
