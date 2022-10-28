<cfoutput>
<!DOCTYPE html>
<html>
<head>
<title>Deez nuts</title>
<style>
.testClass, td{
  border: 1px solid;
  color: black;
}
</style>
</head>

<cfif isDefined("form.deleteBtn")>
	<cfquery name="deletePlayerByID" datasource="roundleague">
			DELETE FROM Players
			WHERE playerID = #form.deletePlayerID#
	</cfquery>
	PlayerID: #form.deletePlayerID# was deleted.
</cfif>
<cfif isDefined("form.updateBtn")>
		<cfquery name="updatePlayerByID" datasource="roundleague">
			UPDATE players 
			SET firstname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.first#">
			WHERE playerID = #form.updatePlayerID#
	</cfquery>
	PlayerID: #form.updatePlayerID# was updated.
</cfif>
<cfif isDefined("form.ethnicity") and isDefined("form.gender")>
	#form.firstName#
	#form.lastName#<br>
	#form.email#<br>
	#form.phoneNumber#<br>
	#form.gender#<br>
	#form.ethnicity#<br>
	<cfquery name="insertPlayer" datasource="roundleague">
		INSERT INTO players (firstName, lastName, Email, Phone, registerDate, birthDate)
		VALUES
		(
			'#form.firstName#',
			'#form.lastName#',
			'#form.email#',
			'#form.phoneNumber#',
			'#form.registerDate#',
			'#form.birthDate#'
		)
	</cfquery> 
</cfif>



<cfquery name ="getRichardData" datasource = "roundleague">
SELECT firstName, lastName, Email, playerID
    FROM players
    ORDER BY playerid DESC
    LIMIT 1

</cfquery>

<body>




<form method="POST">

	<table class="testClass"> 
<tr>
	<th>playerID</th>
	<th>firstName</th>
	<th>lastName</th>
	<th>Email</th>
	<th>Update</th>
	<th>Delete</th>
</tr>
<cfloop query = "getRichardData">
	<tr>
	  <td>#getRichardData.playerID#</td>
		<td><input type="text" name="first" value="#getRichardData.firstName#"></td>
		<td>#getRichardData.lastName#</td>
		<td>#getRichardData.Email#</td>
		<td>
			<input type="submit" value="Update" name= "updateBtn" class="updateBtn" data-value="#getRichardData.playerID#">
		</td>
		<td>
			<input type="submit" value="Delete" name= "deleteBtn" class="deleteBtn" data-value="#getRichardData.playerID#">
		</td>
	</tr>
</cfloop>
</table><br>

	<label>First name:</label><br>
  <input type="text" name="firstName" value=""><br>
  <label>Last name:</label><br>
  <input type="text" name="lastName" value=""><br>
  <label>Email:</label><br>
  <input type="text" name="email" value="fakeemail@fakey.com"><br>
  <label>Register Date:</label><br>
  <input type="text" name="registerDate" value="1999-04-15"><br>
  <label>Birth Date:</label><br>
  <input type="text" name="birthDate" value="1999-04-15"><br>
  <label>Phone number:</label><br>
  <input type="text" name="phoneNumber" value="123-456-7890"><br><br>
  <label>Gender:</label><br>
  <input type="radio" name="gender" value="Male">
  <label for="male">Male</label><br>
  <input type="radio" name="gender" value="Female">
  <label for="female">Female</label><br>
  <input type="radio" name="gender" value="Other">
  <label for="other">Other</label><br><br>
  <label>Ethnicity:</label><br>
  <input type="checkbox" name="ethnicity" value="Caucasian">
  <label for="ethnicity"> Caucasian</label><br>
  <input type="checkbox" name="ethnicity" value="African-American">
  <label for="ethnicity"> African-American</label><br>
  <input type="checkbox" name="ethnicity" value="Asian">
  <label for="ethnicity"> Asian</label><br>
  <input type="checkbox" name="ethnicity" value="Hispanic">
  <label for="ethnicity"> Hispanic</label><br>

  <input type="hidden" value="" name="deletePlayerID" class="deletePlayerID">
  <input type="hidden" value="" name="updatePlayerID" class="updatePlayerID">
  <input type="submit" value="Submit"><br><br>

</form>

</body>
</html>
</cfoutput>

<cfinclude template="/footer.cfm">
<script src="../Jason/jason.js?v=1.2"></script>