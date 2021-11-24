var myTimer;
var start, remaining;

function startTimer(duration, display) {
    var timer = duration, minutes, seconds;
    start = Date.now();
    myTimer = setInterval(function () {
        minutes = parseInt(timer / 60, 10)
        seconds = parseInt(timer % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.textContent = minutes + ":" + seconds;

        remaining = timer;

        if (--timer < 0) {
            timer = duration;
        }
    }, 1000);
}

window.onload = function () {
    var minutesSelect = 60 * 25,
        display = document.querySelector('#time');
    startTimer(minutesSelect, display);
};

function pauseTimer(){
    window.clearTimeout(myTimer);
    console.log("pause");
}

function resumeTimer(){
    start = Date.now();
    window.clearTimeout(myTimer);
    var displayTimer = document.querySelector('#time');
    startTimer(remaining, displayTimer);
    console.log("resume");
}