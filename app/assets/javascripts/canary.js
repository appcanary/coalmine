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

  Backbone.RailsModel = Backbone.Model.extend({
    toJSON: function() {
      json = {};
      json[this.rootKey] = Backbone.Model.prototype.toJSON.call(this);
      return json;
    },

    parse: function(json) {
      if(this.rootKey === undefined) {
        return json
      }

      if(json !== undefined) {
        return json[this.rootKey];
      }
    },

    fromForm: function(form) {
      var data = $(form).serializeArray();
      var formData = _.object(_.pluck(data, 'name'), _.pluck(data, 'value'));

      return this.set(formData);
    },

    setErrors: function(attr) {
      this.errors = attr || {};
      if(this.errors.full_messages === undefined) {
        this.errors.full_messages = [];
      }

      this.trigger('error');
      return this.errors;
    }
  })

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

    // Our own controller object, copying stuff from how Backbone.Model is setup.

    Canary.Controller = function() {
      this.initialize.apply(this, arguments);
    };

    _.extend(Canary.Controller.prototype, Backbone.Events, {
      redirect_to: function(path) {
        if($("#main").length < 1) {
          console.log("missing main");
        }

        // components should know to transition in.
        Canary.Navigator.navigate(path, {trigger: true});
      },
    })

    Canary.Controller.extend = Backbone.Model.extend;

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
