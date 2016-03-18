$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    google.charts.load('current', {packages: ['corechart']});
    google.charts.setOnLoadCallback(drawChart);

    function drawChart() {
      // Define the chart to be drawn.
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'created_at');
      data.addColumn('number', 'checkins');
      data.addRows(gon.chart_checkins);

      var options = {
        hAxis: { title: 'Date',  showTextEvery: 4 },
        vAxis: { title: 'Checkins' },
      };

      // Instantiate and draw the chart.
      var chart = new google.visualization.LineChart(document.getElementById('line-chart'));

      function selectHandler() {
        var selectedItem = chart.getSelection()[0];
        if (selectedItem) {
          var value = data.getValue(selectedItem.row, selectedItem.column);
          alert('The user selected ' + value);
        }
      }

      // Listen for the 'select' event, and call my function selectHandler() when
      // the user selects something on the chart.
      google.visualization.events.addListener(chart, 'select', selectHandler);
      chart.draw(data, options);
    }
  }
})
