<cfoutput>

<cfparam name="url.seasonID" default="0">
<cfparam name="url.playerID" default="">

SeasonID: #url.seasonID#

Player IDS: 
<cfloop list="#url.playerID#" item="i">
    #i#
</cfloop>

<cfloop list="#url.playerID#" item="i">
    <cfquery name="updateStats" datasource="roundleague" result="updateResult">
        UPDATE playerStats
        SET 
            Points = (SELECT CAST(AVG(POINTS) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            Rebounds = (SELECT CAST(AVG(Rebounds) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            Assists = (SELECT CAST(AVG(Assists) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            Steals = (SELECT CAST(AVG(Steals) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            Blocks = (SELECT CAST(AVG(Blocks) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            Turnovers = (SELECT CAST(AVG(Turnovers) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            FGM = (SELECT CAST(AVG(FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            FGA = (SELECT CAST(AVG(FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            3FGM = (SELECT CAST(AVG(3FGM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            3FGA = (SELECT CAST(AVG(3FGA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            FTM = (SELECT CAST(AVG(FTM) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            FTA = (SELECT CAST(AVG(FTA) AS DECIMAL(10,1)) FROM PlayerGameLog WHERE playerID = #i# AND SeasonID = #url.seasonID#),
            GamesPlayed = GamesPlayed - 1
        WHERE playerID = #i#
        AND SeasonID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.seasonID#">
        /* Add in necessary additional where clauses here */
    </cfquery>

</cfloop>

Players successfully updated. 
</cfoutput>