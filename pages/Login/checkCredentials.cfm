<cfoutput>
	<cfset access = false>
	<!--- Place holder security for statsapp / admin dashboard while we get user accounts set up later --->
	<cfquery name="getCredentials" datasource="roundleague">
		SELECT userName, password
		FROM users
		WHERE userID = 1
	</cfquery>
	<cfif form.userName EQ getCredentials.userName AND form.password EQ getCredentials.password>
		<cfset access = true>
	</cfif>
	<cfif access>
		<cfset session.loggedIn = true>
		<cflocation url="../StatsApp/StatsApp-Select.cfm">
	<cfelse>
		<span class="errorMsg">Credentials did not match, please try again.</span>
	</cfif>
</cfoutput>