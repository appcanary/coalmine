window.jQuery = window.$ = require('jquery');
require('jquery-ujs');
require('bootstrap/dist/js/bootstrap.js');
require("./internal/payment_handling.js")
require("./internal/highlighting.js");
require("./internal/handle_intercom.js");
require("./internal/new_servers_page.js");

require("select2");

$(document).ready(function() {
  $('select').select2({
    theme: "bootstrap",
    placeholder: "I use...",
    tags: true
  });
});

