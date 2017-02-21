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