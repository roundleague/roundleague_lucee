
<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->
<link href="../playoffs/playoffs.css" rel="stylesheet">

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <div class="playoffBracket">
		<h1>Playoffs Scheduler</h1>
		<main id="tournament">
		  <ul class="round round-1">
		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top winner">
				<input type="text" required class="form-control border-input" placeholder="Seed 1" name="seed_1">
		    </li>
		    <li class="game game-spacer"></li>
		    <li class="game game-bottom ">
				<input type="text" required class="form-control border-input" placeholder="Seed 8" name="seed_8">
		    </li>

		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top winner">
				<input type="text" required class="form-control border-input" placeholder="Seed 4" name="seed_4">
		    </li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom ">
				<input type="text" required class="form-control border-input" placeholder="Seed 5" name="seed_5">
		    </li>

		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top winner">
				<input type="text" required class="form-control border-input" placeholder="Seed 3" name="seed_3">
		    </li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom ">
				<input type="text" required class="form-control border-input" placeholder="Seed 6" name="seed_6">
		    </li>

		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top winner">
				<input type="text" required class="form-control border-input" placeholder="Seed 2" name="seed_2">
		    </li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom ">
				<input type="text" required class="form-control border-input" placeholder="Seed 7" name="seed_7">
		    </li>

		    <li class="spacer">&nbsp;</li>
		  </ul>
		  <ul class="round round-2">
		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top"></li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom "></li>

		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top"></li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom "></li>

		    <li class="spacer">&nbsp;</li>

		  </ul>
		  <ul class="round round-3">
		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top"></li>
		    <li class="game game-spacer">&nbsp;</li>
		    <li class="game game-bottom "></li>

		    <li class="spacer">&nbsp;</li>
		  </ul>
		  <ul class="round round-4">
		    <li class="spacer">&nbsp;</li>
		    
		    <li class="game game-top"></li>
		    
		    <li class="spacer">&nbsp;</li>
		  </ul>   
		</main>
      </div>

    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">
