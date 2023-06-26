<cfoutput>

<cfquery name="updateStatsFromTo" datasource="roundleague">
	UPDATE playergamelog
	SET playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.toPlayer#">
	WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.fromPlayer#">
	AND playergamelogID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.playerGameLogID#">
</cfquery>

<!--- Update averages logic / insert new player stats --->
<cfquery name="checkExistingPlayerStats" datasource="roundleague">
    SELECT playerID
    FROM PlayerStats
    Where SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    AND PlayerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.toPlayer#">
</cfquery>
<cfif checkExistingPlayerStats.recordCount>
    <cfquery name="updateStats" datasource="roundleague" result="updateResult">
        UPDATE playerStats
        SET 
            Points = (SELECT CAST(AVG(POINTS) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            Rebounds = (SELECT CAST(AVG(Rebounds) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            Assists = (SELECT CAST(AVG(Assists) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            Steals = (SELECT CAST(AVG(Steals) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            Blocks = (SELECT CAST(AVG(Blocks) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            Turnovers = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            FGM = (SELECT CAST(AVG(FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            FGA = (SELECT CAST(AVG(FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            3FGM = (SELECT CAST(AVG(3FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            3FGA = (SELECT CAST(AVG(3FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            FTM = (SELECT CAST(AVG(FTM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            FTA = (SELECT CAST(AVG(FTA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.toPlayer# AND SeasonID = #session.currentSeasonID#),
            GamesPlayed = GamesPlayed + 1
        WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.toPlayer#">
        AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
    </cfquery>
<cfelse>
	<!--- For now they just gonna have to wait until they play next game for updated stat averages for new players --->
    <!--- If we want to update new player averages right away, we will need to bring over all the stats as form variables --->
</cfif>

<!--- Always reset fromPlayer regardless --->
<!--- Reset playerFrom stats, subtract 1 games played --->
<cfquery name="resetPlayerFromStats" datasource="roundleague">
    UPDATE playerStats
    SET 
        Points = (SELECT CAST(AVG(POINTS) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        Rebounds = (SELECT CAST(AVG(Rebounds) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        Assists = (SELECT CAST(AVG(Assists) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        Steals = (SELECT CAST(AVG(Steals) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        Blocks = (SELECT CAST(AVG(Blocks) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        Turnovers = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        FGM = (SELECT CAST(AVG(FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        FGA = (SELECT CAST(AVG(FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        3FGM = (SELECT CAST(AVG(3FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        3FGA = (SELECT CAST(AVG(3FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        FTM = (SELECT CAST(AVG(FTM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        FTA = (SELECT CAST(AVG(FTA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #form.fromPlayer# AND SeasonID = #session.currentSeasonID#),
        GamesPlayed = GamesPlayed - 1
    WHERE playerID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.fromPlayer#">
    AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
</cfquery>



<!-- The actual snackbar -->
<div id="snackbar">Stats have been swapped successfully!</div>

</cfoutput>
