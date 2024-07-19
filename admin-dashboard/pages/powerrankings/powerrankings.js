const teams = document.querySelectorAll('.team-bank div');
const ranks = document.querySelectorAll('.power-rankings div');
const teamBank = document.querySelector('.team-bank');

teams.forEach(team => {
    team.addEventListener('dragstart', dragStart);
    team.addEventListener('dragend', dragEnd);
});

ranks.forEach(rank => {
    rank.addEventListener('dragover', dragOver);
    rank.addEventListener('drop', drop);
    rank.addEventListener('dragenter', dragEnter);
    rank.addEventListener('dragleave', dragLeave);
});

teamBank.addEventListener('dragover', dragOver);
teamBank.addEventListener('drop', dropToBank);

function removeDragOverClass() {
    document.querySelectorAll('.drag-over').forEach(element => {
        element.classList.remove('drag-over');
    });
}

function dragStart(e) {
    e.dataTransfer.setData('text/plain', e.target.id);
    setTimeout(() => {
        e.target.style.display = 'none';
    }, 0);
}

function dragEnd(e) {
    e.target.style.display = 'block';
    removeDragOverClass();
}

function dragOver(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function drop(e) {
    e.preventDefault();
    removeDragOverClass();
    const id = e.dataTransfer.getData('text/plain');
    const draggable = document.getElementById(id);
    draggable.style.display = 'block';

    if (e.target.classList.contains('rank')) {
        // Create a container to hold both the rank and the team
        const container = document.createElement('div');
        container.className = 'rank-container';

        // Set the rank element's width
        e.target.classList.add('rank-with-team');

        // Insert the rank and the draggable team into the container
        container.appendChild(e.target.cloneNode(true));
        container.appendChild(draggable);

        // Replace the rank element with the container
        e.target.parentNode.replaceChild(container, e.target);
    } else if (e.target.classList.contains('team-bank')) {
        teamBank.appendChild(draggable);
        teamBank.classList.remove('drag-over');
    } else {
        draggable.style.display = 'block';
    }
}


function dragEnter(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function dragLeave(e) {
    e.target.classList.remove('drag-over');
}

function dropToBank(e) {
    e.preventDefault();
    const id = e.dataTransfer.getData('text/plain');
    const draggable = document.getElementById(id);
    teamBank.appendChild(draggable);
    draggable.style.display = 'block';
    teamBank.classList.remove('drag-over');
}
