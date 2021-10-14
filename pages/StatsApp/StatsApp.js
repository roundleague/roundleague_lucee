// A $( document ).ready() block.
$( document ).ready(function() {

	var globalHistory = [];

	$(".saveBtn").click(function(){
		$("#id01").show();
		return false;
	});

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

});