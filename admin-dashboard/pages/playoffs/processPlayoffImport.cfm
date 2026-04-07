<cfoutput>
<cfparam name="form.importData" type="string" required="true">

<cfset importData = deserializeJSON(form.importData)>
<cfset brackets = importData.brackets>
<cfset seasonID = session.currentSeasonID>

<!--- Clear all existing playoff data for this season --->
<cfquery datasource="roundleague">
  DELETE FROM Playoffs_Schedule WHERE SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfquery datasource="roundleague">
  DELETE FROM Playoffs_Bracket WHERE SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset totalGames = 0>
<cfset bracketCount = 0>

<cfloop array="#brackets#" index="bracket">
  <cfset bracketCount++>
  <cfset games = bracket.games>

  <!--- Count unique teams for MaxTeamSize --->
  <cfset teamSet = {}>
  <cfloop array="#games#" index="g">
    <cfif isNumeric(g.homeTeamID) AND g.homeTeamID GT 0>
      <cfset teamSet[g.homeTeamID] = 1>
    </cfif>
    <cfif isNumeric(g.awayTeamID) AND g.awayTeamID GT 0>
      <cfset teamSet[g.awayTeamID] = 1>
    </cfif>
  </cfloop>
  <cfset maxTeamSize = structCount(teamSet)>
  <cfif maxTeamSize LT 2><cfset maxTeamSize = arrayLen(games)></cfif>

  <cfquery name="insertBracket" datasource="roundleague">
    INSERT INTO playoffs_bracket (Name, SeasonID, SortOrder, MaxTeamSize)
    VALUES (
      <cfqueryparam value="#bracket.name#" cfsqltype="cf_sql_varchar">,
      <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#bracketCount#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#maxTeamSize#" cfsqltype="cf_sql_integer">
    )
  </cfquery>

  <cfquery name="getNewBracketID" datasource="roundleague">
    SELECT @@IDENTITY AS newID
  </cfquery>
  <cfset bracketID = getNewBracketID.newID>

  <cfset gameID = 1>

  <cfloop array="#games#" index="g">
    <!--- homeTeamID --->
    <cfset homeTeamID = "">
    <cfif structKeyExists(g, "homeTeamID") AND isNumeric(g.homeTeamID) AND g.homeTeamID GT 0>
      <cfset homeTeamID = g.homeTeamID>
    </cfif>

    <!--- awayTeamID --->
    <cfset awayTeamID = "">
    <cfif structKeyExists(g, "awayTeamID") AND isNumeric(g.awayTeamID) AND g.awayTeamID GT 0>
      <cfset awayTeamID = g.awayTeamID>
    </cfif>

    <!--- homeSeed --->
    <cfset homeSeed = "">
    <cfif structKeyExists(g, "homeSeed") AND isNumeric(g.homeSeed)>
      <cfset homeSeed = g.homeSeed>
    </cfif>

    <!--- awaySeed --->
    <cfset awaySeed = "">
    <cfif structKeyExists(g, "awaySeed") AND isNumeric(g.awaySeed)>
      <cfset awaySeed = g.awaySeed>
    </cfif>

    <!--- date --->
    <cfset gameDate = "">
    <cfif structKeyExists(g, "date") AND len(trim(g.date))>
      <cfset gameDate = g.date>
    </cfif>

    <!--- startTime --->
    <cfset startTime = "">
    <cfif structKeyExists(g, "startTime") AND len(trim(g.startTime))>
      <cfset startTime = g.startTime>
    </cfif>

    <cfquery datasource="roundleague">
      INSERT INTO playoffs_schedule (
        playoffs_bracketID, seasonID, bracketGameID, bracketRoundID, week,
        homeSeed, awaySeed, homeTeamID, awayTeamID, date, startTime
      ) VALUES (
        <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#gameID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#g.bracketRoundID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#g.bracketRoundID#" cfsqltype="cf_sql_integer">,
        <cfif len(homeSeed)>
          <cfqueryparam value="#homeSeed#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(awaySeed)>
          <cfqueryparam value="#awaySeed#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(homeTeamID)>
          <cfqueryparam value="#homeTeamID#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(awayTeamID)>
          <cfqueryparam value="#awayTeamID#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(gameDate)>
          <cfqueryparam value="#gameDate#" cfsqltype="cf_sql_date">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(startTime)>
          <cfqueryparam value="#startTime#" cfsqltype="cf_sql_varchar">
        <cfelse>
          NULL
        </cfif>
      )
    </cfquery>

    <cfset gameID++>
    <cfset totalGames++>
  </cfloop>
</cfloop>

<cfset successMsg = "Successfully imported #totalGames# games across #bracketCount# bracket(s).">
</cfoutput>
