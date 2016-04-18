$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    COPO.permissions.setMasters('devices', gon.permissions);
    COPO.permissions.masterChange('devices', gon.permissions);
    COPO.permissions.switchChange('devices', gon.permissions);
    COPO.permissions.checkDisabled();
    COPO.permissions.checkBypass();
    COPO.slider.initSliders();
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

  }
})
