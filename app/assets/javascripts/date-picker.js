$(document).on('ready page:change', function() {
  if ($(".c-devices.a-show").length === 1) {

    // materialize datepicker init
    $('.datepicker').pickadate({
      selectMonths: true,
      selectYears: 15,
      onSet: function( arg ){
        if ( 'select' in arg ){ //prevent closing on selecting month/year
          this.close();
        }
      }
    });

    var from_$input = $('#input_from').pickadate(),
        from_picker = from_$input.pickadate('picker')

    var to_$input = $('#input_to').pickadate(),
        to_picker = to_$input.pickadate('picker')


    // Check if there’s a “from” or “to” date to start with.
    COPO.datePicker.checkPickers(to_picker, from_picker, 'min')
    COPO.datePicker.checkPickers(from_picker, to_picker, 'max')

    // When something is selected, update the “from” and “to” limits.
    from_picker.on('set', function(event){
      COPO.datePicker.setLimits(event, to_picker, from_picker, 'min')
    })
    to_picker.on('set', function(event){
      COPO.datePicker.setLimits(event, from_picker, to_picker, 'max')
    })
  }
})

window.COPO = window.COPO || {};
window.COPO.datePicker = {

  setLimits: function(event, beingSet, setter, limit){
    if ( event.select ) {
      beingSet.set(limit, setter.get('select'))
    }
    else if ( 'clear' in event ) {
      beingSet.set(limit, false)
    }
  },

  checkPickers: function(beingSet, setter, limit){
    if (setter.get('value')) {
      beingSet.set(limit, new Date(moment(setter.get('value'))))
    }
  }
}
