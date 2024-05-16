
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
        
        // AJAX call to update team in division
        const teamID = data;
        const divisionID = element.id;
        
        fetch('updateTeamInDivision.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ teamID, divisionID })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Success:', data);
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    });
});
