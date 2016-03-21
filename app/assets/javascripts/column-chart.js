$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    google.charts.load('current', {packages: ['corechart', 'table']});
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
          console.log(gon.chart_checkins[selectedItem.row]);
          var splitDate = gon.chart_checkins[selectedItem.row][0].split("/");
          var columnDate = new Date(splitDate[2], splitDate[1] - 1, splitDate[0]);
          var weekStartMSeconds = Date.parse(columnDate);
          var weekEndMSeconds = weekStartMSeconds + 604800000;
          var weekEndDate = new Date(weekEndMSeconds);
          var checkins = [];
          gon.checkins.forEach(function(e){
            var dateMSeconds = Date.parse(e.created_at);
            if (dateMSeconds >= weekStartMSeconds && dateMSeconds <= weekEndMSeconds){
              checkins.push(e);
            }
          })
          gon.checkins = checkins;
          drawTable();
          //$.ajax({
          //  url: "/users/"+gon.current_user_id+"/devices/"+gon.device_id+"",
          //  type: 'GET',
          //  data: { from: columnDate, to: weekEndDate }
          //});
          // ajax vv
          // $('#checkin-table-body').html("<%= j (render partial: 'checkin_table_row', collection: checkins, as: :checkin).html_safe %>")
        }
      }

      // Listen for the 'select' event, and call my function selectHandler() when
      // the user selects something on the chart.
      google.visualization.events.addListener(chart, 'select', selectHandler);
      chart.draw(data, options);
    }
  }
})
