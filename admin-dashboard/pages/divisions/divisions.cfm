<cfinclude template="/admin-dashboard/admin_header.cfm">

<!--- Page Specific CSS/JS Here --->

<cfoutput>
<!-- End Navbar -->
<div class="content">
  <div class="row">
    <div class="col-md-12">
      <h3 class="description">Divisions</h3>
      <!--- Content goes here --->
      <div class="container">
        <div class="button-container">
            <button onclick="createNewTeam()">Create New Team</button>
            <button onclick="createNewDivision()">Create New Division</button>
        </div>
        <div class="teams-container">
            <div id="teams-no-divisions">
                <h3>Teams with no divisions</h3>
                <ul id="teams-list">
                    <li>Team 1</li>
                    <li>Team 2</li>
                    <li>Team 3</li>
                </ul>
            </div>
            <div id="adds-to-here">
                <h3>Adds to here</h3>
                <!-- Dynamic content can be added here -->
            </div>
            <div id="sticky">
                <h3>Sticky</h3>
                <!-- Sticky content can be added here -->
            </div>
        </div>
        <div class="divisions-container">
            <div id="north" class="highlight-on-hover">
                <h3>North</h3>
                <!-- North content -->
            </div>
            <div id="south" class="highlight-on-hover">
                <h3>South</h3>
                <!-- South content -->
            </div>
            <div id="east" class="highlight-on-hover">
                <h3>East</h3>
                <!-- East content -->
            </div>
        </div>
      </div>
    </div>
  </div>
</div>
</cfoutput>

<script>
    function createNewTeam() {
        const teamList = document.getElementById('teams-list');
        const newTeam = document.createElement('li');
        newTeam.textContent = 'New Team';
        teamList.appendChild(newTeam);
    }

    function createNewDivision() {
        const newDivision = document.createElement('div');
        newDivision.textContent = 'New Division';
        newDivision.style.border = '1px solid #000';
        newDivision.style.padding = '20px';
        newDivision.style.width = '30%';
        newDivision.style.textAlign = 'center';
        document.querySelector('.divisions-container').appendChild(newDivision);
    }

    document.querySelectorAll('.highlight-on-hover').forEach(element => {
        element.addEventListener('dragover', event => {
            event.preventDefault();
            element.classList.add('highlight');
        });

        element.addEventListener('dragleave', () => {
            element.classList.remove('highlight');
        });

        element.addEventListener('drop', () => {
            element.classList.remove('highlight');
        });
    });
</script>

<style>
    .container {
        margin: 20px;
    }
    .button-container {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
    }
    .button-container button {
        padding: 10px;
        font-size: 16px;
    }
    .teams-container {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
    }
    .teams-container div {
        border: 1px solid #000;
        padding: 10px;
        width: 30%;
    }
    .divisions-container {
        display: flex;
        justify-content: space-between;
    }
    .divisions-container div {
        border: 1px solid #000;
        padding: 20px;
        width: 30%;
        text-align: center;
    }
    .highlight {
        background-color: yellow;
    }
</style>

<cfinclude template="/admin-dashboard/admin_footer.cfm">