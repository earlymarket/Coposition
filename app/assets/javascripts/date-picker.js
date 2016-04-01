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
    if ( from_picker.get('value') ) {
      date = new Date(moment(from_picker.get('value')).startOf('day'))
      to_picker.set('min', date)
    }
    if ( to_picker.get('value') ) {
      date = new Date(moment(to_picker.get('value')).endOf('day'))
      from_picker.set('max', date)
    }

    // When something is selected, update the “from” and “to” limits.
    from_picker.on('set', function(event){
      setLimits(event, to_picker, from_picker, 'min')
    })
    to_picker.on('set', function(event){
      setLimits(event, from_picker, to_picker, 'max')
    })

    function setLimits(event, beingSet, setter, limit){
      if ( event.select ) {
        beingSet.set(limit, setter.get('select'))
      }
      else if ( 'clear' in event ) {
        beingSet.set(limit, false)
      }
    }
  }
})
