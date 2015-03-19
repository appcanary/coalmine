(function() {

  var User = Backbone.RailsModel.extend({
    url: '/users',
    rootKey: "user",
  });

  
  var UserSession = Backbone.RailsModel.extend({
    url: '/user_sessions',
    rootKey: "user",
  });

  var UserStore = Backbone.Collection.extend({
    model: User,
  });

  Canary.User = User;
  Canary.UserSession = UserSession;
  Canary.UserCollection = new UserStore();

})();
