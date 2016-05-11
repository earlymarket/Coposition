$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    COPO.utility.gonFix();
    COPO.permissions.initSwitches('devices', gon.current_user_id, gon.permissions)
    COPO.delaySlider.initSliders(gon.devices);
    window.initPage = function(){
      $('.clip_button').off();
      COPO.utility.initClipboard();
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 50});
      $('.linkbox').off('touchstart click');

      $('.linkbox').on('click', function(e){
        this.select()
      })

      //backup for iOS
      $('.linkbox').on('touchstart', function(){
        this.focus();
        this.setSelectionRange(0, $(this).val().length);
      })

      $('.linkbox').each(function(i,linkbox){
        $(linkbox).attr('size', $(linkbox).val().length)
      })
    }
    initPage();

    $(document).on('page:before-unload', function(){
      $(".permission-switch").off("change");
      $(".master").off("change");
    })
  }
})
