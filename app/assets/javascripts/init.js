window.jQuery = window.$ = require('jquery');
require('jquery-ujs');

$(document).ready(function() {
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
  })

});
