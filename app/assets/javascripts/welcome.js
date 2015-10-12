$(document).on('page:change',function() {

    var chart = c3.generate({
      data: {
        columns: [
          ['speed', -30, 200, 200, 400, -150, 250],
          ['temperature', 130, 100, -100, 200, -150, 50],
          ['altitude', -230, 200, 200, -300, 250, 250]
        ],
        type: 'bar',
        groups: [
          ['speed', 'temperature']
        ]
      },
      grid: {
        y: {
          lines: [{value:0}]
        }
      }
    });

  setInterval(function() {

    setTimeout(function () {
      chart.groups([['speed', 'temperature', 'altitude']])
    }, 1000);

    setTimeout(function () {
      chart.load({
        columns: [['frequency', 100, -50, 150, 200, -300, -100]]
      });
    }, 1500);

    setTimeout(function () {
      chart.groups([['speed', 'temperature', 'altitude', 'frequency']])
    }, 2000);
  }, 5000)


})