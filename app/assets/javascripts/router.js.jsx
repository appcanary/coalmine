(function() {

  var Navigator = Backbone.Router.extend({

    routes: {
      "sign_up":        "sign_up",    
      "login":          "login",    
      "dashboard":      "dashboard", 
    },

    sign_up: function() {
      Canary.UsersController.new();
    },

    login: function() {
      Canary.UsersController.login();
    },

    dashboard: function() {
      Canary.DashboardController.index();
    }

  });


  $(function(){
    Canary.Navigator = new Navigator();
    Backbone.history.start({pushState: true});
  });
})();
