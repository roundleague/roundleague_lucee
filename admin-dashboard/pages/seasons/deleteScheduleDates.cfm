<!--- Delete schedule to make way for autoscheduler --->
<!--- Keeping old previous schedule copy logic in tact because it is needed for  --->
<!--- Keeping teams in correct divisions --->
<!--- Basically, it will copy the schedule than delete it... not ideal but will do for now --->
<cfquery name="deleteSchedule" datasource="roundleague">
	DELETE FROM schedule
	WHERE seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.progressToSeasonId#">
</cfquery>