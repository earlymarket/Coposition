$(document).on('page:change', function(){
  setup();
});

function setup() {
  addEventListeners();
};

function addEventListeners() {
  addClickListeners();
};



function addClickListeners() {
  $(".close").click(function(e){
    $(e.currentTarget).parent().hide(300);
  });
};