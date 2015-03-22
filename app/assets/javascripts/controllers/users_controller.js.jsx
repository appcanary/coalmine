(function() {
  var UsersController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "user-sign-up":  this.create.bind(this),
        "user-login":    this.create.bind(this)
      });

    },

    new: function() {
      var user = new Canary.User();
      React.render(
        <SignUp user={user} />,
          document.body
      );
    },

    login: function() {
      var session = new Canary.UserSession();
      React.render(
        <Login user={session} />,
          document.body
      );
    },

    create: function(payload) {
      var user = payload.user;
      var controller = this;

      user.save(payload.form, {
        success: function(model, response, opt) {
          Canary.current_user = new Canary.User(response["user"]);
          if(Canary.current_user.has_onboarded()) {
            return controller.redirect_to("dashboard") 
          } else {
            return controller.redirect_to("welcome") 
          }
            
        },
        error: function(model, response, opt) {
          return model.setErrors(response.responseJSON);
        }
      });

    },



  });


  Canary.UsersController = new UsersController();

})();
