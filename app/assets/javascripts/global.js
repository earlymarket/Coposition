$(document).on('page:change', function(){
  setup();
});

$(document).on('page:fetch', function() {
  utility.exitPage();
});


function setup() {
  utility.enterPage();
  addEventListeners();
};

function addEventListeners() {
  addClickListeners();
};



function addClickListeners() {
  $(".close").click(function(e){
    $(e.currentTarget).parent().addClass("flipOutX").slideUp(1000);
  });
};