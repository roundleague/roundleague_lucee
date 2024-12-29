$(document).ready(function () {
  // Initialize flatpickr on all inputs with the class 'datepicker'
  $(".datepicker").flatpickr({
    dateFormat: "m/d/Y",
    time_24hr: true,
  });
});
