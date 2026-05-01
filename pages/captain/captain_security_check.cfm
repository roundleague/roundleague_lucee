<!--- Also add check for current session captain ID later --->
<!--- If captain is not logged in AND we are not on local env --->
<cfif !isDefined("session.captainLoggedIn")>
	Access Denied.<cfabort />
<cfelse>
	<cfif session.captainID NEQ url.playerID AND session.captainID NEQ 1001>
		Access Denied.<cfabort />
	</cfif>
</cfif>