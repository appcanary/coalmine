var $ = require('jquery');
var Canary = require('./canary');
var router = require('./router');
var csrf = require('./csrf');
var Backbone = require('backbone');

var loader = require.context("./controllers", true);
loader.keys().forEach(loader);

var foo = require.context("./stores", true);
foo.keys().forEach(foo);

window.Canary = Canary;

$(function(){


  // let's bootstrap the current_user object, if we're already
  // logged in!
  var current_user_div = document.getElementById('canary-current-user');
  if(current_user_div !== null) {
    var userJSON = JSON.parse(current_user_div.textContent);
    Canary.current_user = new Canary.User(userJSON["user"]);
  }

  Backbone.history.start({pushState: true});

});

