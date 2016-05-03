window.COPO = window.COPO || {};
window.COPO.calendar = {

  drawChart: function(checkins, size) {
    var dataTable = new google.visualization.DataTable();
    dataTable.addColumn({ type: 'date', id: 'Date' });
    dataTable.addColumn({ type: 'number', id: 'Won/Loss' });
    var rowData = countCheckinsByDate();
    dataTable.addRows(rowData);
    var chart = new google.visualization.Calendar(document.getElementById('calendar_basic'));
    var options = {
      title: "Checkin frequency",
      calendar: { cellSize: size },
      colorAxis: {colors:['white','orange']},
      noDataPattern: {
        backgroundColor: '',
        color: ''
      }
    };
    chart.draw(dataTable, options);

    function countCheckinsByDate() {
      var createdAt = _.map(checkins, 'created_at');
      var firstDate = moment().startOf('year');
      var daysDiff = moment(Date.now()).endOf('day').diff(firstDate, 'days');
      var createdAtArr = [];
      createdAtArr = createdAtArray({diff: daysDiff, firstDate: firstDate, format: 'YYYY-MM-DD',
                                           increment: 'days', createdAt: createdAt});
      var countedDates = _.toPairs(_.countBy(createdAtArr));
      countedDates = _.map(countedDates, function(n){ return [new Date(n[0]), _.subtract(n[1],1)] });
      return countedDates;
    }

    function createdAtArray(args) {
      createdAtArr = [];
      _.times(args.diff+1, function(){
        createdAtArr.push(new Date(moment(args.firstDate).endOf('day')));
        args.firstDate = args.firstDate.add(1, args.increment);
      });
      _(args.createdAt).each(function(checkin){
        createdAtArr.push(new Date(moment(checkin).endOf('day')));
      });
      return createdAtArr;
    }
  },

  refreshChart: function(checkins){
    let cellsize = null;
    if (window.innerWidth < 1000) {
      cellsize = window.innerWidth/70;
    } else if (window.innerWidth < 1500){
      cellsize = window.innerWidth/85;
    } else {
      cellsize = 18;
    }
    COPO.calendar.drawChart(checkins, cellsize);
  }
}
