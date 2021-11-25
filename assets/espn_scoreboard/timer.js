var myTimer;
var start;
var clockStatus = 'Paused';
var minutesSelected = 60 * 25;
var remaining = minutesSelected;

function startTimer(duration, display) {
    var timer = duration, minutes, seconds;
    start = Date.now();
    myTimer = setInterval(function () {
        minutes = parseInt(timer / 60, 10)
        seconds = parseInt(timer % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.textContent = minutes + ":" + seconds;

        if(timer==0){
            pauseTimer();
        }

        remaining = timer;

        if (--timer < 0) {
            timer = duration;
        }
    }, 1000);
}

// window.onload = function () {
//     display = document.querySelector('#time');
//     // startTimer(minutesSelect, display);
// };

function pauseTimer(){
    $('.clockStatus').text('Paused');
    window.clearTimeout(myTimer);
}

function resumeTimer(){
    start = Date.now();
    window.clearTimeout(myTimer);
    var displayTimer = document.querySelector('#time');
    startTimer(remaining-1, displayTimer);
    $('.clockStatus').text('Active');
}

function resetTimer(){
    var displayTimer = document.querySelector('#time');
    window.clearTimeout(myTimer);
    console.log("reset timer");
    displayTimer.textContent = "25:00";
    remaining = minutesSelected;
    pauseTimer();
}

function modifyTimer(){
    var displayTimer = document.querySelector('#time');
    pauseTimer();
    var minutes = prompt("Minutes: ");
    var seconds = prompt("Seconds: ");
    remaining = (parseInt(minutes) * 60) + parseInt(seconds);
    displayTimer.textContent = minutes + ":" + seconds;
}