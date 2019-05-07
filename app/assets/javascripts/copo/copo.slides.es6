window.COPO = window.COPO || {};
window.COPO.slides = {
  Timer (interval) {
    this.interval = interval;
    this.ping = function () {
      $(window.document).trigger({
        type: 'timer:ping',
        id: this.id
      })
    };
    this.id = setInterval(this.ping.bind(this), interval);
    this.stop = () => { clearInterval(this.id) };
    $(document).one('turbolinks:before-render', this.stop.bind(this) );
  }
};
