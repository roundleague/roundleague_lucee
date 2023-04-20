$( document ).ready(function() {

  $(".playerInfoBtn").click(function(){
    openCity('PlayerInfo')
  });

  $(".playerStatsBtn").click(function(){
    openCity('PlayerStats')
  });

  $(".franchiseInfoBtn").click(function(){
    openCity('FranchiseInfo')
  });

  function openCity(cityName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    document.getElementById(cityName).style.display = "block";
  }

  document.getElementById("defaultOpen").click();

});
