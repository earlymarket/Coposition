$(document).on("page:change", function() {
  if (window.COPO.utility.currentPage("release_notes", "index")) {
    let application = window.location.search.split("=")[1]
    if (application) {
      $("." + application + ", .clear").addClass("active");  
    } else {
      $(".web, .api, .mobile").addClass("active");
      $(".clear").removeClass("active");
    }
  }
})
