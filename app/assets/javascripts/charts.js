window.COPO = window.COPO || {};
window.COPO.charts = {
  data: null,

  drawBarChart: function(checkins) {
    // Define the data for the chart.
    var chart = new google.charts.Bar(document.getElementById('bar-chart'));
    data = new google.visualization.DataTable();
    data.addColumn('string', 'created_at');
    data.addColumn('number', 'Checkins');
    if (checkins){
      var rowData = countCheckinsByDate();
      data.addRows(rowData);
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
    chart.draw(data, google.charts.Bar.convertOptions(options));
    google.visualization.events.addListener(chart, 'select', selectHandler);

    function countCheckinsByDate() {
      var createdAt = _.map(checkins, 'created_at');
      var createdAtArr = [];
      var firstDate = moment(checkins[checkins.length-1].created_at);
      var daysDiff = moment(checkins[0].created_at).diff(firstDate, 'days');
      var monthsDiff = moment(checkins[0].created_at).diff(firstDate, 'months');
      if (monthsDiff > 2){ // by month
        _.times(monthsDiff+2, function(){
          createdAtArr.push(firstDate.format('YYYY-MM'));
          firstDate = firstDate.add(1, 'months');
        });
        _(createdAt).each(function(checkin){
          createdAtArr.push(moment(checkin).format('YYYY-MM'));
        });
      } else{ // by day
        _.times(daysDiff+2, function(){
          createdAtArr.push(firstDate.format('YYYY-MM-DD'));
          firstDate = firstDate.add(1, 'days');
        });
        _(createdAt).each(function(checkin){
          createdAtArr.push(moment(checkin).format('YYYY-MM-DD'));
        });
      }
      var countedDates = _.toPairs(_.countBy(createdAtArr));
      var dates = _.map(countedDates, function(n){ return [n[0], _.subtract(n[1],1)] });
      return dates;
    }

    function selectHandler() {
      if (chart.getSelection().length === 0){
        var table_checkins = checkins;
      } else {
        var selectedItem = chart.getSelection()[0];
        if (selectedItem) {
          var columnDate = data.getValue(selectedItem.row, 0);
          if (columnDate.length === 10){
            var table_checkins = table_checkins(columnDate, 'YYYY-MM-DD');
          } else if (columnDate.length === 7) {
            var table_checkins = table_checkins(columnDate, 'YYYY-MM');
          }
        }
      }
      COPO.charts.drawTable(table_checkins);
    }

    function table_checkins(columnDate, format) {
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
  }
}
