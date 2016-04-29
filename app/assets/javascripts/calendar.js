window.COPO = window.COPO || {};
window.COPO.calendar = {

  drawChart: function() {
    var checkins = gon.checkins;
    var dataTable = new google.visualization.DataTable();
    dataTable.addColumn({ type: 'date', id: 'Date' });
    dataTable.addColumn({ type: 'number', id: 'Won/Loss' });
    var rowData = countCheckinsByDate();
    debugger;
    dataTable.addRows(rowData);
    var chart = new google.visualization.Calendar(document.getElementById('calendar_basic'));
    var options = {
      title: "Red Sox Attendance",
      height: 350,
    };
    chart.draw(dataTable, options);

    function countCheckinsByDate() {
      var createdAt = _.map(checkins, 'created_at');
      var firstDate = moment(checkins[checkins.length-1].created_at).startOf('day');
      var daysDiff = moment(checkins[0].created_at).endOf('day').diff(firstDate, 'days');
      var monthsDiff = moment(checkins[0].created_at).endOf('day').diff(firstDate, 'months');
      var createdAtArr = [];
      createdAtArr = createdAtArray({diff: daysDiff, firstDate: firstDate, format: 'YYYY-MM-DD',
                                           increment: 'days', createdAt: createdAt});
      var countedDates = _.toPairs(_.countBy(createdAtArr));
      countedDates = _.map(countedDates, function(n){ return [n[0], _.subtract(n[1],1)] });
      return countedDates;
    }

    function createdAtArray(args) {
      createdAtArr = [];
      _.times(args.diff+1, function(){
        createdAtArr.push(new Date(args.firstDate.format(args.format)));
        args.firstDate = args.firstDate.add(1, args.increment);
      });
      _(args.createdAt).each(function(checkin){
        createdAtArr.push(new Date(moment(checkin).format(args.format)));
      });
      return createdAtArr;
    }
  }
}
