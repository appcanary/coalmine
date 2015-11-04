window.jQuery = window.$ = require('jquery');
require('jquery-ujs');

$(document).ready(function() {
    $('#payment-form').submit(function(event) {
      var $form = $(this);

      // Disable the submit button to prevent repeated clicks
      $form.find('button').prop('disabled', true);

      var card = {}
      $form.find('[data-stripe]').each(function(i, e) {
        var elem = $(e);
        card[elem.data("stripe")] = elem.val()
      })

      var expiry = $form.find("[name=expiry]").val().split("/").map(function(e) { return $.trim(e) })
      card["exp_month"] = expiry[0];
      card["exp_year"] = expiry[1];

      Stripe.card.createToken(card, stripeResponseHandler);

      // Prevent the form from submitting with the default action
      return false;
    });
});


function stripeResponseHandler(status, response) {
  var $form = $('#payment-form');

  if (response.error) {
    // Show the errors on the form
    $form.find('.payment-errors').css("display", "block");
    $form.find('.payment-errors').text(response.error.message);
    $form.find('button').prop('disabled', false);
  } else {
    // response contains id and card, which contains additional card details
    var token = response.id;
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="user[stripe_token]" />').val(token));
    // and submit
    $form.get(0).submit();
  }
};

$(document).ready(function() {


  if($("#payment-form .card-wrapper").length > 0) {
    require('card');
    var card_form = new Card({form: '#payment-form', container: ".card-wrapper"})
  }

  $(".feedback").on("click", function(e) {
    e.preventDefault();
    if(typeof Intercom != "undefined") {
      Intercom("showNewMessage")
    }
  });

  $(".feedback-else").on("click", function(e) {
    e.preventDefault();
    if(typeof Intercom != "undefined") {
      Intercom("showNewMessage", "Cool. Let us know in this box and we'll get in touch.")
    }
  });

  $(".feedback-problem").on("click", function(e) {
    e.preventDefault();
    if(typeof Intercom != "undefined") {
      Intercom("showNewMessage", "Sorry to hear that. Describe your problem in this box and we'll get in touch.")
    }
  });

});
