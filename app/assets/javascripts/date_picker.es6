window.COPO = window.COPO || {};
window.COPO.datePicker = {

  init: function() {
    $('.datepick').datepicker({
      selectMonths: true,
      selectYears: 15,
      onSet: function(arg) {
        var from_picker = $('#input_from').datepicker()
        var to_picker = $('#input_to').datepicker()
        var selectedPicker = this.component.$node[0].name;
        if (selectedPicker === 'from') {
          COPO.datePicker.setLimits(arg, to_picker, from_picker, 'min')
        } else if (selectedPicker === 'to') {
          COPO.datePicker.setLimits(arg, from_picker, to_picker, 'max')
        }
        if ('select' in arg) { //prevent closing on selecting month/year
          this.close();
        }
      }
    });
    let from_picker = $('#input_from').datepicker()
    let to_picker = $('#input_to').datepicker()
    // Check if there’s a “from” or “to” date to start with.
    COPO.datePicker.checkPickers(to_picker, from_picker, 'min')
    COPO.datePicker.checkPickers(from_picker, to_picker, 'max')
    COPO.datePicker.checkPickers(to_picker, to_picker, 'select')
    COPO.datePicker.checkPickers(from_picker, from_picker, 'select')
  },

  setLimits: function(event, beingSet, setter, limit) {
    if (event.select) {
      beingSet.set(limit, setter.get('select'))
    }
    else if ('clear' in event) {
      beingSet.set(limit, false)
    }
  },

  checkPickers: function(beingSet, setter, limit) {
    if (setter.get('value')) {
      let dateArray = setter.get('value').split(" ");
      let date = new Date(dateArray[1].replace(/\D/g,'') + " " + dateArray[2] + " " + dateArray[3])
      beingSet.set(limit, date)
    }
  },

  openIfSet: function(picker) {
    if (picker.get('value')) {
      $('#date-range-toggle').click()
    }
  }
}
