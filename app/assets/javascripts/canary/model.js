var Backbone = require("backbone");
var _ = require("underscore");

var Model = Backbone.Model.extend({
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
});

module.exports = Model;
