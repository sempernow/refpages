// document ready :: jQuery code outer wrapper 
$(document).ready(function(){
   // jQuery methods go here...
});
// identical [shorthand] 
$(function(){
   // jQuery methods go here...
}); 
// callback/error handling (data,status,object)
$('p.sample').load( path, function (responseText, textStatus, req) {
	//alert(textStatus);
	if (textStatus == "error") { return "message here"; }
});


$('a:contains("Garamond")').click(function () {
	$('h1').html('EB Garamond Bold/400');
	$('h1, #lorem, #glyphs').addClass('Garamond');
});	

$('a').click(function () {
	var title = $(this).attr('title');
	var Class = $(this).text();
	$('h1').html(title);
	$('h1, #lorem, #glyphs').removeClass().addClass(Class);
		
});		
// -- load html file [font sample text] into each p.sample element --
$('p.sample').load('txt-0.html', function() {
// loaded (callback function goes here)
});

// toggle/alternate between 2 functions 
$( 'li.meta a:contains("CSS")' ).toggle(function() {
	// block 1
}, function() {
	// block 2
});

// reload page 
location.reload();

// replace div containing text-str, and its contents, w/ new block of html code
$( "div:contains('text-str')").replaceWith( 'block-of-HTML-code' );

// on click @ h3 ...
$('h3').click(function(e){
	//if(e.target != this) return; // @ this h3, even if has descendents, but not @ descendents
	if( e.target != this && $(this).has('a').length > 0 ) return; 
	// -- @ this h3, but not if @ child a --
	$(this).toggleClass('clear');
	// -- bug; next() failed here --
	$(this).nextAll('h3:first').toggleClass('clear');
	$(this).next('p.sample').toggle('fast');
	$(this).children('span').toggle();
	$(this).toggleClass('mute');			
});

// -- hover @ h3 --
$('h3').mouseover(function(e){
	if( e.target != this && $(this).has('a').length > 0 ) return; 
	// -- @ this h3, but not if @ child a --
	$(this).css('cursor','pointer');
	$(this).addClass('hover2');
});
$('h3').mouseout(function() {
	$(this).removeClass('hover2');
});	
