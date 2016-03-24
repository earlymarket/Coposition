window.COPO = window.COPO || {};
window.COPO.charts = {
  barChartData: null,

  drawBarChart: function(checkins) {
    // Define the data for the chart.
    var chart = new google.charts.Bar(document.getElementById('bar-chart'));
    barChartData = new google.visualization.DataTable();
    barChartData.addColumn('string', 'created_at');
    barChartData.addColumn('number', 'Checkins');
    if (checkins){
      var rowData = countCheckinsByDate();
      barChartData.addRows(rowData);
      var gap = Math.round(rowData.length/10);
    }
    var options = {
      hAxis: { title: 'Date',  showTextEvery: gap },
      vAxis: { title: 'Checkins' },
      colors: '#47b8e0',
      legend: {position: 'none'}
    };

    // Listen for the 'select' event, and call my function selectHandler() when
    // the user selects something on the chart.
    chart.draw(barChartData, google.charts.Bar.convertOptions(options));
    google.visualization.events.addListener(chart, 'select', selectHandler);

    function countCheckinsByDate() {
      var createdAt = _.map(checkins, 'created_at');
      var firstDate = moment(checkins[checkins.length-1].created_at).startOf('day');
      var daysDiff = moment(checkins[0].created_at).endOf('day').diff(firstDate, 'days');
      var monthsDiff = moment(checkins[0].created_at).endOf('day').diff(firstDate, 'months');
      var createdAtArr = []
      if (monthsDiff > 2){ // by month
        createdAtArr = createdAtArray({diff: monthsDiff,firstDate: firstDate, format: 'YYYY-MM',
                                           increment: 'months', createdAt: createdAt})
      } else{ // by day
        createdAtArr = createdAtArray({diff: daysDiff,firstDate: firstDate, format: 'YYYY-MM-DD',
                                           increment: 'days', createdAt: createdAt})
      }
      var countedDates = _.toPairs(_.countBy(createdAtArr));
      var dates = _.map(countedDates, function(n){ return [n[0], _.subtract(n[1],1)] });
      return dates;
    }

    function createdAtArray(args) {
      createdAtArr = [];
      _.times(args.diff+1, function(){
        createdAtArr.push(args.firstDate.format(args.format));
        args.firstDate = args.firstDate.add(1, args.increment);
      });
      _(args.createdAt).each(function(checkin){
        createdAtArr.push(moment(checkin).format(args.format));
      });
      return createdAtArr;
    }

    function selectHandler() {
      if (chart.getSelection().length === 0){
        var table_checkins = checkins;
      } else {
        var selectedItem = chart.getSelection()[0];
        if (selectedItem) {
          var columnDate = barChartData.getValue(selectedItem.row, 0);
          var table_checkins = [];
          if (columnDate.length === 10){
            table_checkins = checkins_for_table(columnDate, 'YYYY-MM-DD');
          } else if (columnDate.length === 7) {
            table_checkins = checkins_for_table(columnDate, 'YYYY-MM');
          }
        }
      }
      COPO.charts.drawTable(table_checkins);
    }

    function checkins_for_table(columnDate, format) {
      var table_checkins = [];
      checkins.forEach(function(checkin){
        var date = moment(checkin.created_at).format(format);
        if (date === columnDate){
          table_checkins.push(checkin);
        }
      })
      return table_checkins;
    }
  },

  drawTable: function(checkins) {
    // Define the data for table to be drawn.
    var tableData = [];
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Created');
    data.addColumn('string', 'Area');
    data.addColumn('string', 'Fogging');
    data.addColumn('string');
    if(checkins.length > 0){
      checkins.forEach(function(checkin){
        var humanizedDate = moment(checkin.created_at).format('YYYY-MM-DD');
        var foggedClass;
        checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
        var delete_button = COPO.utility.ujsLink('delete',
          '<i class="material-icons center red-text">delete_forever</i>' ,
          window.location.pathname + '/checkins/' + checkin.id )
          .attr('data-confirm', 'Are you sure?')
          .prop('outerHTML')
        var fogging_button = COPO.utility.ujsLink('put',
          '<i class="material-icons center">cloud</i>' ,
          window.location.pathname + '/checkins/' + checkin.id )
          .attr('id', 'tableFog' + checkin.id).attr('class', foggedClass)
          .prop('outerHTML')
        tableData.push([humanizedDate, checkin.fogged_area, fogging_button, delete_button]);
      })
      data.addRows(tableData);
      data.setProperty(0, 0, 'style', 'width:20%');
      data.setProperty(0, 1, 'style', 'width:60%');
      data.setProperty(0, 2, 'style', 'width:10%');
      data.setProperty(0, 3, 'style', 'width:10%');
    }
    // Instantiate and draw the chart.
    var table = new google.visualization.Table(document.getElementById('table-chart'));
    var cssClassNames = { 'headerRow' : 'primary-color' }
    var options = { width: '100%', allowHtml: true, cssClassNames: cssClassNames }
    table.draw(data, options);
  },

  refreshCharts: function(checkins){
    COPO.charts.drawBarChart(checkins);
    COPO.charts.drawTable(checkins);
  }
}
