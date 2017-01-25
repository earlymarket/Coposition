window.COPO = window.COPO || {};
window.COPO.permissionsTrigger = {
  initTrigger: function(page){
    $('.permissions-trigger').leanModal()
    $('.permissions-trigger').on('click touchstart', function(){
      const DEVICE_ID = this.dataset.id;
      const $LIST = $(`.permissions[data-id=${DEVICE_ID}]`)
      if($LIST.children().length===1) {
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
