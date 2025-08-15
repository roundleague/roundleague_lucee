<cfcomponent displayname="RateLimiter" hint="Reusable in-memory rate limiter">

    <!--- Ensure application struct exists --->
    <cffunction name="ensureInit" access="public" returntype="void">
        <cfif NOT structKeyExists(application, "rateBuckets")>
            <cfset application.rateBuckets = structNew()>
        </cfif>
    </cffunction>

    <!--- Check and update rate limit for a bucketKey --->
    <cffunction name="check" access="public" returntype="struct">
        <cfargument name="bucketKey" type="string" required="true">
        <cfargument name="limitPerWindow" type="numeric" required="true">
        <cfargument name="windowSec" type="numeric" required="true">
        <cfset ensureInit()>
        <cfset var nowMs = getTickCount()>
        <cfset var windowMs = arguments.windowSec * 1000>
        <cfif structKeyExists(application.rateBuckets, arguments.bucketKey)>
            <cfset var bucket = application.rateBuckets[arguments.bucketKey]>
        <cfelse>
            <cfset var bucket = {
                count = 0,
                resetAt = nowMs + windowMs
            }>
        </cfif>
        <!--- Reset if window expired --->
        <cfif nowMs GT bucket.resetAt>
            <cfset bucket.count = 0>
            <cfset bucket.resetAt = nowMs + windowMs>
        </cfif>
        <cfset bucket.count = bucket.count + 1>
        <cfset application.rateBuckets[arguments.bucketKey] = bucket>
        <cfset var allowed = bucket.count LTE arguments.limitPerWindow>
        <cfset var remaining = arguments.limitPerWindow - bucket.count>
        <cfif remaining LT 0><cfset remaining = 0></cfif>
        <cfreturn {
            allowed = allowed,
            count = bucket.count,
            limit = arguments.limitPerWindow,
            resetAt = bucket.resetAt,
            remaining = remaining
        }>
    </cffunction>

</cfcomponent>
