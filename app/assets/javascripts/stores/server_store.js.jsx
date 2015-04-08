var Canary = require("../canary");
var Backbone = require("backbone");

var ServerModel = require("../models/server");

var ServerStore = Backbone.Collection.extend({
  url: "/servers",
  model: ServerModel,
  parse: function(response) {
    return response.servers;
  },
});

module.exports = new ServerStore();
