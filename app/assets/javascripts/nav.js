$(document).on('page:change', function() {
	$(".dropdown-button").dropdown({
		hover: true,
		belowOrigin: true
	});
	$(".button-collapse").sideNav();
	$('.collapsible').collapsible();
});