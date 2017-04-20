$(document).on("page:change", function() {
  if (window.COPO.utility.currentPage("release_notes", "index")) {
    let application = window.location.search.split("=")[1]
    if (application) {
      $("." + application).css("opacity", 1);
    } else {
      $(".clear").css("display", "none");
      $(".web, .api, .mobile").css("opacity", 1);
    }
  }
})
