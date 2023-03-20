<!--- Playoffs Component --->
<cfcomponent displayname="Playoffs" hint="ColdFusion Component for Playoffs">
  <cffunction name="getPlayoffTextByMaxBracketRoundID"
	hint="Print out the team's finished playoff spot based on Bracket Round ID" returntype="string">
	<cfargument name="maxBracketRoundID" default="" required="yes" type="numeric">
	<cfargument name="maxTeamSize" default="" required="yes" type="numeric">
		<cfoutput>
			<cfset playoffFinishedText = ''>
			<!--- This logic is subject to change based on playoff scheduling for future brackets --->
	        <cfif maxTeamSize EQ 32>
	          <!--- 32 Team Logic --->
	          <cfswitch expression="#maxBracketRoundID#">
	             <cfcase value="1">
	             	<cfset playoffFinishedText = 'Playoffs'>
	             </cfcase>
	             <cfcase value="2">
	             	<cfset playoffFinishedText = 'Sweet 16'>
	             </cfcase>
	             <cfcase value="3">
	             	<cfset playoffFinishedText = 'Elite 8'>
	             </cfcase>
	             <cfcase value="4">
	             	<cfset playoffFinishedText = 'Final 4'>
	             </cfcase>
	             <cfcase value="5">
	             	<cfset playoffFinishedText = 'Championship Game'>
	             </cfcase>
	          </cfswitch>
	        <cfelseif maxTeamSize EQ 8>
	          <!--- 8 Team Logic --->
	          <cfswitch expression="#maxBracketRoundID#">
	             <cfcase value="1">
	             	<cfset playoffFinishedText = 'Playoffs'>
	             </cfcase>
	             <cfcase value="2">
	             	<cfset playoffFinishedText = 'Final 4'>
	             </cfcase>
	             <cfcase value="3">
	             	<cfset playoffFinishedText = 'Championship Game'>
	             </cfcase>
	          </cfswitch>
	        <cfelseif maxTeamSize EQ 4>
	          <!--- 4 Team Logic --->
	          <cfswitch expression="#maxBracketRoundID#">
	             <cfcase value="1">
	             	<cfset playoffFinishedText = 'Playoffs'>
	             </cfcase>
	             <cfcase value="2">
	             	<cfset playoffFinishedText = 'Championship Game'>
	             </cfcase>
	          </cfswitch>
	        </cfif>
			<cfreturn playoffFinishedText>
		</cfoutput>
 </cffunction>
</cfcomponent>