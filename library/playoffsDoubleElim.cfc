<!--- Playoffs Double-Elimination Component --->
<cfcomponent displayname="PlayoffsDoubleElim" hint="ColdFusion Component for the fixed 7-team, 12-game double-elimination bracket template">
	<cffunction name="getDoubleElim7Template"
		hint="Return the fixed 12-game, 7-team double-elimination bracket topology" returntype="array">
		<cfset var template = []>

		<cfset arrayAppend(template, {gameID=1,  winnerTo=5,  loserTo=4,  label=''})>
		<cfset arrayAppend(template, {gameID=2,  winnerTo=6,  loserTo=4,  label=''})>
		<cfset arrayAppend(template, {gameID=3,  winnerTo=6,  loserTo=7,  label=''})>
		<cfset arrayAppend(template, {gameID=4,  winnerTo=7,  loserTo=0,  label='ELIMINATION GAME'})>
		<cfset arrayAppend(template, {gameID=5,  winnerTo=9,  loserTo=8,  label=''})>
		<cfset arrayAppend(template, {gameID=6,  winnerTo=9,  loserTo=10, label=''})>
		<cfset arrayAppend(template, {gameID=7,  winnerTo=8,  loserTo=0,  label='ELIMINATION GAME'})>
		<cfset arrayAppend(template, {gameID=8,  winnerTo=10, loserTo=0,  label='ELIMINATION GAME'})>
		<cfset arrayAppend(template, {gameID=9,  winnerTo=12, loserTo=11, label='WINNERS BRACKET FINAL'})>
		<cfset arrayAppend(template, {gameID=10, winnerTo=11, loserTo=0,  label='ELIMINATION GAME'})>
		<cfset arrayAppend(template, {gameID=11, winnerTo=12, loserTo=0,  label='SEMIFINAL / ELIMINATION GAME'})>
		<cfset arrayAppend(template, {gameID=12, winnerTo=0,  loserTo=0,  label='CHAMPIONSHIP'})>

		<cfreturn template>
	</cffunction>
</cfcomponent>
