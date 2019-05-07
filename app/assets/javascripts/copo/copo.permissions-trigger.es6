window.COPO = window.COPO || {};
window.COPO.permissionsTrigger = {
  initTrigger(page) {
    $('.permissions-trigger').modal();
    $('.permissions-trigger').on('click touchstart', function(){
      const DATA_ID = this.dataset.id;
      const $LIST = $(`.permissions[data-id=${DATA_ID}]`)
      if($LIST.children().length===1) {
        const FROM = { from: page }
        $LIST.append('<div class="progress"><div class="indeterminate"></div></div>');
        $.get({
          url: `devices/${DATA_ID}/permissions`,
          data: FROM,
          dataType: "script"
        });
      }
    })
  }
}
