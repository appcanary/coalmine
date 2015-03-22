(function() {

  var Item = Backbone.RailsModel.extend({
  });

  var TimelineStore = Backbone.Collection.extend({
    url: "/timeline",
    model: Item,

    parse: function(response) {
      return response.timeline;
    }
  });

  Canary.Item = Item;
  Canary.Timeline = new TimelineStore();

})();
