$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {

    $('.tooltipped').tooltip({delay: 50});

    $('.linkbox').on('click', function(e){
      this.select()
    })

    var client = new ZeroClipboard( $('.clip_button') );

    client.on( 'ready', function(event) {
       // console.log( 'movie is loaded' );

      client.on( 'copy', function(event) {
        event.clipboardData.setData('text/plain', event.target.value);
      });

      client.on( 'aftercopy', function(event) {
        Materialize.toast('Copied', 2000);
      });

    });

    client.on( 'error', function(event) {
     console.log( 'ZeroClipboard error of type "' + event.name + '": ' + event.message );
     ZeroClipboard.destroy();
    });
  }
})
