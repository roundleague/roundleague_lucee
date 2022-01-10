<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" rel="stylesheet">

<cfquery name="getPlayerStats" datasource="roundleague">
	SELECT firstName, lastName, points, rebounds, assists
	FROM playerstats ps
	JOIN players p ON p.playerID = ps.playerID
	WHERE seasonID = (SELECT seasonID From Seasons Where Status = 'Active')
	ORDER BY points desc
</cfquery>

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->
		<table id="example" class="display" style="width:100%">
		        <thead>
		            <tr>
		                <th>Name</th>
		                <th>Points</th>
		                <th>Rebounds</th>
		                <th>Assists</th>
		            </tr>
		        </thead>
		        <tbody>
		        	<cfloop query="getPlayerStats">
		        		<tr>
			        		<td data-label="Name">#getPlayerStats.firstName# #getPlayerStats.lastName#</td>
			        		<td data-label="Points">#getPlayerStats.Points#</td>
			        		<td data-label="Rebounds">#getPlayerStats.Rebounds#</td>
			        		<td data-label="Assists">#getPlayerStats.Assists#</td>
		        		</tr>
		        	</cfloop>
		        </tbody>
		</table>

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="/pages/Stats/seasonStats.js"></script>
