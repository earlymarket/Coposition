$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    google.charts.load('current', {packages: ['corechart']});
    google.charts.setOnLoadCallback(drawChart);

    function drawChart() {
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
          console.log(gon.chart_checkins[selectedItem.row])
          debugger;
          // var checkins = []
          // gon.checkins.each(function(e){
          //   if (new Date(this).toLocaleDateString('en-GB')===gon.chart_checkins[selectedItem.row])
          //     checkins += this
          //   end
          // })
          // datestring = new Date(gon.checkins[0].created_at);
          // datestring.toLocaleDateString('en-GB');
          //
        }
      }

      // Listen for the 'select' event, and call my function selectHandler() when
      // the user selects something on the chart.
      google.visualization.events.addListener(chart, 'select', selectHandler);
      chart.draw(data, options);
    }
  }
})
