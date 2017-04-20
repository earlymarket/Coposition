$(document).on("page:change", function() {
  if (window.COPO.utility.currentPage("release_notes", "index")) {
  	let active = window.location.search.slice(13)
  	if (active.length) {
  		$("."+active).css("opacity", 1);
  	} else {
      $(".clear").css("display", "none");
      $(".web").css("opacity", 1);
      $(".api").css("opacity", 1);
      $(".mobile").css("opacity", 1);
    }
  }
})
