<cfoutput>
<cfset playerIDList = form.playerIDList>

<cfloop list="#playerIDList#" index="count" item="i">
	<cfif len(trim(form["photo_player_" & i])) NEQ 0>
		<!--- If a picture was uploaded for this player --->
	    <cffile 
		    action="upload" 
		    fileField="photo_player_#i#" 
		    destination="/assets/img/PlayerProfiles/#i#.jpg"
		    nameConflict="overwrite">
	</cfif>
</cfloop>

<!-- The actual snackbar -->
<div id="snackbar">Photos have been updated.</div>

</cfoutput>