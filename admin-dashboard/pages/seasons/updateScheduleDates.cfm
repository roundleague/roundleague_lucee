<cfoutput>
<!--- Loop through each week of new season and set the date 1 week after previous date --->
<!--- Problem: Games on different days. Womens = Mon, Weds, Men = Sat, Sun --->
<!--- This is Sat --->
<cfquery name="getStartDate" datasource="roundleague">
	SELECT startDate
	FROM seasons
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
</cfquery>
<!--- Get the Sun, Mon, Weds after startDate --->

<!--- Sunday --->
<cfif dayOfWeek(getStartDate.startDate) gt 1>
    <cfset NextSunday = dateAdd("d", 8 - dayOfWeek(getStartDate.startDate), getStartDate.startDate)>
</cfif>

<!--- Monday --->
<cfif dayOfWeek(getStartDate.startDate) gt 1>
    <cfset NextMonday = dateAdd("d", 9 - dayOfWeek(getStartDate.startDate), getStartDate.startDate)>
<cfelse>
    <cfset NextMonday = dateAdd("d", 1, getStartDate.startDate)>
</cfif>

<!--- Wednesday --->
<cfif dayOfWeek(getStartDate.startDate) gt 1>
    <cfset NextWeds = dateAdd("d", 11 - dayOfWeek(getStartDate.startDate), getStartDate.startDate)>
<cfelse>
    <cfset NextWeds = dateAdd("d", 3, getStartDate.startDate)>
</cfif>

<cfquery name="getNewSchedule" datasource="roundleague">
	SELECT scheduleID, week, DAYOFWEEK(DATE) as DayOfWeek
	FROM schedule
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
</cfquery>

<!--- Week 2, 3, 4, etc, just update schedule date to be past week + 7, by divisionID --->
<cfquery name="getUniqueDivision" datasource="roundleague">
	SELECT distinct divisionID
	FROM schedule
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
</cfquery>

<!--- MySQL Day of the Weeks Key --->
<!--- Sat = 7, Sun = 1, Mon = 2, Weds = 4 --->
<cfloop query="getNewSchedule">
	<cfif getNewSchedule.week EQ 8>
		<!--- Do not include play in games, which are designated as week 8 right now --->
		<cfbreak>
	<cfelseif getNewSchedule.week EQ 1>
		<cfswitch expression="#getNewSchedule.DayOfWeek#">
			<cfcase value="7">
				<!--- Sat --->
				<cfquery name="setDate" datasource="roundleague">
					UPDATE schedule
					SET date = <cfqueryparam cfsqltype="cf_sql_date" value="#getStartDate.startDate#">
					WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.scheduleID#">
				</cfquery>
			</cfcase>
			<cfcase value="1">
				<!--- Sun --->
				<cfquery name="setDate" datasource="roundleague">
					UPDATE schedule
					SET date = <cfqueryparam cfsqltype="cf_sql_date" value="#NextSunday#">
					WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.scheduleID#">
				</cfquery>
			</cfcase>
			<cfcase value="2">
				<!--- Mon --->
				<cfquery name="setDate" datasource="roundleague">
					UPDATE schedule
					SET date = <cfqueryparam cfsqltype="cf_sql_date" value="#NextMonday#">
					WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.scheduleID#">
				</cfquery>
			</cfcase>
			<cfcase value="4">
				<!--- Weds --->
				<cfquery name="setDate" datasource="roundleague">
					UPDATE schedule
					SET date = <cfqueryparam cfsqltype="cf_sql_date" value="#NextWeds#">
					WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.scheduleID#">
				</cfquery>
			</cfcase>
		</cfswitch>
	<cfelse>
		<!--- Week 2, 3, 4, etc, just update schedule date to be past week + 7, by divisionID --->
		<cfloop query="getUniqueDivision">
			<!--- currently not working --->
			<cfquery name="updateDate" datasource="roundleague">
				UPDATE schedule
				SET date = (
						SELECT DATE_ADD(date, INTERVAL 7 DAY) 
						FROM schedule 
						WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
						AND divisionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getUniqueDivision.divisionID#">
						AND week = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.Week#"> - 1
						LIMIT 1)
				WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getNewSchedule.scheduleID#">
			</cfquery>
		</cfloop>
	</cfif>
</cfloop>
</cfoutput>