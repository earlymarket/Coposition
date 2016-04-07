$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    COPO.permissions.switch_change();
    COPO.permissions.check_disabled();
    window.initPage = function(){
      $('.clip_button').off();
      COPO.utility.initClipboard();
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 50});
      $('.linkbox').off('touchstart click');
      $('.linkbox').on('touchstart click', function(e){
        this.select()
      })
      $('.linkbox').each(function(i,linkbox){
        $(linkbox).attr('size', $(linkbox).val().length)
      })
    }
    initPage();
  }
})
