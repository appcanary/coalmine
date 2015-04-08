var Model = require("../canary/model");

var TimelineEvent = Model.extend({
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

module.exports = TimelineEvent;
