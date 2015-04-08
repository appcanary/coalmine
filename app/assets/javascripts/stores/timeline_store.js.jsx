var Canary = require("../canary");
var Collection = require("backbone").Collection;

var TimelineEvent = require("../models/timeline");


var TimelineStore = Collection.extend({
  url: "/timeline",
  model: TimelineEvent,

  parse: function(response) {
    return response.timeline;
  },

  filterCollection: function(predicate) {
    return new TimelineStore(this.filter(predicate));
  }
});

module.exports = Canary.Timeline = new TimelineStore();

