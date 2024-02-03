<link href="../boxscore/recap.css?v=1.0" rel="stylesheet">

<cfquery name="getExistingRecap" datasource="roundleague">
	SELECT recapText
	FROM recaps
	WHERE scheduleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.scheduleID#">
</cfquery>

<cfset recapMessageText = ''>

<cfparam name="firstTeamTotals" default="">
<cfparam name="secondTeamTotals" default="">
<cfparam name="teamScores" default="">
<cfparam name="playerListPrompts" default="">

<cfif getExistingRecap.recordCount>
	<cfset recapMessageText = getExistingRecap.recapText>
<cfelse>
	<cfset apiKey = "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">
	<cfset openaiApiUrl = "https://api.openai.com/v1/chat/completions">

	<cfset totalMessage = firstTeamTotals & secondTeamTotals & teamScores & playerListPrompts>

	<cfhttp url="#openaiApiUrl#" method="POST">
	    <cfhttpparam type="header" name="Content-Type" value="application/json">
	    <cfhttpparam type="header" name="Authorization" value="Bearer #apiKey#">
	    
	    <!--- Your API request payload goes here, for example: --->
	    <cfhttpparam type="body" value='{
	  "model": "gpt-3.5-turbo",
	  "messages": [
	    {
	      "role": "system",
	      "content": "Recap this basketball game like ESPN would based on the following stats in less than 1000 characters. Majority sentences should highlight individual performances but make sure one sentence compares team totals."
	    },
	    {
	      "role": "user",
	      "content": "#totalMessage#"
	    }
	  ],
	  "temperature": 1.0,
	  "top_p": 1
	}'>
	</cfhttp>

	<cfset response = DeserializeJSON(cfhttp.fileContent)>

	<!--- One time insert into database to prevent future calls for this scheduleID --->
	<!--- We should check response before inserting --->
	<cfquery name="insertGameRecap" datasource="roundleague">
		INSERT INTO recaps (scheduleID, recapText)
		VALUES
			(
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getTeamsPlaying.scheduleID#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#response.choices[1].message.content#">
			)
	</cfquery>

	<cfoutput>
	    <!-- Print the content -->
	    <cfset recapMessageText = response.choices[1].message.content>
	</cfoutput>
</cfif>

<!--- Modal Section --->
<div class="modal fade" id="recapModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">x</span>
                    </button>
                    <h5 class="modal-title text-center" id="exampleModalLabel">Recap</h5>
                  </div>
                  <div class="modal-body"> 
                  	<cfoutput><p id="recapText">#recapMessageText#</p></cfoutput>
                  </div>
                  <div class="modal-footer">
                    <div class="left-side">
                      <button type="button" class="btn btn-default btn-link" data-dismiss="modal">Done</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
<!--- End Modal Section --->

<button type="button" class="btn btn-outline-danger btn-round modalBtn" data-toggle="modal" data-target="#recapModal">
  Show Recap
</button>