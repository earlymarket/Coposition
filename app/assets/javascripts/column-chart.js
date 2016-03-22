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
      colors: ['#47b8e0'],
      legend: {position: 'none'}
    };

    // Instantiate and draw the chart.
    var chart = new google.charts.Bar(document.getElementById('bar-chart'));

    function selectHandler() {
      if (chart.getSelection().length === 0){
        gon.table_checkins = gon.checkins;
      } else {
        var selectedItem = chart.getSelection()[0];
        if (selectedItem) {
          var splitColumnDate = gon.chart_checkins[selectedItem.row][0].split("/");
          gon.table_checkins = [];

          if (splitColumnDate.length === 3){
            var columnDate = new Date(splitColumnDate[2], splitColumnDate[1]-1, splitColumnDate[0]);
            gon.checkins.forEach(function(checkin){
              date = new Date(new Date(checkin.created_at).setHours(0,0,0,0));
              if (date.toString() === columnDate.toString()){
                gon.table_checkins.push(checkin);
              }
            })
          } else if (splitColumnDate.length ===2) {
            gon.checkins.forEach(function(checkin){
              var month = new Date(checkin.created_at).getMonth();
              var year = new Date(checkin.created_at).getFullYear().toString();
              if (month == splitColumnDate[0]-1 && year.substr(year.length-2) == splitColumnDate[1]){
                gon.table_checkins.push(checkin);
              }
            })
          }
        }
      }
      COPO.charts.drawTable();
    }

    // Listen for the 'select' event, and call my function selectHandler() when
    // the user selects something on the chart.
    google.visualization.events.addListener(chart, 'select', selectHandler);
    chart.draw(data, google.charts.Bar.convertOptions(options));
  },

  drawTable: function() {
    // Define the chart to be drawn.
    var tableData = [];
    gon.table_checkins.forEach(function(checkin){
      var humanizedDate = new Date(checkin.created_at).toLocaleDateString('en-GB');
      var foggedClass;
      checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
      var delete_button = COPO.utility.ujsLink('delete', '<i class="material-icons red-text right">delete_forever</i>' , window.location.pathname + '/checkins/' + checkin.id ).attr('data-confirm', 'Are you sure?').prop('outerHTML')
      var fogging_button = COPO.utility.ujsLink('put', '<i class="material-icons">cloud</i>' , window.location.pathname + '/checkins/' + checkin.id ).attr('id', 'fog' + checkin.id).attr('class', foggedClass).prop('outerHTML')
      tableData.push([humanizedDate, checkin.fogged_area, fogging_button, delete_button]);
    })
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Created');
    data.addColumn('string', 'Area');
    data.addColumn('string', 'Fogging');
    data.addColumn('string', '');
    data.addRows(tableData);

    // Instantiate and draw the chart.
    var table = new google.visualization.Table(document.getElementById('table-chart'));
    var options = { width: '100%', height: '250px', allowHtml: true }
    table.draw(data, options);
  }
}


