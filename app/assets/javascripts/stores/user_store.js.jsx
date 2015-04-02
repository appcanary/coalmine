(function() {

  var User = Backbone.RailsModel.extend({
    rootKey: "user",
    urlRoot: "/users",
    has_onboarded: function() {
      return this.get("onboarded") === true
    },
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
