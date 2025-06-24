<cfsavecontent variable="htmlEmail">
<cfoutput>
<!DOCTYPE html>
<html>
<head>
    <title>Password Reset Request</title>
    <style>
        body, p, h1, h2, h3, h4, h5, h6 { margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background-color: ##f2f2f2; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; background-color: ##ffffff; }
        .header { text-align: center; margin-bottom: 20px; }
        .header img { max-width: 200px; }
        .content { padding: 20px; }
        .title { font-size: 24px; font-weight: bold; margin-bottom: 10px; }
        .text { font-size: 16px; margin-bottom: 20px; }
        .cta-button { display: inline-block; padding: 10px 20px; background-color: ##ffaa00; color: ##ffffff; font-size: 18px; text-decoration: none; border-radius: 5px; }
        .footer { text-align: center; margin-top: 20px; }
        .footer p { font-size: 12px; }
        .footer img { max-width: 50px; margin-top: 10px; }
        .socialMediaIcons { padding: 5px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <img src="https://static.wixstatic.com/media/b16829_f3a215a62a9f485990b0e43a0a993d3d~mv2.png/v1/fill/w_909,h_335,al_c,q_85,usm_0.66_1.00_0.01/4_edited.webp" alt="Basketball League Logo">
        <h1>Password Reset</h1>
    </div>
    <div class="content">
        <h2 class="title">Reset Your Password</h2>
        <p class="text">
            Hello,<br><br>
            We received a request to reset the password for your account (<b>#userEmail#</b>).<br><br>
            Please click the button below to set a new password. If you did not request this, you can safely ignore this email.
        </p>
        <a target="_blank" href="#resetLink#" class="cta-button">Reset Password</a>
        <p class="text" style="font-size:13px; margin-top:20px;">If the button above does not work, copy and paste this link into your browser:<br>#resetLink#</p>
    </div>
    <div class="footer">
        <p>Follow us on social media for more updates:</p>
        <a class="socialMediaIcons" href="https://www.instagram.com/theroundleague/" target="_blank"><img width="32" height="32" src="https://img.icons8.com/color/48/instagram-new--v1.png" alt="instagram-new--v1"/></a>
        <a class="socialMediaIcons" href="https://www.youtube.com/channel/UCOlYUrGXE-S_dxK1mjCW8Gw" target="_blank"><img width="32" height="32" src="https://img.icons8.com/color/48/youtube-play.png" alt="youtube-play"/></a>
        <a class="socialMediaIcons" href="https://www.linkedin.com/company/the-round-league/" target="_blank"><img width="32" height="32" src="https://img.icons8.com/color/48/linkedin.png" alt="linkedin"/></a>
        <br>
        <a href="https://goo.gl/maps/tUs7Jvvfgn4hi4HY8" target="_blank">4150 SW Watson Ave, Beaverton, OR 97005</a>
    </div>
</div>
</body>
</html>
</cfoutput>
</cfsavecontent>
