var Collection = require("backbone").Collection;
var User = require("../models/user");

// for now
var Canary = require("../canary");


var UserStore = Collection.extend({
  model: User,
});

Canary.UserCollection = new UserStore();

module.exports = UserStore;
