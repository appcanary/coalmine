(function() {

  var TimelineEvent = Backbone.RailsModel.extend({
    vuln: function() {
      return this.get("vuln");
    },

    app: function() {
      return this.get("app");
    },

    server: function() {
      return this.get("server");
    }
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
