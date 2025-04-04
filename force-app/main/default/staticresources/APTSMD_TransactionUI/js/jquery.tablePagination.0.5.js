/**

 * tablePagination - A table plugin for jQuery that creates pagination elements

 *

 * http://neoalchemy.org/tablePagination.html

 *

 * Copyright (c) 2009 Ryan Zielke (neoalchemy.com)

 * licensed under the MIT licenses:

 * http://www.opensource.org/licenses/mit-license.php

 *

 * @name tablePagination

 * @type jQuery

 * @param Object settings;

 *      firstArrow - Image - Pass in an image to replace default image. Default: (new Image()).src="./images/first.gif"

 *      prevArrow - Image - Pass in an image to replace default image. Default: (new Image()).src="./images/prev.gif"

 *      lastArrow - Image - Pass in an image to replace default image. Default: (new Image()).src="./images/last.gif"

 *      nextArrow - Image - Pass in an image to replace default image. Default: (new Image()).src="./images/next.gif"

 *      rowsPerPage - Number - used to determine the starting rows per page. Default: 5

 *      currPage - Number - This is to determine what the starting current page is. Default: 1

 *      optionsForRows - Array - This is to set the values on the rows per page. Default: [5,10,25,50,100]

 *      ignoreRows - Array - This is to specify which 'tr' rows to ignore. It is recommended that you have those rows be invisible as they will mess with page counts. Default: []

 *      topNav - Boolean - This specifies the desire to have the navigation be a top nav bar

 *

 *

 * @author Ryan Zielke (neoalchemy.org)

 * @version 0.5

 * @requires jQuery v1.2.3 or above

 */



 (function($){



	$.fn.tablePagination = function(settings) {

		var defaults = {  

			//firstArrow : (new Image()).src="images/first.png",  

			prevArrow : (new Image()).src="images/prev.png",

			//lastArrow : (new Image()).src="images/last.png",

			nextArrow : (new Image()).src="images/next.png",

			rowsPerPage :5,

			currPage : 1,

			optionsForRows : [5,10,25,50,100,200],

			ignoreRows : [],

			topNav : false,
			
			trClass : '',
			trClassSubOne : '',
			trClassSubTwo : ''
			

		};  


		settings = $.extend(defaults, settings);
		

		return this.each(function() {

      var table = $(this)[0];

      var totalPagesId, currPageId, rowsPerPageId, firstPageId, prevPageId, nextPageId, lastPageId;

      totalPagesId = '.tablePagination_totalPages';

      currPageId = '.tablePagination_currPage';

      rowsPerPageId = '.tablePagination_rowsPerPage';


      prevPageId = '.tablePagination_prevPage';

      nextPageId = '.tablePagination_nextPage';


      var tblLocation = (defaults.topNav) ? "prev" : "next";



      var possibleTableRows = $.makeArray($('tbody tr'+defaults.trClass, table));
	  var possibleTableRowsSubOne = $.makeArray($('tbody tr'+defaults.trClassSubOne, table));
 	  var possibleTableRowsSubTwo = $.makeArray($('tbody tr'+defaults.trClassSubTwo, table));

      var tableRowsSubTwo = $.grep(possibleTableRowsSubTwo, function(value, index) {

        return ($.inArray(value, defaults.ignoreRows) == -1);

      }, false)
	 
	 var tableRowsSubOne = $.grep(possibleTableRowsSubOne, function(value, index) {

        return ($.inArray(value, defaults.ignoreRows) == -1);

      }, false)
	  
	  var tableRows = $.grep(possibleTableRows, function(value, index) {

        return ($.inArray(value, defaults.ignoreRows) == -1);

      }, false)

      

      var numRows = tableRows.length

      var totalPages = resetTotalPages();

      var currPageNumber = (defaults.currPage > totalPages) ? 1 : defaults.currPage;

      if ($.inArray(defaults.rowsPerPage, defaults.optionsForRows) == -1)

        defaults.optionsForRows.push(defaults.rowsPerPage);

      

      

      function hideOtherPages(pageNum) {

        if (pageNum==0 || pageNum > totalPages)

          return;

        var startIndex = (pageNum - 1) * defaults.rowsPerPage;

        var endIndex = (startIndex + defaults.rowsPerPage - 1);

        $(tableRows).show();
		$(tableRowsSubOne).show();
		$(tableRowsSubTwo).show();
		
		for (var i=0;i<tableRowsSubTwo.length;i++) {
			
			  if (i < startIndex || i > endIndex) {
			
				$(tableRowsSubTwo[i]).hide()
			
			  }
			
			}



		for (var i=0;i<tableRowsSubOne.length;i++) {
		
		  if (i < startIndex || i > endIndex) {
		
			$(tableRowsSubOne[i]).hide()
		
		  }
		
		}


        for (var i=0;i<tableRows.length;i++) {

          if (i < startIndex || i > endIndex) {

            $(tableRows[i]).hide()

          }

        }

      }

      

      function resetTotalPages() {

        var preTotalPages = Math.round(numRows / defaults.rowsPerPage);

        var totalPages = (preTotalPages * defaults.rowsPerPage < numRows) ? preTotalPages + 1 : preTotalPages;

        if ($(table)[tblLocation]().find(totalPagesId).length > 0)

          $(table)[tblLocation]().find(totalPagesId).html(totalPages);

        return totalPages;

      }

      

      function resetCurrentPage(currPageNum) {

        if (currPageNum < 1 || currPageNum > totalPages)

          return;

        currPageNumber = currPageNum;

        hideOtherPages(currPageNumber);

        $(table)[tblLocation]().find(currPageId).val(currPageNumber)

      }

      

      function resetPerPageValues() {

        var isRowsPerPageMatched = false;

        var optsPerPage = defaults.optionsForRows;

        optsPerPage.sort(function (a,b){return a - b;});

        var perPageDropdown = $(table)[tblLocation]().find(rowsPerPageId)[0];

        perPageDropdown.length = 0;

        for (var i=0;i<optsPerPage.length;i++) {

          if (optsPerPage[i] == defaults.rowsPerPage) {

            perPageDropdown.options[i] = new Option(optsPerPage[i], optsPerPage[i], true, true);

            isRowsPerPageMatched = true;

          }

          else {

            perPageDropdown.options[i] = new Option(optsPerPage[i], optsPerPage[i]);

          }

        }

        if (!isRowsPerPageMatched) {

          defaults.optionsForRows == optsPerPage[0];

        }

      }

      

      function createPaginationElements() {
		
        var htmlBuffer = [];

        htmlBuffer.push("<div class='tablePagination'>");

        htmlBuffer.push("<span class='tablePagination_perPage'>");

        htmlBuffer.push("View &nbsp; <select class='tablePagination_rowsPerPage moreCategoriesSelect'><option value='5'>5</option></select>");

        htmlBuffer.push("<big>Items Per Page</big>");

        htmlBuffer.push("</span>");

        htmlBuffer.push("<div class='tablePagination_paginater'>");

        htmlBuffer.push("<span class='tablePagination_prevPage'>Previous</span>");

        htmlBuffer.push("<span>Page</span>");

        htmlBuffer.push("<span><input class='tablePagination_currPage' type='input' value='"+currPageNumber+"' size='1'></span>");

        htmlBuffer.push("<span>of</span> <span class='tablePagination_totalPages'>"+totalPages+"</span>");

        htmlBuffer.push("<span class='tablePagination_nextPage'>Next</span>");

        htmlBuffer.push("</div>");

        htmlBuffer.push("<div class='clear'>");

        htmlBuffer.push("</div>");

        htmlBuffer.push("</div>");

        return htmlBuffer.join("").toString();
		

      }

      

      if ($(table)[tblLocation]().find(totalPagesId).length == 0) {

		if (defaults.topNav) {

			$(this).before(createPaginationElements());

		} else {

			$(this).after(createPaginationElements());

		}

      }

      else {

        $(table)[tblLocation]().find(currPageId).val(currPageNumber);

      }

      resetPerPageValues();

      hideOtherPages(currPageNumber);

      

      $(table)[tblLocation]().find(firstPageId).bind('click', function (e) {

        resetCurrentPage(1)

      });

      

      $(table)[tblLocation]().find(prevPageId).bind('click', function (e) {

        resetCurrentPage(currPageNumber - 1)

      });

      

      $(table)[tblLocation]().find(nextPageId).bind('click', function (e) {

        resetCurrentPage(parseInt(currPageNumber) + 1)

      });

      

      $(table)[tblLocation]().find(lastPageId).bind('click', function (e) {

        resetCurrentPage(totalPages)

      });

      

      $(table)[tblLocation]().find(currPageId).bind('change', function (e) {

        resetCurrentPage(this.value)

      });

      /*$(table)[tblLocation]().find(currPageId).bind('keypress', function (e) {

    	  if(e.which == 13){

    		  e.preventDefault();

    		  resetCurrentPage(this.value);

    	  }

        });*/



      

      $(table)[tblLocation]().find(rowsPerPageId).bind('change', function (e) {

        defaults.rowsPerPage = parseInt(this.value, 10);

        totalPages = resetTotalPages();

        resetCurrentPage(1)

      });

      

		})

	};		

})(jQuery);