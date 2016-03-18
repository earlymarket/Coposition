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
        hAxis: {
          title: 'Date'
        },
        vAxis: {
          title: 'Checkins'
        }
      };

      // Instantiate and draw the chart.
      var chart = new google.visualization.LineChart(document.getElementById('myPieChart'));
      chart.draw(data, options);
    }
  }
})
