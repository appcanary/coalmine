(function() {

  var User = Backbone.RailsModel.extend({
    url: '/users',
    rootKey: "user",
  });

  var UserStore = Backbone.Collection.extend({
    model: User,
  });

  Canary.User = User;
  Canary.UserCollection = new UserStore();

})();
