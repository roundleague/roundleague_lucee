$( document ).ready(function() {

  $(".playerInfoBtn").click(function(){
    openTab('PlayerInfo')
  });

  $(".playerStatsBtn").click(function(){
    openTab('PlayerStats')
  });

  $(".franchiseInfoBtn").click(function(){
    openTab('FranchiseInfo')
  });

  function openTab(tabName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    document.getElementById(tabName).style.display = "block";
  }

  document.getElementById("defaultOpen").click();

});