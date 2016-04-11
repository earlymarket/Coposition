window.COPO = window.COPO || {};
window.COPO.slider = {

  initSliders: function(){
    $('.delay-slider').each(function(){
      var delaySlider = this;
      var device_id =  parseInt(delaySlider.dataset.device);
      var device = _.find(gon.devices, _.matchesProperty('id', device_id));

      noUiSlider.create(delaySlider, {
        start: [ device.delayed || 0 ],
        range: {
          'min': [ 0, 1 ],
          '25%': [ 10, 5 ],
          '50%': [ 60, 30 ],
          '75%': [ 360, 60 ],
          '90%': [ 720, 120 ],
          'max': [ 1440 ]
        },
        pips: {
          mode: 'values',
          values: [0,5,10,30,60,360,720,1440],
          density: 2,
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

    });
  },


 //  var delaySliderValueElement = document.getElementById('delay-slider-step-value')
 //  delaySlider.noUiSlider.on('update', function( values, handle ) {
 //    delaySliderValueElement.innerHTML = values[handle];
 //  })

}
