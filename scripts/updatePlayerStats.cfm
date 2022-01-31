<cfoutput>

<cfparam name="url.teamID" default="0">
<cfparam name="url.seasonID" default="0">

TeamID: #url.teamID#
SeasonID: #url.seasonID#

<cfquery name="getPlayerIDs" datasource="roundleague">
    SELECT playerID
    FROM roster
    WHERE TeamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.teamID#">
    AND seasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.seasonID#">
    AND PlayerID IN 
    (
    544,
    858,
    852,
    435,
    461,
    964
    )
</cfquery>

<cfloop list="#valueList(getPlayerIDs.playerID)#" item="i">
    <cfquery name="updateStats" datasource="roundleague" result="updateResult">
        UPDATE playerStats
        SET 
            Points = (SELECT CAST(AVG(POINTS) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            Rebounds = (SELECT CAST(AVG(Rebounds) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            Assists = (SELECT CAST(AVG(Assists) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            Steals = (SELECT CAST(AVG(Steals) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            Blocks = (SELECT CAST(AVG(Blocks) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            Turnovers = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            FGM = (SELECT CAST(AVG(FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            FGA = (SELECT CAST(AVG(FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            3FGM = (SELECT CAST(AVG(3FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            3FGA = (SELECT CAST(AVG(3FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            FTM = (SELECT CAST(AVG(FTM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            FTA = (SELECT CAST(AVG(FTA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #session.currentSeasonID#),
            GamesPlayed = GamesPlayed - 1
        WHERE playerID = #i#
        AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.currentSeasonID#">
        /* Add in necessary additional where clauses here */
    </cfquery>
</cfloop>
</cfoutput>