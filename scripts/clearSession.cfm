<cfset StructClear(Session)>
<cfif isDefined("url.redirect")>
    <cflocation url="#url.redirect#" addtoken="false">
</cfif>