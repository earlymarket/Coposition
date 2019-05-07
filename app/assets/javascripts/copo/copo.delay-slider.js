window.COPO = window.COPO || {};
window.COPO.delaySlider = {

  initSliders: function(devices){
    $('.delay-slider').each(function(){
      if(!this.noUiSlider){
        var delaySlider = this;
        var device_id =  parseInt(delaySlider.dataset.device, 10);
        var device = _.find(devices, _.matchesProperty('id', device_id));

        noUiSlider.create(delaySlider, {
          start: [ device.delayed ],
          range: {
            'min': [ 0, 5 ],
            '50%': [ 5, 1435 ],
            'max': [ 1440 ]
          },
          pips: {
            mode: 'values',
            values: [0,5,1440],
            density: 100,
            stepped:true
          },
          format: wNumb({
            decimals: 0
          })
        });

        delaySlider.noUiSlider.on('change', function(){
          var delayed = delaySlider.noUiSlider.get();
          device.delayed = delayed;
          $.ajax({
            url: "/users/"+device.user_id+"/devices/"+device_id,
            type: 'PUT',
            data: { delayed: delayed }
          });
        });
      }
    });

    $('.noUi-value.noUi-value-horizontal.noUi-value-large').each(function(){
      var val = $(this).html();
      val = COPO.delaySlider.recountVal(val);
      $(this).html(val);
    });
  },

  recountVal: function(val){
    switch(val){
      case '0': return 'Off';
      case '5': return '5 min';
      case '1440': return '1 day';
      default: return val;
    }
  }
}
