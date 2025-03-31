$( document ).ready(function() {
  $(".ands-menu-toggle, .ands-modal").click (function(){
		$("body").toggleClass("ands-open");
		$(".ands-modal").toggleClass("ands-open");
	});
	$( '.ands-tree li' ).each( function() {
		if( $( this ).children( 'ul' ).length > 0 ) {
			$( this ).addClass( 'ands-parent' );     
		}
	});
	$( '.ands-tree li.ands-parent > a' ).click( function( ) {
		$( this ).parent().toggleClass( 'active' );
		$( this ).parent().children( 'ul' ).slideToggle( 'fast' );
	});
	$( '#ands-all' ).click( function() {
		$( '.ands-tree li' ).each( function() {
			$( this ).toggleClass( 'active' );
			$( this ).children( 'ul' ).slideToggle( 'fast' );
		});
	});
	$(".ands-drop").click (function(){
		$(".ands-drop>ul").toggleClass("ands-open");
	});
	$("table thead th a").click (function(){
		$("i").toggleClass("ands-show");
	});
});