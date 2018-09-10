function submitRecaptchaForm(e) {
  $('button.btn').removeClass("disabled");
};

$(document).on('page:change', function () {
  if (window.COPO.utility.currentPage('registrations', 'new')) {
    window.COPO.utility.setActivePage('Log In');
    $.validator.methods.email = function (value, element) {
      return this.optional(element) || /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/.test(value);
    };

    if (['test', 'staging'].indexOf($('body').attr('data-environment')) > -1) {
      $('button.btn').removeClass("disabled");
    }

    let resource_name = window.location.pathname.includes("user") ? "user" : "developer"
    let elements = {
      email: `${resource_name}[email]`,
      email_confirmation: `${resource_name}[email_confirmation]`,
      password: `${resource_name}[password]`,
      password_confirmation: `${resource_name}[password_confirmation]`,
      company_name: `${resource_name}[company_name]`,
      redirect_url: `${resource_name}[redirect_url]`, 
      username: `${resource_name}[username]`
    }

    $("#new_" + resource_name).validate({
      onkeyup: false,
      rules: {
        [elements.email]: {
          required: true
        },
        [elements.email_confirmation]: {
          required: true,
          equalTo: '" + resource_name + "_email'
        },
        [elements.password]: {
          required: true,
          minlength: 8
        },
        [elements.password_confirmation]: {
          required: true,
          equalTo: '" + resource_name + "_password'
        },
        [elements.company_name]: {
          required: window.location.pathname.includes("developer"),
        },
        [elements.redirect_url]: {
          required: window.location.pathname.includes("developer"),
          url: true
        },
        [elements.username]: {
          required: window.location.pathname.includes("user"),
          minlength: 4,
          maxlength: 20
        }
      },
      errorElement: "div",
      errorPlacement: function errorPlacement(error, element) {
        var placement = $(element).data("error");
        if (placement) {
          $(placement).append(error);
        } else {
          error.insertAfter(element);
        }
      },
      errorClass: "invalid",
      validClass: "valid"
    });
  }
});
