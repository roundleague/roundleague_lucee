<!--- Verify user is logged in and accessing their own account --->
<cfif !isDefined("session.playerLoggedIn")>
    Access Denied.<cfabort />
<cfelse>
    <cfif session.playerID NEQ url.playerID>
        Access Denied.<cfabort />
    </cfif>
</cfif>
