// A $( document ).ready() block.
$( document ).ready(function() {

	var globalHistory = [];
	var playerFlag = false;
	var playerNode;
	var playerNodeRow;
	var playerNodeIndex;

	var dnpPlayerId;

	$(".saveBtn").click(function(){
		$("#saveScoresModal").show();

		// Remove the player highlight to prevent any numbers from updating stats
		$("td.playerBox").removeClass("playerHighlight");

		return false;
	});

	// Hidden Jersey Column for export
	$('.jerseyNumber').keyup(function() {
	    var exportJerseyNode = $(this).parent().next();
	    exportJerseyNode.html($(this).val());
	});

	$('.dnpIcon').click(function(){
		// Get the Player name to display in confirmation
		var playerName = $(this).next('.playerName').text();
		$('.dnpPlayer').text(playerName);

		$("#dnpModal").show();

		// Get/Set the Player's ID to remove later
		var rowPlayerID = $(this).parent().parent();
		dnpPlayerId = parseInt($(rowPlayerID).attr('id').replace(/[^\d]/g, ''), 10);

		setTimeout(function() {
			$("td.playerBox").removeClass("playerHighlight");
		   }, 100);

	});

	// DNP Remove Player Row
	$('.dnpConfirm').click(function(){
		$('#Player_'+dnpPlayerId).remove();
		$("#dnpModal").hide();
	})

	 $(document).keydown(function(e) {
	 	var currentFocus = $(':focus');
	 	if(currentFocus.hasClass('playerName') || currentFocus.hasClass('jerseyNumber')){
	 		return;
	 	}
	 	if(playerNode.hasClass("playerHighlight")){
			switch (e.which) {
			 case 97:
			 case 49:
			 	hotKeyAdd("FGM");
			   	break;
			 case 98:
			 case 50:
			   	hotKeyAdd("FGA");
			   	break;
			 case 99:
			 case 51:
			 	hotKeyAdd("3FGM");
			   	break;
			 case 100:  	
			 case 52:
			   	hotKeyAdd("3FGA");
			   	break;
			 case 101: 
			 case 53:
			 	hotKeyAdd("REBS");
			   	break;
			 case 102: 
			 case 54:
			   	hotKeyAdd("ASTS");
			   	break;
			 case 103: 
			 case 55:
			 	hotKeyAdd("STLS");
			   	break;
			 case 104: 
			 case 56:
			   	hotKeyAdd("BLKS");
			   	break;
			 case 105: 
			 case 57:
			   	hotKeyAdd("TO");
			   	break;
			 case 83: // s
			   	playerNodeIndex = $(playerNode).parent().index() + 1;
			   	// console.log("DOWN - playerNodeIndex: " + playerNodeIndex);
			   	if(playerNodeIndex < 5){
				   	var newPlayerNode = $("tr").find(".playerBox")[playerNodeIndex];
				   	$(newPlayerNode).trigger('click');
			   	}
			   	break;
			 case 87: // w
			   	playerNodeIndex = $(playerNode).parent().index() - 1;
			   	// console.log("UP - playerNodeIndex: " + playerNodeIndex);
			   	var newPlayerNode = $("tr").find(".playerBox")[playerNodeIndex];
			   	$(newPlayerNode).trigger('click');
			   	break;		   	
			}
	 	}
	 });

	$(".playerBox").click(function() {
	     // var row = $(this).parent('tr').index(),
	     //         column = $(this).index();
	     // console.log(row, column);

	     $("td").not(this).removeClass("playerHighlight");
	     $(this).toggleClass("playerHighlight");
	     playerNode = $(this);
	     playerNodeRow = $(this).parent('tr');
	})

	// $(document).keydown(function(e){
	// 	if( e.which === 90 && e.ctrlKey )
	// 	{
	// 		e.preventDefault();
	//         $('.undoBtn').trigger("click"); 
	//     }          
	// }); 

	function hotKeyAdd(category){

		var addNode = $(playerNodeRow).find('.'+ category).not('.button-error')

		// Push to globalHistory
		var undoNode = $(addNode).siblings('.button-error');
		globalHistory.push(undoNode);

		var playerID = $(addNode).closest('tr').attr('id');
		var fieldValueSpan = $(addNode).siblings(".fieldValue");
		var fieldValue = parseInt($(addNode).siblings(".fieldValue").val());
		var newFieldValue = fieldValue + 1;
		fieldValueSpan.val(newFieldValue);

		/* Visual Display of Add*/
		var tdFlash = $(addNode).parent();
		flashBackground(tdFlash);

		if($(addNode).hasClass("FGM")){
			addToValue("FGA", 1, playerID);
			addToValue("PTS", 2, playerID);
		}
		else if($(addNode).hasClass("3FGM")){
			addToValue("FGM", 1, playerID);
			addToValue("FGA", 1, playerID);
			addToValue("3FGA", 1, playerID);
			addToValue("PTS", 3, playerID);
		}
		else if($(addNode).hasClass("3FGA")){
			addToValue("FGA", 1, playerID);
		}
		else if($(addNode).hasClass("FTM")){
			addToValue("PTS", 1, playerID);
			addToValue("FTA", 1, playerID);
		}
	}


	$( ".button-success" ).click(function() {
		// Push to globalHistory
		var undoNode = $(this).siblings('.button-error');
		globalHistory.push(undoNode);

		var playerID = $(this).closest('tr').attr('id');
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").val());
		var newFieldValue = fieldValue + 1;
		fieldValueSpan.val(newFieldValue);

		if($(this).hasClass("FGM")){
			addToValue("FGA", 1, playerID);
			addToValue("PTS", 2, playerID);
		}
		else if($(this).hasClass("3FGM")){
			addToValue("FGM", 1, playerID);
			addToValue("FGA", 1, playerID);
			addToValue("3FGA", 1, playerID);
			addToValue("PTS", 3, playerID);
		}
		else if($(this).hasClass("3FGA")){
			addToValue("FGA", 1, playerID);
		}
		else if($(this).hasClass("FTM")){
			addToValue("PTS", 1, playerID);
			addToValue("FTA", 1, playerID);
		}
		else if($(this).hasClass("FOULS")){
			var currentHalf = getCurrentHalf();
			console.log(currentHalf);
			var currentNum = parseFloat($('.Fouls_Half_'+currentHalf).html());
			currentNum += 1;
			$('.Fouls_Half_'+currentHalf).html(currentNum);
		}
	});

	$(document).keydown(function(e){
		if( e.which === 90 && e.ctrlKey )
		{
			e.preventDefault();
	        $('.undoBtn').trigger("click"); 
	    }          
	}); 

	$( ".undoBtn" ).click(function() {
		var undoAction = globalHistory.pop();
		$(undoAction).trigger("click");
	});

	$( ".button-error" ).click(function() {
		var fieldValueSpan = $(this).siblings(".fieldValue");
		var fieldValue = parseInt($(this).siblings(".fieldValue").val());
		var playerID = $(this).closest('tr').attr('id');
		var newFieldValue = fieldValue - 1;
		if(newFieldValue >= 0) {
			fieldValueSpan.val(newFieldValue);
			if($(this).hasClass("FGM")){
				addToValue("FGA", -1, playerID);
				addToValue("PTS", -2, playerID);
			}
			else if($(this).hasClass("3FGM")){
				addToValue("FGM", -1, playerID);
				addToValue("FGA", -1, playerID);
				addToValue("3FGA", -1, playerID);
				addToValue("PTS", -3, playerID);
			}
			else if($(this).hasClass("3FGA")){
				addToValue("FGA", -1, playerID);
			}
			else if($(this).hasClass("FTM")){
				addToValue("PTS", -1, playerID);
				addToValue("FTA", -1, playerID);
			}
		}
	});

	function addToValue(id, addValue, playerID){
		var fieldValueSpan = $("#"+playerID).find("#"+id);
		var fieldValue = parseInt(fieldValueSpan.val());
		var newFieldValue = fieldValue + addValue;
		fieldValueSpan.val(newFieldValue);

		/* Visual Display of Add*/
		// var tdFlash = $(fieldValueSpan).parent();
		// flashBackground(tdFlash);

		 if(id=="PTS"){
			var currentNum = parseFloat($('.teamTotalPts').html());
			currentNum += addValue;
			$('.teamTotalPts').html(currentNum);
		 }
	}

	/* Drag and drop section */
	// var fixHelperModified = function(e, tr) {
	//     var $originals = tr.children();
	//     var $helper = tr.clone();
	//     $helper.children().each(function(index) {
	//         $(this).width($originals.eq(index).width())
	//     });
	//     return $helper;
	// },
	//     updateIndex = function(e, ui) {
	//         $('td.index', ui.item.parent()).each(function (i) {
	//             $(this).html(i + 1);
	//         });
	//     };

	// $("#sort tbody").sortable({
	//     helper: fixHelperModified,
	//     stop: updateIndex,
	//     cursor: "grabbing",
	//     cancel: "#bench"
	// }).disableSelection();
	/* End Drag and drop section */

	/* Test Drag and Replace */
	jQuery.fn.swap = function(b){ 
	    // method from: http://blog.pengoworks.com/index.cfm/2008/9/24/A-quick-and-dirty-swap-method-for-jQuery
	    b = jQuery(b)[0]; 
	    var a = this[0]; 
	    var t = a.parentNode.insertBefore(document.createTextNode(''), a); 
	    b.parentNode.insertBefore(a, b); 
	    t.parentNode.insertBefore(b, t); 
	    t.parentNode.removeChild(t); 
	    return this; 
	};


	$( ".dragdrop" ).draggable({ revert: true, helper: "clone" });

	$( ".dragdrop" ).droppable({
	    accept: ".dragdrop",
	    activeClass: "ui-state-hover",
	    hoverClass: "ui-state-active",
	    drop: function( event, ui ) {

	        var draggable = ui.draggable, droppable = $(this),
	            dragPos = draggable.position(), dropPos = droppable.position();
	        
	        draggable.css({
	            left: dropPos.left+'px',
	            top: dropPos.top+'px'
	        });

	        droppable.css({
	            left: dragPos.left+'px',
	            top: dragPos.top+'px'
	        });
	        draggable.swap(droppable);
	    }
	});
	/* End Drag Replace */

	// Collapse Bench Section
	$('#benchToggle').removeClass("ui-sortable-handle");
	$("#benchToggle").click(function() {
	  $(this).nextAll().toggle();
	});

	function flashBackground(node) 
	{ 
		// Flash yellow background
		$(node).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
	}

	// 1st Half to 2nd Half Logic
	$(".switch-label").click(function() {
	   var currentHalf = $(this).data('value');
	   if (currentHalf == "1") {
	     $(this).data('value', "2");
	   } else {
	     $(this).data('value', "1");
	   }
	});

	function getCurrentHalf(){
		return $(".switch-label").data('value');
	}

});