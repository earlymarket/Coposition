$(document).on('page:change', function() {
  var checkinData =  {
    x: 'x',
    columns: [
      ['x', '2013-01-01', '2013-01-02', '2013-01-03', '2013-01-04', '2013-01-05', '2013-01-06'],
      ['device-1', 30, 200, 100, 400, 150, 250],
      ['device-2', 50, 20, 10, 40, 15, 25]
    ],

    type: 'bar',

    groups: [
      ['device-1', 'device-2']
    ]
  };

  var checkinAxes = {
    y: {
      label: {
        text: 'Check-ins',
        position: 'outer-middle'
      }
    },

    x: {
      type: 'timeseries',
      tick: {
          format: '%m/%d'
      },
      label: {
        text: 'Dates',
        position: 'outer-center'
      }
    }
  };

  var dailyCheckins = c3.generate({
    bindto: '#dashboard-charts #daily-checkins div',
    data: checkinData,
    axis: checkinAxes,
    bar: {
      width: {
        ratio: 0.9
      }
    },
    zoom: {
      enabled: true
    },
    color: {
        pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
    }
  });


  checkinData.type = 'pie';
  var checkinRatio = c3.generate({
    bindto: '#dashboard-charts #checkin-ratio div',
    data: checkinData,
    color: {
        pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
    }
  });
});