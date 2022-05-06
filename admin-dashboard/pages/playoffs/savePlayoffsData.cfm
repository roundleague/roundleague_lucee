<!--- Page Specific CSS/JS Here --->

<cfoutput>

    <!--- Content Here --->
	<cfloop list="#form.fieldNames#" index="count" item="i">
		<cfset gameNumber = rematch("[\d]+",i)>
		<cfset homeOrAway = ''>
		<cfif findNoCase("home", i)>
			<cfset homeOrAway = 'homeTeamID'>
		<cfelse>
			<cfset homeOrAway = 'awayTeamID'>
		</cfif>
		<cfif i NEQ 'saveBtn'>
			<cfquery name="updatePlayoffSchedule" datasource="roundleague">
				UPDATE playoffs_schedule
				SET
					#homeOrAway# = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form["Game_" & gameNumber[1] & "_" & homeOrAway]#">
				WHERE playoffs_bracketID = 1 <!--- Fix later --->
				AND BracketGameID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#gameNumber[1]#">
			</cfquery>
		</cfif>
	</cfloop>

	<!--- <cfloop list="#playerIDList#" index="count" item="i">
	    <cfquery name="updatePlayerData" datasource="roundleague">
	    	UPDATE Players
	    	SET 
	    		position = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["position_" & i]#">,
	    		height = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["height_" & i]#">,
	    		weight = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#val(form["weight_" & i])#">,
	    		hometown = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["hometown_" & i]#">,
	    		school = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["school_" & i]#">,
	    		instagram = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["instagram_" & i]#">
	    	WHERE PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">;

	    	UPDATE roster
	    	SET JERSEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#val(form["jersey_" & i])#">
	    	WHERE PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
	    	AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">;
	    </cfquery>
	</cfloop> --->
</cfoutput>

