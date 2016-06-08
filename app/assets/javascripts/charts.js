/*eslint no-unused-expressions: [2, { allowTernary: true }]*/

window.COPO = window.COPO || {};
window.COPO.charts = {
  drawTable: function(checkins, page) {
    // Define the data for table to be drawn.
    var table_div = document.getElementById('table-chart');
    if (table_div){
      var tableData = [];
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Created');
      data.addColumn('string', 'Address');
      if(checkins.length > 0){
        (page === 'user') ? userTableData() : friendTableData();
      }
      // Instantiate and draw the chart.
      var table = new google.visualization.Table(table_div);
      var cssClassNames = { 'headerRow' : 'white' }
      var options = { width: '100%', allowHtml: true, cssClassNames: cssClassNames }
      table.draw(data, options);
    }

    function userTableData() {
      data.addColumn('string');
      checkins.forEach(function(checkin){
        var humanizedDate = moment(checkin.created_at).format('LLL');
        var foggedClass = checkin.fogged ?  'fogged enabled-icon' : ' disabled-icon';
        var delete_button = COPO.utility.deleteCheckinLink(checkin);
        var fogging_button = COPO.utility.fogCheckinLink(checkin, foggedClass, 'tableFog');
        tableData.push([
          humanizedDate,
          checkin.address === 'Not yet geocoded' ? COPO.utility.geocodeCheckinLink(checkin) : checkin.address,
          fogging_button + delete_button
        ])
      })
      data.addRows(tableData);
      data.setProperty(0, 0, 'style', 'width:20%');
      data.setProperty(0, 1, 'style', 'width:60%');
      data.setProperty(0, 2, 'style', 'width:10%');
    }

    function friendTableData() {
      checkins.forEach(function(checkin){
        var humanizedDate = moment(checkin.created_at).format('LLL');
        tableData.push([humanizedDate, checkin.address]);
      })
      data.addRows(tableData);
      data.setProperty(0, 0, 'style', 'width:30%');
      data.setProperty(0, 1, 'style', 'width:70%');
    }
  },

  refreshCharts: function(checkins, page){
    COPO.charts.drawTable(checkins, page);
  }
}
