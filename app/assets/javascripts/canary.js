// sets up stuff required for the rest of the app to load.

define("canary", ["flux", "backbone", "underscore"], function(Flux, Backbone, _) {

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
    };}



    // define us some mixins shall we

    var TimeagoMixin = {
      componentDidMount: function() {
        $(React.findDOMNode(this)).find(".timestamp").timeago();
      },
      componentDidUpdate: function() {
        $(React.findDOMNode(this)).find(".timestamp").timeago();
      }  
    };

    return Canary;
});
