$(document).ready(function() {

  // initialize card.js for billing page
  if($("#payment-form .card-wrapper").length > 0) {
    require('card/lib/js/card.js');
    var card_form = new Card({form: '#payment-form', container: ".card-wrapper"})
  }


  // bind to payment form

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

    // disable form elements we should not be submitting.
    $form.find("input.form-control").attr("disabled", true)

    // and submit
    $form.get(0).submit();
  }
};

