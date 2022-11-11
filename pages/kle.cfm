
<cfoutput>

<cfif !findNoCase("127.0.0.1", CGI.HTTP_HOST)>
	<cfdump var="Access Denied." /><cfabort />
</cfif>

<!DOCTYPE html>
<html>
<head>
<title>KEVIN'S SUGONMA</title>
</head>

<cfif isDefined("form.firstName")>
	#form.firstName#
	#form.lastName#
	#form.email#
	#form.Phone#
	<cfquery name="InsetPlayer" datasource="roundleague">
		INSERT INTO players (firstName, lastName, Email, Phone, RegisterDate, BirthDate)
VALUES
(
	#form.firstName#
	#form.lastName#
	#form.email#
	#form.Phone#
	'2022-02-16',
	'1991-03-30'
)			
</cfquery>
</cfif>

<cfquery name="getTrippData" datasource="roundleague">
SELECT firstName, lastName, POSITION
FROM players
WHERE playerID IN (1001, 1002, 1003)

</cfquery>

<body>
<style>
.testClass,td{
  border: 1px solid;
  color: hotpink;
}
</style>

<h2>This is a Heading</h2>
<p>This is a paragraph.</p>

<table class="testClass"> 

<tr>
	<th>firstName</th>
	<th>lastName</th>
	<th>POSITION</th>
</tr>
	<cfloop query="getTrippData">
	<tr>
		<td>#getTrippData.firstName#</td>
		<td>#getTrippData.lastName#</td>
		<td>#getTrippData.position#</td>
	</tr>
	</cfloop>

</table>
<form method="POST">
  <label for="fname">First name:</label><br>
  <input type="text" name="firstName" value="Deez"><br><br>
  <label for="lname">Last name:</label><br>
  <input type="text" name="lastName" value="Nutz"><br><br>
  <label for="fname">Phone Number:</label><br>
  <input type="text" name="Phone Number" value="(123) 456 7890"><br><br>
  <label for="fname">Email:</label><br>
  <input type="text" name="Email" value="deeznuts@gmail.com"><br>
  <br><br>
  
 

<p>Choose your Gender:</p> 

  <input type="radio" id="html" name="Gender" value="Male">
  <label for="html">Male</label><br>
  <input type="radio" id="css" name="Gender" value="Female">
  <label for="css">Female</label><br>
  <input type="radio" id="javascript" name="Gender" value="Non-Binary">
  <label for="javascript">Non-Binary</label>

 <br> <br><input type="submit" value="Submit">
</form>

</body>
</html>
</cfoutput>