function myFunction() {
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  table = document.getElementById("myTable");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    home = tr[i].getElementsByTagName("td")[0];
    away = tr[i].getElementsByTagName("td")[1];
    if (home && away) {
      txtValue = home.textContent || home.innerText;
      txtValue2 = away.textContent || away.innerText;
      if (txtValue.toUpperCase().indexOf(filter) > -1 || txtValue2.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
        $(".weekRow").hide();
      }
    }      
  }
  if(filter.length == 0){
    $(".weekRow").show();
  }
}