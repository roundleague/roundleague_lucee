<cfinclude template="/header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<div class="main" style="background-color: white; margin-top: 50px">
    <div class="section text-center">
      <div class="container">

        <!--- Content Here --->

		<!--- <button type="button" class="btn btn-outline-success btn-round helloWorldBtn_BE">Click Here to Render "Hello World" using Back End</button> --->

		<div class="textBox_FE" style="margin-top: 25px; font-weight: bold;">
        	<span class="textRender_FE"></span>
		</div>

    <input type="number" class="form-control border-input jokeNumber" name="jokeNumber" style="width: 100px;">

    <button type="button" class="btn btn-outline-success btn-round getJokeNumber">Click to get joke based on ID</button>

		<!--- <div class="textBox_BE" style="margin-top: 25px; font-weight: bold;">
        	Back End: <span class="textRender_BE"></span>
		</div> --->

      </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
<script src="../HelloWorld/helloWorld.js"></script>

