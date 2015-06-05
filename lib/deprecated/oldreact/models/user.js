var Model = require("../canary/model");

var User = Model.extend({
  rootKey: "user",
  urlRoot: "/users",
  has_onboarded: function() {
    return this.get("onboarded") === true
  },
});

module.exports = User;
