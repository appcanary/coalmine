(function() {
  var ServerModel = Backbone.RailsModel.extend({
  })
  var ServerStore = Backbone.Collection.extend({
    url: "/servers",
    model: ServerModel,
    parse: function(response) {
      return response.servers;
    },
  });

  Canary.ServerCollection = new ServerStore();
})()
