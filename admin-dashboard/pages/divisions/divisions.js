
function createNewTeam() {
    const teamName = prompt("Enter the new team's name:");
    if (teamName) {
        fetch('insertNewTeam.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ teamName })
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                const teamList = document.getElementById('teams-list');
                const newTeam = document.createElement('li');
                newTeam.textContent = teamName;
                newTeam.draggable = true;
                newTeam.id = data.teamID; // Set the ID to the newly created team ID
                newTeam.ondragstart = drag;
                teamList.appendChild(newTeam);
            } else {
                alert('Error: ' + data.message);
            }
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    }
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
        
        // Remove the "teamNoDivision" class from the dropped element
        draggableElement.classList.remove('teamNoDivision');

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
