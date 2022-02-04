<!--- Also add check for current session captain ID later --->
<cfif !isDefined("session.captainLoggedIn") AND !findNoCase("127.0.0.1", CGI.HTTP_HOST)>
	Access Denied.<cfabort />
</cfif>