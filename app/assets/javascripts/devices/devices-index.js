$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    COPO.permissions.switch_change();
    COPO.permissions.check_disabled();
    window.initPage = function(){
      $('.clip_button').off();
      COPO.utility.initClipboard();
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 50});
      $('.linkbox').off();
      $('.linkbox').on('click', function(e){
        this.select()
      })
    }
    initPage();
  }
})
