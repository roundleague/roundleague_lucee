<cfoutput>
<cfparam name="form.importData" type="string" required="true">

<cfset importData = deserializeJSON(form.importData)>
<cfset brackets = importData.brackets>
<cfset seasonID = session.currentSeasonID>

<!--- Only replace the bracket(s) actually present in this submission — importing
      one flyer at a time must not wipe out brackets already imported/played.
      Preserve each existing bracket's SortOrder so re-importing a fix doesn't
      reshuffle the dropdown; new bracket names get the next available slot. --->
<cfset bracketSortOrders = {}>
<cfquery name="getMaxSortOrder" datasource="roundleague">
  SELECT MAX(SortOrder) AS maxSort FROM playoffs_bracket
  WHERE SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset nextSortOrder = isNumeric(getMaxSortOrder.maxSort) ? getMaxSortOrder.maxSort : 0>

<cfloop array="#brackets#" index="bracket">
  <cfquery name="findExistingBracket" datasource="roundleague">
    SELECT Playoffs_BracketID, SortOrder FROM playoffs_bracket
    WHERE SeasonID = <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">
    AND Name = <cfqueryparam value="#bracket.name#" cfsqltype="cf_sql_varchar">
  </cfquery>
  <cfif findExistingBracket.recordCount>
    <cfset bracketSortOrders[bracket.name] = findExistingBracket.SortOrder>
    <cfquery datasource="roundleague">
      DELETE FROM Playoffs_Schedule WHERE Playoffs_BracketID = <cfqueryparam value="#findExistingBracket.Playoffs_BracketID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfquery datasource="roundleague">
      DELETE FROM Playoffs_Bracket WHERE Playoffs_BracketID = <cfqueryparam value="#findExistingBracket.Playoffs_BracketID#" cfsqltype="cf_sql_integer">
    </cfquery>
  <cfelse>
    <cfset nextSortOrder++>
    <cfset bracketSortOrders[bracket.name] = nextSortOrder>
  </cfif>
</cfloop>

<cfset totalGames = 0>
<cfset bracketCount = 0>

<cfloop array="#brackets#" index="bracket">
  <cfset bracketCount++>
  <cfset games = bracket.games>

  <!--- Format: default 'single' for payload back-compat --->
  <cfset bracketFormat = 'single'>
  <cfif structKeyExists(bracket, "format") AND len(trim(bracket.format))>
    <cfset bracketFormat = bracket.format>
  </cfif>

  <cfif bracketFormat EQ 'double_elim_7'>
    <!--- Server-side backstop behind the client-side 12-game check --->
    <cfif arrayLen(games) NEQ 12>
      <cfthrow message="Double-Elim (7-Team) bracket '#bracket.name#' must have exactly 12 games, got #arrayLen(games)#.">
    </cfif>
    <cfset maxTeamSize = 7>
    <cfset doubleElimObj = createObject("component", "library.playoffsDoubleElim")>
    <cfset doubleElimTemplate = doubleElimObj.getDoubleElim7Template()>

    <!--- One-off, bracket-specific override for the current season's "Premiere Tier 1"
          bracket only (requested by Rich). Swaps the losers-bracket routing so that:
            G4 = Loser(G3) vs Loser(G2)   (default template: Loser(G1) vs Loser(G2))
            G7 = Winner(G4) vs Loser(G1)  (default template: Winner(G4) vs Loser(G3))
          Expressed as a minimal 2-value swap of LoserAdvancesTo for G1 and G3 only.
          getDoubleElim7Template() itself is untouched, so every other double_elim_7
          bracket (Open Tier 1, Open Tier 2, Premiere Tier 2, future brackets) keeps
          the default wiring. Keyed by bracket Name only, since playoffs_bracket has
          no separate tier/type column — delete this block once no longer needed. --->
    <cfset loserAdvanceOverrides = {}>
    <cfif trim(bracket.name) EQ "Premiere Tier 1">
      <cfset loserAdvanceOverrides = { "1": 7, "3": 4 }>
    </cfif>
  <cfelse>
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
  </cfif>

  <cfquery name="insertBracket" datasource="roundleague">
    INSERT INTO playoffs_bracket (Name, SeasonID, SortOrder, MaxTeamSize, BracketFormat)
    VALUES (
      <cfqueryparam value="#bracket.name#" cfsqltype="cf_sql_varchar">,
      <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#bracketSortOrders[bracket.name]#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#maxTeamSize#" cfsqltype="cf_sql_integer">,
      <cfqueryparam value="#bracketFormat#" cfsqltype="cf_sql_varchar">
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

    <!--- Double-elim advancement columns: from the fixed template, keyed by ordinal position (= gameID) --->
    <cfset winnerAdvancesTo = "">
    <cfset loserAdvancesTo = "">
    <cfset gameLabel = "">
    <cfif bracketFormat EQ 'double_elim_7'>
      <cfset templateRow = doubleElimTemplate[gameID]>
      <cfset effectiveLoserTo = templateRow.loserTo>
      <cfif structKeyExists(loserAdvanceOverrides, gameID)>
        <cfset effectiveLoserTo = loserAdvanceOverrides[gameID]>
      </cfif>
      <cfif templateRow.winnerTo GT 0><cfset winnerAdvancesTo = templateRow.winnerTo></cfif>
      <cfif effectiveLoserTo GT 0><cfset loserAdvancesTo = effectiveLoserTo></cfif>
      <cfif len(trim(templateRow.label))><cfset gameLabel = templateRow.label></cfif>
    </cfif>

    <cfquery datasource="roundleague">
      INSERT INTO playoffs_schedule (
        playoffs_bracketID, seasonID, bracketGameID, bracketRoundID, week,
        homeSeed, awaySeed, homeTeamID, awayTeamID, date, startTime,
        WinnerAdvancesTo, LoserAdvancesTo, GameLabel
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
          <cfqueryparam value="#startTime#" cfsqltype="cf_sql_varchar">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(winnerAdvancesTo)>
          <cfqueryparam value="#winnerAdvancesTo#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(loserAdvancesTo)>
          <cfqueryparam value="#loserAdvancesTo#" cfsqltype="cf_sql_integer">,
        <cfelse>
          NULL,
        </cfif>
        <cfif len(gameLabel)>
          <cfqueryparam value="#gameLabel#" cfsqltype="cf_sql_varchar">
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
