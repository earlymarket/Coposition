$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    google.charts.setOnLoadCallback(drawTable);

    function drawTable() {
      // Define the chart to be drawn.
      var tableData = [];
      gon.checkins.forEach(function(e){
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
})
