<cfoutput>
	<cfset access = false>
	<!--- Place holder security for statsapp / admin dashboard while we get user accounts set up later --->
	<cfquery name="getCredentials" datasource="roundleague">
		SELECT userID, userName, password, playerID
		FROM users
		WHERE userID = 1
	</cfquery>
	<cfif form.userName EQ getCredentials.userName AND form.password EQ getCredentials.password>
		<cfset access = true>
	</cfif>
	<cfif access>
		<cfset session.loggedIn = true>
		<cfset session.currentSessionUserID = getCredentials.userID>
		<cfif len(trim(getCredentials.playerID))>
			<cfquery name="getPlayerName" datasource="roundleague">
				SELECT firstName, lastName
				FROM players
				WHERE PlayerID = <cfqueryparam value="#getCredentials.playerID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfif getPlayerName.recordCount AND len(trim(getPlayerName.firstName))>
				<cfset session.userName = trim(getPlayerName.firstName & " " & getPlayerName.lastName)>
			<cfelse>
				<cfset session.userName = getCredentials.userName>
			</cfif>
		<cfelse>
			<cfset session.userName = getCredentials.userName>
		</cfif>
		<cflocation url="../StatsApp/StatsApp-Select.cfm">
	<cfelse>
		<span class="errorMsg">Credentials did not match, please try again.</span>
	</cfif>
</cfoutput>