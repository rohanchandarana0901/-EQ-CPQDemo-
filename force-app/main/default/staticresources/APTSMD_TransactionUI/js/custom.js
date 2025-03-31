$(document).ready(function() {
						   
	     var autoFixHeader = function () {
        $('.header_fix:visible').each(function (ind) {
            $this = $(this);
            if (!$(this).hasClass("fixed")) {
                $this = $(this);
                if (!$(this).hasClass('pvotRgtBox'))
                    $('<div>').addClass('fixedHeaderContainer').attr('data-index', ind).width($(this).find('thead').width()).insertBefore($(this));
                $(this).attr('fixedheader', ind);
                $(this).find('thead').hide();
                $(this).addClass("fixed");

                $newDiv = $('<div>').addClass('fixHeader' + ind).attr('fixedheader', ind).html('<table><thead>' + $(this).find('table thead').html() + '</thead></table>').appendTo('body');
                var offset = $(this).offset();
                $this.attr('data-top', offset.top);
                $this.attr('data-left', offset.left);
            }
            else {
                $newDiv = $('div.fixHeader' + ind);
            }

            if ($(this).hasClass('pvotRgtBox')) {
                var offsetTop = $('.pvotLftBox.header_fix').prev().offset().top;
                var offsetLeft = $(this).offset().left;
            }
            else {
                var offsetTop = $(this).prev().offset().top + 2;
                var offsetLeft = $(this).prev().offset().left;
            }

            var zind = 1000;
            $newDiv.css({
                'width': $(this).width() + 1,
                'top': offsetTop + 'px',
                'left': (offsetLeft) + 'px',
                'overflow': 'hidden',
                'position': 'absolute',
                'z-index': zind,
                'background-color': 'rgb(245, 245, 245)'
            });
            $('div.fixHeader' + ind).find('table:visible').width($(this).width() + 1);
            /*    $('div.fixHeader' + ind + ' thead tr').find('th').each(function (ind, ele) {
             $(ele).width($this.find('tbody td').eq(ind).width());
             }); */
            setTimeout(function () {
                $('.fixedHeaderContainer[data-index="' + ind + '"]').height($('.fixHeader' + ind).height() + 2);
            }, 10);
        });
    };
autoFixHeader();



 $('body').on('click', '.indicator', function () {
        autoFixHeader();
    });
	
	$(".all-categories ul li").click(function() {
    currentCat = $(this).attr("data-cat");
    currentSymbol = $(this).attr("data-symbol");
    if($(this).closest(".all-categories").hasClass("currency-menu")){
        $(".currency-sign").html(currentSymbol);
    }
        $(".all-categories ul li").removeClass("active");
        $(".search-top .all-search-text").removeClass("active");
        $(this).addClass("active");
        
        var placehldr = "";
        placehldr = currentCat;
        if (typeof currentCat === 'undefined') {
            currentCat = "";
            placehldr = "";
        };
        var container = $(this).closest(".all-categories").prev().find(".all-search-text");
        $(container).find(".catSelected").hide();
        $(container).find(".catSelected .gray-txt").html(currentCat);
        $(container).find(".catSelected").fadeIn();
        $(".all-categories").slideUp();
    });
	
	$(".all-search-text").click(function() {
        $(this).closest(".search-outer").find(".more-link span").removeClass("active");
        $(this).closest(".search-outer").find(".link-categories").slideUp();
        $(this).toggleClass("active");
        $("#searchInput").val("");
        $(this).closest(".search-outer").find(".all-categories").slideToggle();
    });
				
						   
						   
	
	/*--Select Option Box --*/
	$(".moreCategoriesSelect").selectbox();
	/*--Radio/CheckBox Option Box --*/
	$('body').label_radio_check();
	
	$('.tooltip').tipsy({ gravity: 's'});
	$('.tooltip-n').tipsy({ gravity: 'n'});
	$('.tooltip-w').tipsy({ gravity: 'w'});
	$('.tooltip-e').tipsy({ gravity: 'e'});
	$('.tooltip-sw').tipsy({ gravity: 'sw'});
	$('.tooltip-se').tipsy({ gravity: 'se'});
	$('.tooltip-nw').tipsy({ gravity: 'nw'});
	$('.tooltip-ne').tipsy({ gravity: 'ne'});
	
	/** Credit Card Verification  Script ***/
	$(function() {
			$('input.credit-card-info').validateCreditCard(function(result) {
            $('.card-type').attr('class', 'card-type').addClass((result.card_type == null ? '' : result.card_type.name));
        }); 
    });
	
	/** Credit Card Verification  Script Ends  ***/
	
	
	/*check card filled */
	
	$(".add-pay-mathod input[type=text]").on("keyup",function(){
		checkCardFilled();
	});
	
	
	$(".card-num").on("keypress",function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        //$("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
	
	$(".moreCategoriesSelect").on("change",function(){
		checkCardFilled();
	});
	
	
	function checkCardFilled(){
		var cardNo      = $(".card-number input[type=text]").val();
		var cardMonth   = $(".card-month select").val();
		var cardYear    = $(".card-year select").val();
		var cvvNo       = $(".card-cvv input[type=text]").val();
		var cardUserName = $(".card-user-name input[type=text]").val();
		
	if(cardNo!="" && cardMonth!=0 && cardYear!=0 && cvvNo!="" && cardUserName!=""){
		$(".submit-payment").removeAttr("disabled");
	}else{
		$(".submit-payment").attr("disabled","disabled");
	}
	}
	
	/*check card filled End*/
	
	
	
	/*get saved card*/
	
	$(".method-choice select").on("change",function(){
		var card = $(this).val();
		if(card==1){
			$(".card-number input[type=text]").val("0000111122223333");
			$(".card-month select").val("2").change();
			$(".card-year select").val("4").change();
			$(".card-user-name input[type=text]").val("Bob");
			$('.card-type').attr('class', 'card-type').addClass("mastercard");
			$(".submit-payment").removeAttr("disabled");
		}else if(card==2){
			$(".card-number input[type=text]").val("6666777788889999");
			$(".card-month select").val("1").change();
			$(".card-year select").val("5").change();
			$(".card-user-name input[type=text]").val("Alice");
			$('.card-type').attr('class', 'card-type').addClass("discover");
			$(".submit-payment").removeAttr("disabled");
		}
	});
	
	/*get saved card Ends*/
	
	$(".pvotLftBox").niceScroll({
	   cursorcolor:" #e5e5e5"
	});
	$( ".datepicker" ).datepicker({
	  dayNamesMin: [ "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" ],
	  dateFormat: 'MM dd, yy',
	});
	
	$( "#invoice-stlmnt" ).buttonset();
	
	$(".view-summary").click(function(){
		//$(".internal-links").show("slide", { direction: "right" }, 500);
		//$(".internal-links").show("hide", { direction: "left" }, 500);
		$(".internal-links").hide();
		$(this).closest("td").find(".internal-links").show("slide", { direction: "right" }, 700);
	});
	$(".close-internal-link").click(function(){
		//$(".internal-links").hide("slide", { direction: "right" }, 500);
		$(this).closest("td").find(".internal-links").show("hide", { direction: "left" }, 700);
	});
	
	
	 $(".pay-now-overlay").fancybox({
        'titlePosition': 'inside',
        'transitionIn': 'none',
        'transitionOut': 'none',
        'href': '#payment-info-overlay',
		'afterShow': function(){
			$(".sbOptions").getNiceScroll().remove();
			$(".sbOptions").niceScroll({
			   		cursorcolor: "#e3e3e3",
					autohidemode: false
			   });
			 $(".add-pay-mathod").getNiceScroll().remove();  
			 $(".add-pay-mathod").niceScroll({
						cursorcolor: "#B2B2B2",
						cursorwidth: "7px",
						zindex: "1000",
						autohidemode: false,
				}); 
			$(".modal-content").niceScroll({
			cursorcolor: "#e3e3e3",
			autohidemode: false,
			});
			}
    });
	  
	$(".scrollbox").niceScroll({
        cursorcolor: "#B2B2B2",
        cursorwidth: "7px",
        zindex: "1000",
        autohidemode: false,
    });
	$(".add-pay-mathod").niceScroll({
        cursorcolor: "#B2B2B2",
        cursorwidth: "7px",
        zindex: "1000",
        autohidemode: false,
    });
	
	
/*	$("td.tbl-col-width").each(function(ind){ 
									  
									$(".fixed-header .tbl-col-width:eq("+ind+")").width($(this).width());
									  $(this).width($(this).width());
									  });*/
	
	$( ".datepicker" ).each(function(){
		$(this).datepicker( "hide" );
	});
	$(".edit-icon a").click(function(e){
								   $(this).closest(".edit-field").addClass("active");
								   var value = $(this).closest(".invoice-value").find(".edit-field").text();
								   value = value.substring(1);
								   $(this).closest(".invoice-value").find(".edit-field").hide();
								   $(this).closest(".invoice-value").find(".edit-input").val(value).show().focus();
								   //$(this).hide();
								   });
								   
								   $(".edit-input").keyup(function(e){
								   
								   if(e.which==13){
								    $(".edit-input").each(function(){ 
											var value = $(this).val();
											$(this).closest(".invoice-value").find(".edit-field.xyz").text("$"+value);	
											$(this).closest(".invoice-value").find(".edit-icon").show();
													   });
									$(".edit-input").hide();
									$(".edit-field").show();
									$(".edit-icon").show();
									$(".invoice-bar").removeClass("show-invoice-field");
								   }
								   }).keypress(function(e){
									return isNumber(e);
								   });
	
	$(".sbOptions").niceScroll({
		   cursorcolor: "#e3e3e3"
		   });
	
	
	
	
	 $("body").mousedown(function (e)
				{
					var container = $(".edit-field, .invoice-value");
				
					if (!container.is(e.target) // if the target of the click isn't the container...
						&& container.has(e.target).length === 0) // ... nor a descendant of the container
					{
							
						
						$(".edit-input").each(function(){ 
											var value = $(this).val();
											$(this).closest(".invoice-value").find(".edit-field").text("$"+value);	
											$(this).closest(".invoice-value").find(".edit-icon").show();
													   });
						
						$(".edit-input").hide();
						$(".edit-field").show();
						$(".edit-icon").show();
						$(".invoice-bar").removeClass("show-invoice-field");
					}
				});
	 
	/* $(".scheduling-form input[type=radio]").on("change",function(){
  if($(this).hasClass("scheduling-form-run-now")){
   $(".schedule-rec").addClass("disable-schedule");
   $(".schedule-rec").find("input[type=radio],.datepicker ").attr("disabled","disabled");
     }else if($(this).hasClass("scheduling-form-recurring")){
   $(".schedule-rec").removeClass("disable-schedule");
   $(".schedule-rec").find("input[type=radio],.datepicker ").removeAttr("disabled");
  }
 });*/
 

$("input[name='methodType']").on("change",function(){
		if($(this).val()=="existing-pay-method"){
			
				$(".method-choice select").removeAttr("disabled");
				$(".add-pay-mathod input[type=text]").attr("disabled","disabled");
				$(".add-pay-mathod select").attr("disabled","disabled");
				$(".moreCategoriesSelect").selectbox("detach").selectbox();
				$(".method-choice select").val(0).change();
				$(".submit-payment").attr("disabled","disabled");
				
			}else if($(this).val()=="new-pay-method"){
				
				$(".method-choice select").attr("disabled","disabled");
				$(".add-pay-mathod input[type=text]").removeAttr("disabled");
				$(".card-number input[type=text]").val("");
				$(".card-user-name input[type=text]").val("");
				$(".add-pay-mathod select").val("0").change().removeAttr("disabled");
				$(".moreCategoriesSelect").selectbox("detach").selectbox();
				$(".card-type").attr("class","card-type");
				}
				$(".sbOptions").niceScroll({
					cursorcolor: "#e3e3e3"
			   });
				 });

	
			$(document).mouseup(function (e) {
				var container = $(".all-categories, .all-search-text");
				
				if (!container.is(e.target) // if the target of the click isn't the container...
						&& container.has(e.target).length === 0) // ... nor a descendant of the container
				{
						$(".all-categories").slideUp();
						
				}
			
			});

		  
		  $(document).mouseup(function (e) {
				var container = $(".internal-links");
				
				if (!container.is(e.target) // if the target of the click isn't the container...
						&& container.has(e.target).length === 0) // ... nor a descendant of the container
				{
						$(".internal-links").hide();
						
				}
			
			});
    
});
				
				/*--close menu on body click(end)--*/												 
	
	
	/*--check/uncheck all(start)--*/
	
	$(document).on("click",'thead .label_check',function(e){
			
				var thisCheckbox = $('input[data-chk="head"]').is(":checked");//toggle check
				
				var checkedbox = $('input[data-chk="body"]:checked').length;
		if(checkedbox > 0){
			$('.table-action-btn .btn ').attr("disabled","disabled");
		}else{
			$('.table-action-btn .btn ').removeAttr("disabled");
			}
				
				if(thisCheckbox==true){
					$('input[data-chk="body"]').prop("checked",thisCheckbox).parent('label').removeClass('c_off').addClass('c_on');
				}else{
					$('input[data-chk="body"]').prop("checked",thisCheckbox).parent('label').removeClass('c_on').addClass('c_off');
					
				}
				
		
	});

	$(document).on('change','input[data-chk="body"]',function(e){
		var checkbox   = $('input[data-chk="body"]').length;
		var checkedboxHead = $('input[data-chk="head"]:checked').length;
		if(checkedboxHead > 0){
			$('.table-action-btn .btn ').removeAttr("disabled");
		}else{
			$('.table-action-btn .btn ').attr("disabled","disabled");
			}

		var checkedbox = $('input[data-chk="body"]:checked').length;
		if(checkedbox > 0){
			$('.table-action-btn .btn ').removeAttr("disabled");
		}else{
			$('.table-action-btn .btn ').attr("disabled","disabled");
			}


		if(checkbox == checkedbox){$('input[data-chk="head"]').prop("checked",true).parent('label').removeClass('c_off').addClass('c_on');}
		else{
			$('input[data-chk="head"]').prop("checked",false).parent('label').removeClass('c_on').addClass('c_off');
	    	
		}
	}); 
	

	/*--check/uncheck all(end)--*/
	setTimeout(function(){
		$(".transaction-table-wrapper").tablePagination();
		$(".transaction-table-wrapper").niceScroll({cursorcolor:"#e9e7e8"});
		$(".moreCategoriesSelect").selectbox();
		
		
		$(".transactionTable thead th").each(function(ind){
				 var thwidth = $(this).width();
				$(".transactionTable tbody tr").each(function(){
											$(this).find("td:eq("+ind+")").width(thwidth+"%");				  
															  });  
				  });
		
		
		
	},4000);
	

	
	
	
	
	/*--adjust header width on resize(start)--*/
	
	$(window).resize(function(){
		  var wd = $(".table-wrapper").width();
		  	
		  $(".pivotBoxWrapper").width(wd);			  
		  $(".fixHeader1").width(wd);	
		  $(".fixHeader1 table").width(wd);
		  $("[fixheader=1]").width(wd);
	});
	
	
	/*--adjust header width on resize(end)--*/
																 
	 
	


/*-only allow numbers in input(start)-*/

function isNumber(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}


/*-only allow numbers in input(end)-*/