<!--- playerID 1001 admin bypass — passes regardless of captain login state --->
<cfif isDefined("session.playerID") AND session.playerID EQ 1001>
	<!--- allowed --->
<cfelseif !isDefined("session.captainLoggedIn")>
	Access Denied.<cfabort />
<cfelse>
	<cfif session.captainID NEQ url.playerID>
		Access Denied.<cfabort />
	</cfif>
</cfif>