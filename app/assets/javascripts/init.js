window.jQuery = window.$ = require('jquery');
require('jquery-ujs');

$(document).ready(function() {
  $(".feedback").on("click", function(e) {
    e.preventDefault();
    if(typeof Intercom != "undefined") {
      Intercom("showNewMessage")
    }
  })
});
