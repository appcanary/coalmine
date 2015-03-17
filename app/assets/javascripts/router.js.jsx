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

var UserController = function() {
  this.new = function() {
    React.render(
      <SignUp handler={this.create} />,
      document.getElementById("main")
    );
  }

  // this.create = function(form) {
        
  // }
};


var User = Backbone.RailsModel.extend({
  url: '/users',
  rootKey: "user",
});

var UserCollection = Backbone.Collection.extend({
  model: User,
  initialize: function() {
    this.dispatchToken = Canary.Herald.register_action(this.sign_up.bind(this), "user-sign-up");

  },


  sign_up: function(payload) {
    var user = new this.model();

    user.fromForm(form);
    sign_up.save({
      success: function(foo, resp) {
      },

      error: function(foo, response) {
      }
    });

  },

  foo: function() {
    debugger;
  }
});

Canary.User = User;
Canary.UserCollection = new UserCollection();


Canary.controllers.UserController = new UserController();

$(function(){
  Canary.Navigator = new Navigator();
  Backbone.history.start({pushState: true});
});
