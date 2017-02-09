$(document).ready(function() {

  // if, for whatever reason, Intercom isn't loading,
  // default to sending us an email per the a href buttons.
  if(typeof Intercom != "undefined") {
    $(".feedback").on("click", function(e) {
      e.preventDefault();
      Intercom("showNewMessage")
    });

    $(".feedback-else").on("click", function(e) {
      e.preventDefault();
      Intercom("showNewMessage", "Cool. Let us know in this box and we'll get in touch.")
    });

    $(".feedback-problem").on("click", function(e) {
      e.preventDefault();
      Intercom("showNewMessage", "Sorry to hear that. Describe your problem in this box and we'll get in touch.")
    });
  }
});
