//= require jquery
//= require vendor/velocity
//= require vendor/velocity.ui


$(document).ready(function() {
  $("form").on("submit", function(e) {
    e.preventDefault();

    var form = $("form");
    $.ajax({
      type: "POST",
      url: form.attr("action"),
      data: form.serialize(), // serializes the form's elements.
      success: function(data)
      {
        $(".sign-up").velocity("transition.slideDownOut")
        $(".flash").velocity("transition.slideDownIn").velocity("callout.bounce");
      }
    });
  });


  $(".feedback-enterprise").on("click", function(e) {
    e.preventDefault();
    if(typeof Intercom != "undefined") {
      Intercom("showNewMessage", "Hey! I have a lot of servers. Let's talk!")
    }
  });

});
