$(document).on("page:change", function() {
  if (window.COPO.utility.currentPage("release_notes", "index")) {
    let application = RegExp("[?&]application=([^&]*)").exec(window.location.search);
    if (application) {
      $("." + application[1] + ", .clear").addClass("active");  
    } else {
      $(".web, .api, .mobile").addClass("active");
      $(".clear").removeClass("active");
    }
  }
});
