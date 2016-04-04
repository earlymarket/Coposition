$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    window.initPage = function(){
      $('.clip_button').off();
      COPO.utility.initClipboard('.clip_button', function(){
        $('.material-tooltip').children('span').text('Copied');
      });
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
