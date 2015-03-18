(function() {

  var Navigator = Backbone.Router.extend({

    routes: {
      "sign_up":        "sign_up",    
      "dashboard":      "dashboard", 
    },

    sign_up: function() {
      Canary.UsersController.new();
    },

    dashboard: function() {
      React.render(
        <h1>Hello World</h1>,
        document.getElementById("main")
      )
    }

  });


  $(function(){
    Canary.Navigator = new Navigator();
    Backbone.history.start({pushState: true});
  });
})();
