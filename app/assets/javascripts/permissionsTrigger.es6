window.COPO = window.COPO || {};
window.COPO.permissionsTrigger = {
  initTrigger: function(page){
    $('.permissions-trigger').leanModal()
    $('.permissions-trigger').on('click touchstart', function(){
      const device = this.dataset.device;
      const $LIST = $(`.permissions[data-device=${device}]`)
      // const $LIST = $(this.parentElement).find('.permissions')
      if($LIST.children().length===1) {
        const DEVICE_ID = page === 'devices' ? $LIST.data().device : $LIST.data().friend;
        const FROM = { from: page }
        $LIST.append('<div class="progress"><div class="indeterminate"></div></div>');
        $.get({
          url: `devices/${DEVICE_ID}/permissions`,
          data: FROM,
          dataType: "script"
        });
      }
    })
  }
}
