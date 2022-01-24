<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<cfquery name="checkConfirmationCode" datasource="roundleague">
  SELECT userID
  FROM pending_signups
  WHERE ConfirmationCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.hashCode#">
  and userID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.userID#">
</cfquery>

<cfif checkConfirmationCode.recordCount>

  <cfquery name="updateUserAccount" datasource="roundleague">
      UPDATE users
      SET Status = 'Active'
      WHERE userID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.userID#">
  </cfquery>

  <cfquery name="getPlayerId" datasource="roundleague">
      SELECT playerID
      FROM users
      WHERE userID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.userID#">
  </cfquery>

  <cfset session.captainLoggedIn = true>

  <cflocation url="../captain/captain.cfm?playerID=#getPlayerId.playerID#">

<cfelse>
  Invalid hash code.<cfabort />
</cfif>

</cfoutput>

<cfinclude template="/footer.cfm">