<cfoutput>
<cfparam name="form.bracketName" type="string" required="true">
<cfparam name="form.numTeams" type="numeric" required="true">
<cfparam name="session.currentSeasonID" type="numeric" required="true">

<cfset bracketName = form.bracketName>
<cfset numTeams = form.numTeams>
<cfset seasonID = session.currentSeasonID>

<!--- Insert into playoffs_bracket table --->
<cfquery name="insertIntoPlayoffsBracket" datasource="roundleague">
    INSERT INTO playoffs_bracket (Name, SeasonID, SortOrder, MaxTeamSize)
    VALUES (
        <cfqueryparam value="#bracketName#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
        NULL, 
        <cfqueryparam value="#numTeams#" cfsqltype="cf_sql_integer">
    )
</cfquery>

<!--- Get the ID of the newly inserted playoff bracket --->
<cfquery name="getNewPlayoffBracketID" datasource="roundleague">
    SELECT @@IDENTITY AS newPlayoffBracketID
</cfquery>

<cfset bracketID = getNewPlayoffBracketID.newPlayoffBracketID>

<!--- Utility function to calculate log base 2 --->
<cfscript>
  function log2(x) {
    return log(x) / log(2);
  }
</cfscript>

<cfset gameID = 1>
<cfset roundID = 1>

<!--- Calculate the number of rounds --->
<cfset numRounds = ceiling(log2(numTeams))>

<!--- Generate initial round matchups --->
<cfset initialMatchups = arrayNew(1)>
<cfset i = 1>
<cfloop from="1" to="#numTeams#" index="i" step="2">
  <cfset arrayAppend(initialMatchups, {homeSeed=i, awaySeed=i+1})>
</cfloop>

<!--- Insert initial round matchups --->
<cfloop array="#initialMatchups#" index="matchup">
  <cfquery datasource="roundleague">
    INSERT INTO playoffs_schedule (playoffs_bracketID, seasonID, bracketGameID, bracketRoundID, homeSeed, awaySeed)
    VALUES (
        <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#gameID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#roundID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#matchup.homeSeed#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#matchup.awaySeed#" cfsqltype="cf_sql_integer">
    )
  </cfquery>
  <cfset gameID++>
</cfloop>

<!--- Generate subsequent rounds --->
<cfloop from="2" to="#numRounds#" index="roundID">
  <cfset numGames = numTeams / (2^(roundID - 1))>
  <cfloop from="1" to="#numGames#" index="i">
    <cfquery datasource="roundleague">
      INSERT INTO playoffs_schedule (playoffs_bracketID, seasonID, bracketGameID, bracketRoundID, homeSeed, awaySeed)
      VALUES (
          <cfqueryparam value="#bracketID#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#seasonID#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#gameID#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#roundID#" cfsqltype="cf_sql_integer">,
          NULL,
          NULL
      )
    </cfquery>
    <cfset gameID++>
  </cfloop>
</cfloop>

<!-- The actual snackbar -->
<div id="snackbar">Playoff Bracket "#bracketName#" with #numTeams# teams has been created.</div>

</cfoutput>
