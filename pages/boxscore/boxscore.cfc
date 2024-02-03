<!--- boxscore.cfc --->
<cfcomponent>

    <cffunction name="generatePlayerStatsPrompt" returntype="string">
        <cfargument name="player" type="query" required="true">
        <cfargument name="teamID" type="number" required="true">

        <cfquery name="teamName" datasource="roundleague">
	        SELECT teamName
	        FROM teams
	        WHERE teamID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#teamID#">
    	</cfquery>

        <cfset var prompt = "">
        
        <!-- Player information -->
        <cfset prompt &= "#player.firstName# #player.lastName# for #teamName# stats ">

        <!-- Field goals -->
        <cfif player.FGM GT 0>
            <cfset prompt &= "#player.FGM# field goals made on #player.FGA# attempts, ">
        </cfif>

        <!-- Three-pointers -->
        <cfif player.3FGM GT 0>
            <cfset prompt &= "#player.3FGM# three-pointers made on #player.3FGA# attempts, ">
        </cfif>

        <!-- Free throws -->
        <cfif player.FTM GT 0>
            <cfset prompt &= "#player.FTM# free throws made on #player.FTA# attempts, ">
        </cfif>

        <!-- Rebounds -->
        <cfif player.Rebounds GT 0>
            <cfset prompt &= "#player.Rebounds# rebounds, ">
        </cfif>

        <!-- Assists -->
        <cfif player.Assists GT 0>
            <cfset prompt &= "#player.Assists# assists, ">
        </cfif>

        <!-- Steals -->
        <cfif player.Steals GT 0>
            <cfset prompt &= "#player.Steals# steals, ">
        </cfif>

        <!-- Blocks -->
        <cfif player.Blocks GT 0>
            <cfset prompt &= "#player.Blocks# blocks, ">
        </cfif>

        <!-- Turnovers -->
        <cfif player.Turnovers GT 0>
            <cfset prompt &= "#player.Turnovers# turnovers, ">
        </cfif>

        <!-- Fouls -->
        <cfif val(player.Fouls) GT 0>
            <cfset prompt &= "#player.Fouls# fouls, ">
        </cfif>

        <!-- Points -->
        <cfif player.Points GT 0>
            <cfset prompt &= "scoring #player.Points# points.">
        </cfif>

        <cfreturn prompt>
    </cffunction>

	<cffunction name="generateTeamStatsPrompt" returntype="string">
		<cfargument name="teamName" type="string" required="true">
	    <cfargument name="teamStats" type="struct" required="true">

	    <cfset var prompt = "">
	    <cfset prompt &= "Total stats for team #teamName#, ">

	    <!-- Field goals -->
	    <cfif teamStats.TotalFGM GT 0>
	        <cfset prompt &= "#teamStats.TotalFGM# field goals made on #teamStats.TotalFGA# attempts, ">
	    </cfif>

	    <!-- Three-pointers -->
	    <cfif teamStats.Total3FGM GT 0>
	        <cfset prompt &= "#teamStats.Total3FGM# three-pointers made on #teamStats.Total3FGA# attempts, ">
	    </cfif>

	    <!-- Free throws -->
	    <cfif teamStats.TotalFTM GT 0>
	        <cfset prompt &= "#teamStats.TotalFTM# free throws made on #teamStats.TotalFTA# attempts, ">
	    </cfif>

	    <!-- Rebounds -->
	    <cfif teamStats.TotalREB GT 0>
	        <cfset prompt &= "#teamStats.TotalREB# rebounds, ">
	    </cfif>

	    <!-- Assists -->
	    <cfif teamStats.TotalAST GT 0>
	        <cfset prompt &= "#teamStats.TotalAST# assists, ">
	    </cfif>

	    <!-- Steals -->
	    <cfif teamStats.TotalSTL GT 0>
	        <cfset prompt &= "#teamStats.TotalSTL# steals, ">
	    </cfif>

	    <!-- Blocks -->
	    <cfif teamStats.TotalBLK GT 0>
	        <cfset prompt &= "#teamStats.TotalBLK# blocks, ">
	    </cfif>

	    <!-- Turnovers -->
	    <cfif teamStats.TotalTO GT 0>
	        <cfset prompt &= "#teamStats.TotalTO# turnovers, ">
	    </cfif>

	    <!-- Fouls -->
	    <cfif teamStats.TotalFLS GT 0>
	        <cfset prompt &= "#teamStats.TotalFLS# fouls, ">
	    </cfif>

	    <!-- Points -->
	    <cfif teamStats.TotalPTS GT 0>
	        <cfset prompt &= "scoring #teamStats.TotalPTS# points.">
	    </cfif>

	    <cfreturn prompt>
	</cffunction>


</cfcomponent>
