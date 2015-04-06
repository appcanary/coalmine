// sets up stuff required for the rest of the app to load.

var Flux = require("flux")
var Backbone = require("backbone")
var _ = require("underscore")

// needed for loading velocity
window.jQuery = window.$ = require("jquery")

require("./vendor/velocity");
require("./vendor/velocity.ui");

var Canary = {}
Canary.components = {};
Canary.controllers = {};
Canary.models = {};
Canary.mixins = {};


Canary.mixins.RefNodeMixin = {
  refnode: function(ref) {
    return React.findDOMNode(this.refs[ref]);
  }
}


Flux.Dispatcher.prototype.register_action = function(actions) {

  return this.register(function(payload) {
    var callback = actions[payload.actionType];

    if (callback !== undefined) {
      callback(payload);
    }
  });
}

Canary.Herald = new Flux.Dispatcher();

// consider a link_to mixin?

Canary.Herald.trigger = function(event, obj) {
  return function(e) {
    e.preventDefault();
    Canary.Herald.dispatch(_.extend({actionType: event}, obj));  
  };
};

module.exports =Canary;
