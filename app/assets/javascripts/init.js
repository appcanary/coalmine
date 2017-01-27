window.jQuery = window.$ = require('jquery');
require('jquery-ujs');
require('bootstrap/dist/js/bootstrap.js');
require("./internal/payment_handling.js")
require("./internal/highlighting.js")


$(document).ready(function() {

 
  $(".feedback").on("click", function(e) {
    if(typeof Intercom != "undefined") {
      e.preventDefault();
      Intercom("showNewMessage")
    }
  });

  $(".feedback-else").on("click", function(e) {
    if(typeof Intercom != "undefined") {
      e.preventDefault();
      Intercom("showNewMessage", "Cool. Let us know in this box and we'll get in touch.")
    }
  });

  $(".feedback-problem").on("click", function(e) {
    if(typeof Intercom != "undefined") {
      e.preventDefault();
      Intercom("showNewMessage", "Sorry to hear that. Describe your problem in this box and we'll get in touch.")
    }
  });

});
