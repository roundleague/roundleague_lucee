<!--- Page Specific CSS/JS Here --->

<cfoutput>

    <!--- Content Here --->
	<cfset playerIDList = form.playerIDList>

	<cfloop list="#playerIDList#" index="count" item="i">
	    <cfquery name="updatePlayerData" datasource="roundleague">
	    	UPDATE Players
	    	SET 
	    		position = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["position_" & i]#">,
	    		height = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["height_" & i]#">,
	    		weight = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form["weight_" & i])#">,
	    		hometown = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["hometown_" & i]#">,
	    		school = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["school_" & i]#">,
	    		instagram = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["instagram_" & i]#">
	    	WHERE PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
	    </cfquery>
	</cfloop>
</cfoutput>

