(function() {

  var Navigator = Backbone.Router.extend({
    
    routes: {
      "": "login",
      "sign_up":        "sign_up",    
      "login":          "login",    
      "dashboard":      "dashboard", 
      "welcome":        "welcome", 
      "servers/new":    "servers_new", 
    },

    sign_up: function() {
      Canary.UsersController.new();
    },

    login: function() {
      Canary.UsersController.login();
    },

    dashboard: function(onboard) {
      Canary.DashboardController.index(onboard);
    },

    welcome: function() {
      Canary.OnboardController.index();
    },
    
    servers_new: function(action) {
      Canary.ServersController.new();
    }

  });
  
  Canary.Navigator = new Navigator();

})();
