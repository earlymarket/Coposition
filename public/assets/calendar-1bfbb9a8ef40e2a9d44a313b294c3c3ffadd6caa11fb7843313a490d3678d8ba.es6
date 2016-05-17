window.COPO = window.COPO || {};
window.COPO.calendar = {

  drawChart(checkins, size) {
    const chart = new google.visualization.Calendar(document.getElementById('calendar'));
    const dataTable = new google.visualization.DataTable();
    dataTable.addColumn({ type: 'date', id: 'Date' });
    dataTable.addColumn({ type: 'number', id: 'Frequency' });
    const rowData = gon.checkins.map((day) =>[new Date(day[0]), day[1]]);;
    dataTable.addRows(rowData);
    const options = {
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
