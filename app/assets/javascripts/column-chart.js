window.COPO = window.COPO || {};
window.COPO.charts = {
  drawChart: function() {
    // Define the chart to be drawn.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'created_at');
    data.addColumn('number', 'Checkins');
    data.addRows(gon.chart_checkins);
    var gap = Math.round(gon.chart_checkins.length/10)
    var options = {
      hAxis: { title: 'Date',  showTextEvery: gap },
      vAxis: { title: 'Checkins' },
    };

    // Instantiate and draw the chart.
    var chart = new google.visualization.ColumnChart(document.getElementById('line-chart'));

    function selectHandler() {
      var selectedItem = chart.getSelection()[0];
      if (selectedItem) {
        var splitDate = gon.chart_checkins[selectedItem.row][0].split("/");
        gon.table_checkins = [];
        if (splitDate.length === 3){
          var columnDate = new Date(splitDate[2], splitDate[1]-1, splitDate[0]);
          var startMSeconds = Date.parse(columnDate);
          var endMSeconds = startMSeconds + 86400000; //one day
          gon.checkins.forEach(function(e){
            var dateMSeconds = Date.parse(e.created_at);
            if (dateMSeconds >= startMSeconds && dateMSeconds <= endMSeconds){
              gon.table_checkins.push(e);
            }
          })
        } else if (splitDate.length ===2) {
          gon.checkins.forEach(function(e){
            var month = new Date(e.created_at).getMonth();
            var year = new Date(e.created_at).getFullYear().toString();
            if (splitDate[0]-1 == month && splitDate[1] == year.substr(year.length-2)){
              gon.table_checkins.push(e);
            }
          })
        }
        COPO.charts.drawTable();
      }
    }

    // Listen for the 'select' event, and call my function selectHandler() when
    // the user selects something on the chart.
    google.visualization.events.addListener(chart, 'select', selectHandler);
    chart.draw(data, options);
  },

  drawTable: function() {
    // Define the chart to be drawn.
    var tableData = [];
    gon.table_checkins.forEach(function(e){
      var humanizedDate = new Date(e.created_at).toLocaleDateString('en-GB')
      tableData.push([humanizedDate, e.fogged_area]);
    })
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Created');
    data.addColumn('string', 'Area');
    data.addRows(tableData);

    // Instantiate and draw the chart.
    var table = new google.visualization.Table(document.getElementById('table-chart'));
    var options = { width: '100%', height: '100%' }
    table.draw(data, options);
  }
}

