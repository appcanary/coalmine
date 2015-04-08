var Canary = require("../canary");
var Backbone = require("backbone");
var AppModel = require("../models/app");

var AppStore = Backbone.Collection.extend({
  url: "/apps",
  model: AppModel,
  parse: function(response) {
    return response.apps;
  },
});

module.exports = new AppStore();
