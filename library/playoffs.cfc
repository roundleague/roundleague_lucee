<!--- Playoffs Component --->
<cfcomponent displayname="Playoffs" hint="ColdFusion Component for Playoffs">
	<cffunction name="getPlayoffTextByMaxBracketRoundID"
	    hint="Print out the team's finished playoff spot based on Bracket Round ID" returntype="string">
	    <cfargument name="maxBracketRoundID" default="" required="yes" type="numeric">
	    <cfargument name="MaxTeamSize" default="" required="yes" type="numeric">
		    <cfoutput>
		    	<cfset playoffsFinishText = ''>
		    	<!--- 32 & 22 Team Logic --->
		    	<cfif MaxTeamSize EQ 32 OR MaxTeamSize EQ 22>
			    	<cfswitch expression="#maxBracketRoundID#">
	                <cfcase value="1">
	                    <cfset playoffsFinishText = 'Playoffs'>
	                </cfcase>
	                <cfcase value="2">
	                    <cfset playoffsFinishText = 'Sweet 16'>
	                </cfcase>
	                <cfcase value="3">
	                    <cfset playoffsFinishText = 'Elite 8'>
	                </cfcase>
	                <cfcase value="4">
	                    <cfset playoffsFinishText = 'Final 4'>
	                </cfcase>
	                <cfcase value="5">
	                    <cfset playoffsFinishText = 'Championship Game'>
	                </cfcase>
	              	</cfswitch>
              <!--- 8 Team Logic --->
              	<cfelseif MaxTeamSize EQ 8>
	      			<cfswitch expression="#maxBracketRoundID#">
	                <cfcase value="1">
	                    <cfset playoffsFinishText = 'Playoffs'>
	                </cfcase>
	                <cfcase value="2">
	                    <cfset playoffsFinishText = 'Final 4'>
	                </cfcase>
	                <cfcase value="3">
	                    <cfset playoffsFinishText = 'Championship'>
			    	</cfcase>
			    	</cfswitch>
		    	<!--- 4 Team Logic --->
              	<cfelseif MaxTeamSize EQ 4>
	      			<cfswitch expression="#maxBracketRoundID#">
	                <cfcase value="1">
	                    <cfset playoffsFinishText = 'Playoffs'>
	                </cfcase>
	                <cfcase value="2">
	                    <cfset playoffsFinishText = 'Championship'>
			    	</cfcase>
			    	</cfswitch>
		    	</cfif>
		    	<cfreturn "#playoffsFinishText#">
		    </cfoutput>

	</cffunction>
</cfcomponent>
