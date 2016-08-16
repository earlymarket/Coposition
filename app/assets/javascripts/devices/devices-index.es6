$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    var U = COPO.utility;
    const M  = window.COPO.maps;
    const P = window.COPO.permissionsTrigger;
    M.initMap();
    M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
    U.gonFix();
    P.initTrigger('devices');
    COPO.permissions.initSwitches('devices', gon.current_user_id, gon.permissions)
    COPO.delaySlider.initSliders(gon.devices);
    gon.checkins.length ? COPO.maps.initMarkers(gon.checkins) : $('#map-overlay').removeClass('hide');

    $('.fogButton').each((index, fogButton) => {
      if(!$(fogButton).data('fogged')){
        $(fogButton).removeData('confirm').removeAttr('data-confirm')
      }
    })

    $('body').on('click', '.edit-button', function (e) {
      e.preventDefault();
      $(this).toggleClass('hide', true);
      makeEditable($(this).prev('span'), handleEdited);
    });

    $('.modal-trigger').leanModal();

    $('.locate').on('click', function() {
      const device_id = this.dataset.device;
      const checkin = gon.checkins.find((checkin) => checkin.device_id.toString() === device_id);
      if(checkin) M.centerMapOn(checkin.lat, checkin.lng);
    });

    var makeEditable = function ($target, handler) {
      var original = $target.text();
      $target.attr('contenteditable', true);
      $target.focus();
      document.execCommand('selectAll', false, null);
      $target.on('blur', function () {
        handler(original, $target);
      });
      $target.on('keydown', function (e) {
        if(e.which === 27 || e.which === 13 ) {
          handler(original, $target);
        }
      });
      $target.on('click', function (e) {
        e.preventDefault();
      });
      return $target;
    }

    var handleEdited = function (original, $target) {
      var newName = $target.text()
      if(original !== newName) {
        console.log('Name optimistically set to: ' + $target.text());
        var url = $target.parents('a').attr('href');
        var request = $.ajax({
          dataType: 'json',
          url: url,
          type: 'PUT',
          data: { name: newName }
        });

        request
        .done(function (response) {
          console.log('Server processed the request');
        })
        .fail(function (error) {
          $target.text(original);
          try {
            Materialize.toast('Name: ' + JSON.parse(error.responseText).name, 3000, 'red');
          }
          catch (e) {
            console.log(error);
            Materialize.toast('Error changing names', 3000, 'red');
          }
        })
      }
      $target.text($target.text());
      $target.attr('contenteditable', false);
      $target.next().toggleClass('hide', false);
      U.deselect();
      $target.off();
    }

    window.initPage = function(){
      $('.clip_button').off();
      U.initClipboard();
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
      COPO.permissions.switchesOff();
      $(window).off("resize");
      $('body').off('click', '.edit-button');
    })
  }
})
