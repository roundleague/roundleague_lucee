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
	<cfquery name="addSeason" datasource="roundleague">
		INSERT INTO Seasons 
		(
			SeasonName,
			Status,
			PreviousSeasonID,
			StartDate,
			EndDate
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.newSeasonName#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="Inactive">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#getPreviousSeasonID.seasonID#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(form.startDate, "mm/dd/yyyy")#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(form.endDate, "mm/dd/yyyy")#">
		)
	</cfquery>
	<cfset toastMsg = 'Successfully added season!'>
</cfif>

</cfoutput>