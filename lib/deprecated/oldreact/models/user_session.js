var Model = require("../canary/model");

var UserSession = Model.extend({
  url: '/user_sessions',
  rootKey: "user",

});

module.exports = UserSession;
