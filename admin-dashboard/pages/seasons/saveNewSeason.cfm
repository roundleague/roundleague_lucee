<!--- Page Specific CSS/JS Here --->

<cfoutput>

<cfquery name="checkDuplicate" datasource="roundleague">
	SELECT seasonID
	FROM seasons
	WHERE seasonName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.newSeasonName#">
</cfquery>

<cfif checkDuplicate.recordCount>
	<cfset toastMsg = 'There is already a season with that name. Please enter a unique season name.'>
<cfelse>
	<cfquery name="getPreviousSeasonID" datasource="roundleague">
		SELECT seasonID
		FROM seasons
		ORDER BY seasonID Desc
		LIMIT 1
	</cfquery>
	<cfquery name="addPlayer" datasource="roundleague" result="playerAdd">
		INSERT INTO Seasons 
		(
			SeasonName,
			Status,
			PreviousSeasonID
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.newSeasonName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Inactive">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#getPreviousSeasonID.seasonID#">
		)
	</cfquery>
	<cfset toastMsg = 'Successfully added season!'>
</cfif>

</cfoutput>