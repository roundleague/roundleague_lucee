<cfoutput>
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
<style>
.testClass, td, th{
  border: 1px solid;
  color:  black;
}
</style>
</head>

<cfif isDefined("form.ethnicity") and isDefined("form.gender")>
	#form.firstName#
	#form.lastName#
	#form.email# <br>
	#form.BirthDate#<br>
	#form.RegisterDate#<br>
	#form.phoneNumber#<br>
	#form.ethnicity#<br>
	#form.gender#<br>
	<cfquery name="insertPlayer" datasource="roundLeague">
		INSERT INTO players (firstName, lastName, Email, Phone, RegisterDate, BirthDate)
		VALUES
		(
			'#form.firstName#',
			'#form.lastName#',
			'#form.email#',
			'#form.phoneNumber#',
			'#form.RegisterDate#',
			'#form.BirthDate#'
		)
	</cfquery>
</cfif>


<cfquery name = "getTylerData" datasource = "roundLeague">
	SELECT firstName, lastName, POSITION
	FROM players
	WHERE playerID IN (1001, 1002, 1003)
</cfquery>

<body>



<table class="testClass">
	<tr>
		<th>firstName</th>
		<th>lastName</th>
		<th>position</th>
	</tr>
	<cfloop query = "getTylerData"> 
		<tr>
			<td>#getTylerData.firstName#</td>
			<td>#getTylerData.lastName#</td>
			<td>#getTylerData.position#</td>
		</tr>
	</cfloop>
</table>
<form method="POST">
	<label>First name:</label><br>
  <input type="text" name="firstName" value="John"><br>
  <label>Last name:</label><br>
  <input type="text" name="lastName" value="Doe"><br>
  <label>Email:</label><br>
  <input type="text" name="email" value="jonan@gmail.com"><br>
  <label>Register Date</label><br>
  <input type="text" name="RegisterDate" value="1999-04-15"><br>
  <label>Birth Date</label><br> 
  <input type="text" name="BirthDate" value="1999-04-15"><br>
  <label>Phone Number:</label><br> 
  <input type="text" name="phoneNumber" value="56397987134"><br><br>
  <p>Checkbox</p>
  <input type="checkbox" id="ethnicity" name="ethnicity" value="Asian">
  <label for"ethnicity"> Asian </label><br>
  <input type="checkbox" id="ethnicity" name="ethnicity" value="Hispanic">
  <label for"ethnicity"> Hispanic </label><br>
  <input type="checkbox" id="ethnicity" name = "ethnicity" value = "White">
  <label for "ethnicity"> White </label><br><br>
  <p>Radio</p>
  <input type="radio" id ="gender" name="gender" value = "Male"><br>
  <label for"gender"> Male </label><br>
  <input type="radio" id="gender" name="gender" value="Female"><br>
  <label for"gender"> Female</label><br><br>
  <input type="submit" value="Submit">
</form>
<!--- #getTylerData.firstName# #getTylerData.lastName# --->
</body>
</html>
</cfoutput>