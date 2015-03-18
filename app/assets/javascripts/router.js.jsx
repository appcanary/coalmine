(function() {
  Canary.Herald = new Flux.Dispatcher();

  var Navigator = Backbone.Router.extend({

    routes: {
      "sign_up":        "sign_up",    
      "dashboard":      "dashboard", 
    },

    sign_up: function() {
      Canary.controllers.UserController.new();
    },

    dashboard: function() {
      React.render(
        <h1>Hello World</h1>,
        document.getElementById("main")
      )
    }

  });


  // sets up initial state for rendering views

  var UserController = function() {

    var controller = {}
    controller.new =  function() {
      var user = new Canary.User();
      React.render(
        <SignUp user={user} />,
          document.getElementById("main")
      );
    };

    controller.create = function(payload) {
      var user = payload.user;
      var controller = this;

      user.save(payload.form, {
        success: function(model, response, opt) {
          return controller.redirect_to("dashboard")
        },
        error: function(model, response, opt) {
          return model.setErrors(response.responseJSON);
        }
      });

      controller.redirect_to = function(path) {
        // awful but maybe GoodEnough
        $("#main").velocity("transition.fadeOut", function() {
          React.unmountComponentAtNode(document.getElementById("main"));
          $("#main").velocity({opacity: 1})
          Canary.Navigator.navigate(path, {trigger: true});
        });

      }
    };


    controller.dispatchToken = Canary.Herald.register_action(controller.create.bind(controller), "user-sign-up")
    _.extend(controller, Backbone.Events);

    return controller;

  };


  var User = Backbone.RailsModel.extend({
    url: '/users',
    rootKey: "user",
  });

  var UserStore = Backbone.Collection.extend({
    model: User,
    initialize: function() {
    },


    sign_up: function(payload) {
    },

    foo: function() {
      debugger;
    }
  });

  Canary.User = User;
  Canary.UserCollection = new UserStore();


  Canary.controllers.UserController = new UserController();

  $(function(){
    Canary.Navigator = new Navigator();
    Backbone.history.start({pushState: true});
  });
})();
