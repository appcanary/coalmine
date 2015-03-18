(function() {
  var UsersController = function() {

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


  Canary.UsersController = new UsersController();

})();
