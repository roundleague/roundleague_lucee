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
</cfoutput>

