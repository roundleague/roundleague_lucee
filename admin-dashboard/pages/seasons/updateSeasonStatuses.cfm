<!--- Page Specific CSS/JS Here --->

<cfoutput>
	<cfloop list="#form.seasonIDList#" index="count" item="i">
		<cfquery name="updateSeasons" datasource="roundleague">
			UPDATE Seasons
			SET Status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["status_" & i]#">
			WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">
		</cfquery>
	</cfloop>
	<cfset toastMsg = 'Successfully saved season statuses!'>

</cfoutput>