window.COPO = window.COPO || {};
window.COPO.permissionsTrigger = {
  initTrigger: function(page){
    $('.permissions-trigger').leanModal()
    $('.permissions-trigger').on('click touchstart', function(){
      var $list = $(this.parentElement).find('.permissions')
      if($list.children().length===1) {
        var device_id = page === 'devices' ? $list.data().device : $list.data().friend;
        var originator = { from: page }
        $list.append('<div class="progress"><div class="indeterminate"></div></div>');
        $.get({
          url: `devices/${device_id}/permissions`,
          data: originator,
          dataType: "script"
        });
      }
    })
  }
}
