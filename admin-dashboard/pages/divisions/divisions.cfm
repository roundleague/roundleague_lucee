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
				    <li draggable="true" id="team1" ondragstart="drag(event)">Team 1</li>
				    <li draggable="true" id="team2" ondragstart="drag(event)">Team 2</li>
				    <li draggable="true" id="team3" ondragstart="drag(event)">Team 3</li>
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
            <div id="north" class="highlight-on-hover" ondrop="drop(event)" ondragover="allowDrop(event)">
                <h3>North</h3>
                <!-- North content -->
            </div>
            <div id="south" class="highlight-on-hover" ondrop="drop(event)" ondragover="allowDrop(event)">
                <h3>South</h3>
                <!-- South content -->
            </div>
            <div id="east" class="highlight-on-hover" ondrop="drop(event)" ondragover="allowDrop(event)">
                <h3>East</h3>
                <!-- East content -->
            </div>
        </div>
      </div>
    </div>
  </div>
</div>
</cfoutput>

<cfinclude template="/admin-dashboard/admin_footer.cfm">

<script>
    function createNewTeam() {
        const teamList = document.getElementById('teams-list');
        const newTeam = document.createElement('li');
        newTeam.textContent = 'New Team';
        newTeam.draggable = true;
        newTeam.ondragstart = drag;
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

    function allowDrop(event) {
        event.preventDefault();
    }

    function drag(event) {
        event.dataTransfer.setData("text", event.target.id);
    }

    function drop(event) {
        event.preventDefault();
        const data = event.dataTransfer.getData("text");
        const element = document.getElementById(data);
        event.target.appendChild(element);
        element.draggable = true;
    }

    document.querySelectorAll('.highlight-on-hover').forEach(element => {
        element.addEventListener('dragover', event => {
            event.preventDefault();
            element.classList.add('highlight');
        });

        element.addEventListener('dragleave', () => {
            element.classList.remove('highlight');
        });

        element.addEventListener('drop', event => {
            event.preventDefault();
            element.classList.remove('highlight');
            const data = event.dataTransfer.getData("text");
            const draggableElement = document.getElementById(data);
            element.appendChild(draggableElement);
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
