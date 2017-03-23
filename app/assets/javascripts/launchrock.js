//= require jquery
//= require vendor/velocity
//= require vendor/velocity.ui


$(document).ready(function() {
  // $("form").on("submit", function(e) {
  //   e.preventDefault();

  //   var form = $("form");
  //   $.ajax({
  //     type: "POST",
  //     url: form.attr("action"),
  //     data: form.serialize(), // serializes the form's elements.
  //     success: function(data)
  //     {
  //       $(".sign-up").velocity("transition.slideDownOut")
  //       $(".flash").velocity("transition.slideDownIn").velocity("callout.bounce");
  //     }
  //   });
  // });


  $(".feedback-enterprise").on("click", function(e) {
    if(typeof Intercom != "undefined") {
      e.preventDefault();
      Intercom("showNewMessage", "Hey! I have a lot of servers. Let's talk!")
    }
  });

  
  if ($('form#new_user').length > 0) {
    $("#forgot-password").on("click", function(e) {
      $("form#new_user #password_reset").val("true");
      $("form#new_user").submit();
    })
  }

});
