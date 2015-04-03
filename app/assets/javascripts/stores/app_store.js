var Canary = require("../canary");
var Backbone = require("backbone");

var AppModel = Backbone.RailsModel.extend({
})
var AppStore = Backbone.Collection.extend({
  url: "/apps",
  model: AppModel,
  parse: function(response) {
    return response.apps;
  },
});

Canary.AppCollection = new AppStore();
