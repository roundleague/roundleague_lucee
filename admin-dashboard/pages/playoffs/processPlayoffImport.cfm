<cfoutput>
<cfparam name="form.importData" type="string" required="true">

<cfset importData = deserializeJSON(form.importData)>
<cfset seasonID = session.currentSeasonID>
<cfset games = importData.games>

<cfif NOT arrayLen(games)>
  <cfthrow message="No games to import.">
</cfif>

<!--- Resolve the bracket: reuse an existing one, or create a new manual/no-auto-advance bracket --->
<cfif isNull(importData.bracketID) OR NOT len(importData.bracketID)>
  <cfset teamSet = {}>
  <cfloop array="#games#" index="g">
    <cfif isNumeric(g.homeTeamID) AND g.homeTeamID GT 0><cfset teamSet[g.homeTeamID] = 1></cfif>
    <cfif isNumeric(g.awayTeamID) AND g.awayTeamID GT 0><cfset teamSet[g.awayTeamID] = 1></cfif>
  </cfloop>
  <cfset maxTeamSize = structCount(teamSet)>
  <cfif maxTeamSize LT 2><cfset maxTeamSize = arrayLen(games)></cfif>

  <cfquery name="getNextSortOrder" datasource="roundleague">
    SELECT COALESCE(MAX(SortOrder), 0) + 1 AS nextSort
    FROM playoffs_bracket
    WHERE SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfquery name="insertBracket" datasource="roundleague">
    INSERT INTO playoffs_bracket (Name, SeasonID, SortOrder, MaxTeamSize, AutoAdvance)
    VALUES (
      <cfqueryparam value="#importData.bracketName#" cfsqltype="cf_sql_varchar">,
      <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#getNextSortOrder.nextSort#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#maxTeamSize#" cfsqltype="cf_sql_integer">,
      0
    )
  </cfquery>

  <cfquery name="getNewBracketID" datasource="roundleague">
    SELECT @@IDENTITY AS newID
  </cfquery>
  <cfset bracketID = getNewBracketID.newID>
<cfelse>
  <cfset bracketID = importData.bracketID>

  <!--- Confirm the bracket belongs to this season before writing to it --->
  <cfquery name="verifyBracket" datasource="roundleague">
    SELECT Playoffs_bracketID, MaxTeamSize
    FROM playoffs_bracket
    WHERE Playoffs_bracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
    AND SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfif verifyBracket.recordCount EQ 0>
    <cfthrow message="Selected bracket does not belong to the current season.">
  </cfif>
</cfif>

<!--- Distinct rounds present in this upload --->
<cfset roundSet = {}>
<cfloop array="#games#" index="g">
  <cfset roundSet[g.bracketRoundID] = 1>
</cfloop>
<cfset roundList = structKeyList(roundSet)>

<!--- Safety check: block the import if any game in these rounds already has a recorded score --->
<cfloop list="#roundList#" index="roundID">
  <cfquery name="checkScored" datasource="roundleague">
    SELECT COUNT(*) AS scoredCount
    FROM playoffs_schedule
    WHERE Playoffs_BracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
    AND BracketRoundID = <cfqueryparam value="#roundID#" cfsqltype="cf_sql_integer">
    AND (HomeScore IS NOT NULL OR AwayScore IS NOT NULL)
  </cfquery>
  <cfif checkScored.scoredCount GT 0>
    <cfthrow message="Round #roundID# already has #checkScored.scoredCount# game(s) with a recorded score — it can't be re-imported automatically. Pick a different round number, or fix this round's games directly.">
  </cfif>
</cfloop>

<!--- Safe to replace just these rounds for this bracket --->
<cfloop list="#roundList#" index="roundID">
  <cfquery datasource="roundleague">
    DELETE FROM playoffs_schedule
    WHERE Playoffs_BracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
    AND SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
    AND BracketRoundID = <cfqueryparam value="#roundID#" cfsqltype="cf_sql_integer">
  </cfquery>
</cfloop>

<cfquery name="getMaxGameID" datasource="roundleague">
  SELECT COALESCE(MAX(BracketGameID), 0) AS maxGameID
  FROM playoffs_schedule
  WHERE Playoffs_BracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset nextGameID = getMaxGameID.maxGameID + 1>

<cfset totalGames = 0>
<cfset roundTeamSet = {}>

<cfloop array="#games#" index="g">
  <cfset homeTeamID = "">
  <cfif structKeyExists(g, "homeTeamID") AND isNumeric(g.homeTeamID) AND g.homeTeamID GT 0>
    <cfset homeTeamID = g.homeTeamID>
    <cfset roundTeamSet[homeTeamID] = 1>
  </cfif>

  <cfset awayTeamID = "">
  <cfif structKeyExists(g, "awayTeamID") AND isNumeric(g.awayTeamID) AND g.awayTeamID GT 0>
    <cfset awayTeamID = g.awayTeamID>
    <cfset roundTeamSet[awayTeamID] = 1>
  </cfif>

  <cfset homeSeed = "">
  <cfif structKeyExists(g, "homeSeed") AND isNumeric(g.homeSeed)>
    <cfset homeSeed = g.homeSeed>
  </cfif>

  <cfset awaySeed = "">
  <cfif structKeyExists(g, "awaySeed") AND isNumeric(g.awaySeed)>
    <cfset awaySeed = g.awaySeed>
  </cfif>

  <cfset gameDate = "">
  <cfif structKeyExists(g, "date") AND len(trim(g.date))>
    <cfset gameDate = g.date>
  </cfif>

  <cfset startTime = "">
  <cfif structKeyExists(g, "startTime") AND len(trim(g.startTime))>
    <cfset startTime = g.startTime>
  </cfif>

  <cfquery datasource="roundleague">
    INSERT INTO playoffs_schedule (
      Playoffs_BracketID, SeasonID, BracketGameID, BracketRoundID, Week,
      HomeSeed, AwaySeed, HomeTeamID, AwayTeamID, Date, StartTime
    ) VALUES (
      <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#nextGameID#" cfsqltype="cf_sql_integer">,
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

  <cfset nextGameID++>
  <cfset totalGames++>
</cfloop>

<!--- Keep MaxTeamSize current as new rounds introduce teams --->
<cfquery name="getCurrentMaxTeamSize" datasource="roundleague">
  SELECT MaxTeamSize FROM playoffs_bracket
  WHERE Playoffs_bracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset newMaxTeamSize = max(val(getCurrentMaxTeamSize.MaxTeamSize), structCount(roundTeamSet))>
<cfif newMaxTeamSize NEQ val(getCurrentMaxTeamSize.MaxTeamSize)>
  <cfquery datasource="roundleague">
    UPDATE playoffs_bracket
    SET MaxTeamSize = <cfqueryparam value="#newMaxTeamSize#" cfsqltype="cf_sql_integer">
    WHERE Playoffs_bracketID = <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">
  </cfquery>
</cfif>

<cfset successMsg = "Successfully imported #totalGames# game(s) into round(s) #roundList#.">
</cfoutput>
