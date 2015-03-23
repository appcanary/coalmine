(function() {

  var TimelineEvent = Backbone.RailsModel.extend({
  });

  var TimelineStore = Backbone.Collection.extend({
    url: "/timeline",
    model: TimelineEvent,

    parse: function(response) {
      return response.timeline;
    }
  });

  Canary.TimelineEvent = TimelineEvent;
  Canary.Timeline = new TimelineStore();

})();
