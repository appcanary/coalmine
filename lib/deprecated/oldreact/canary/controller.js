var Backbone = require("backbone");
var _ = require("underscore");
var $ = require("jquery");

// Our own controller object, copying stuff from how Backbone.Model is setup.
var Controller = function() {
  this.initialize.apply(this, arguments);
};

_.extend(Controller.prototype, Backbone.Events, {
  redirect_to: function(path) {
    if($("#main").length < 1) {
      console.log("missing main");
    }

    // components should know to transition in.
    Canary.Navigator.navigate(path, {trigger: true});
  },
})

Controller.extend = Backbone.Model.extend;

module.exports = Controller;

