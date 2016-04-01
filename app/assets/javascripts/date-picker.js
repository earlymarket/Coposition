$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {

    // materialize datepicker init
    $('.datepicker').pickadate({
      selectMonths: true,
      selectYears: 15,
      onSet: function( arg ){
        var from_picker = $('#input_from').pickadate().pickadate('picker')
        var to_picker = $('#input_to').pickadate().pickadate('picker')
        beingSet = this.component.$node[0].name;
        if ( beingSet === 'from'){
          COPO.datePicker.setLimits(arg, to_picker, from_picker, 'min')
        } else if ( beingSet === 'to'){
          COPO.datePicker.setLimits(arg, from_picker, to_picker, 'max')
        }
        if ( 'select' in arg ){ //prevent closing on selecting month/year
          this.close();
        }
      }
    });

    var from_picker = $('#input_from').pickadate().pickadate('picker')
    var to_picker = $('#input_to').pickadate().pickadate('picker')

    // Check if there’s a “from” or “to” date to start with.
    COPO.datePicker.checkPickers(to_picker, from_picker, 'min')
    COPO.datePicker.checkPickers(from_picker, to_picker, 'max')

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
