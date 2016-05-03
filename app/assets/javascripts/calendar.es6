window.COPO = window.COPO || {};
window.COPO.calendar = {

  drawChart(checkins, size) {
    let chart = new google.visualization.Calendar(document.getElementById('calendar'));
    let dataTable = new google.visualization.DataTable();
    dataTable.addColumn({ type: 'date', id: 'Date' });
    dataTable.addColumn({ type: 'number', id: 'Frequency' });
    let rowData = countCheckinsByDate();
    dataTable.addRows(rowData);
    let options = {
      title: "Checkin frequency",
      calendar: {
        cellSize: size,
        monthOutlineColor: {
          stroke: 'grey',
          strokeOpacity: 0.8,
          strokeWidth: 1.5
        },
      },
      colorAxis: {colors:['white','orange']},
    };

    chart.draw(dataTable, options);

    function countCheckinsByDate() {
      let createdAt = _.map(checkins, 'created_at');
      let createdAtArr = [];
      _(createdAt).each(function(checkin){
        createdAtArr.push(moment(checkin).endOf('day'));
      });
      let countedDates = _.toPairs(_.countBy(createdAtArr));
      countedDates = countedDates.map(function(n){ return [new Date(n[0]), n[1]] });
      return countedDates;
    }
  },

  refreshCalendar(checkins){
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
