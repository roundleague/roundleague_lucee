<cfparam name="form.teamID" default="0">

<cfoutput>
<cfif form.teamID GT 0>
    <!--- Get team and captain info --->
    <cfquery name="getTeamInfo" datasource="roundleague">
        SELECT 
            t.teamID, 
            t.teamName, 
            d.DivisionName,
            p.firstName,
            p.lastName,
            p.email AS captainEmail,
            p.playerID AS captainID
        FROM 
            teams t
        LEFT JOIN 
            divisions d ON d.divisionID = t.DivisionID
        LEFT JOIN 
            players p ON p.PlayerID = t.captainPlayerID
        WHERE 
            t.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
    </cfquery>
    
    <cfinclude template="/pages/account/payments/get_team_payment_status.cfm">
    <cfset teamStatus = getTeamPaymentStatus(teamID=form.teamID, seasonID=session.currentSeasonID)>
    
    <!--- Get all players on the team --->
    <cfquery name="getPlayers" datasource="roundleague">
        SELECT 
            p.firstName,
            p.lastName,
            p.email
        FROM 
            Roster r
        JOIN 
            Players p ON p.playerID = r.playerID
        WHERE 
            r.teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">
        AND 
            r.seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        AND 
            p.email IS NOT NULL
    </cfquery>
    
    <!--- Prepare email recipient list --->
    <cfset recipientList = getTeamInfo.captainEmail>
    <cfloop query="getPlayers">
        <cfif len(email) AND email NEQ getTeamInfo.captainEmail>
            <cfset recipientList = listAppend(recipientList, email)>
        </cfif>
    </cfloop>
    
    <!--- Send email --->
    <cfmail 
        to="#getTeamInfo.captainEmail#"
        bcc="#recipientList#"
        from="noreply@roundleague.com"
        subject="Payment Reminder - #getTeamInfo.teamName# - Season #session.currentSeasonID#"
        type="html">
        <h2>Payment Reminder - Season #session.currentSeasonID#</h2>
        
        <p>Dear #getTeamInfo.firstName#,</p>
        
        <p>This is a friendly reminder about your team's payment for the current season.</p>
        
        <h3>Team Payment Status</h3>
        <table style="border-collapse: collapse; width: 100%;">
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Team Name:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;"><strong>#getTeamInfo.teamName#</strong></td>
            </tr>
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Division:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;">#getTeamInfo.DivisionName#</td>
            </tr>
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Season:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;">#session.currentSeasonID#</td>
            </tr>
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Total Team Fee:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;">$#numberFormat(teamStatus.teamFee, '999,999.00')#</td>
            </tr>
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Amount Paid:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;">$#numberFormat(teamStatus.totalPaid, '999,999.00')#</td>
            </tr>
            <tr>
                <td style="padding: 8px; border: 1px solid ##ddd;">Remaining Balance:</td>
                <td style="padding: 8px; border: 1px solid ##ddd;"><strong>$#numberFormat(teamStatus.remainingBalance, '999,999.00')#</strong></td>
            </tr>
        </table>
        
        <p>Please make the payment at your earliest convenience. You can make payments through our online payment system:</p>
        
        <p><a href="https://#cgi.server_name#/pages/account/payments/payment_status.cfm?playerID=#getTeamInfo.captainID#" style="background-color: ##4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; display: inline-block;">Make a Payment</a></p>
        
        <p>Players can make individual contributions to help meet the team fee. The suggested amount per player is $#numberFormat(1000/getPlayers.recordCount, '999')#.</p>
        
        <p>If you have any questions about your payment, please contact us.</p>
        
        <p>Thank you for your prompt attention to this matter.</p>
        
        <p>Best regards,<br>
        The Round League Team</p>
    </cfmail>
    
    <!--- Log the reminder --->
    <cfquery datasource="roundleague">
        INSERT INTO payment_reminders (
            team_id, 
            sent_on, 
            sent_by, 
            amount_due
        ) VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.teamID#">,
            <cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#cgi.auth_user#">,
            <cfqueryparam cfsqltype="CF_SQL_DECIMAL" value="#teamStatus.remainingBalance#">
        )
    </cfquery>
    
    {"success": true, "message": "Payment reminder sent to #getTeamInfo.teamName# team."}
<cfelse>
    {"success": false, "message": "Invalid team ID."}
</cfif>
</cfoutput>
