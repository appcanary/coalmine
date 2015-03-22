(function() {

  var OnboardController = Canary.Controller.extend({

     initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "welcome-add-app":  this.add_app.bind(this),
      });

    },

    index: function(onboarded) {
      React.render(
        <Onboard />,
        document.body
      )
    },

    add_app: function() {
      this.redirect_to("apps/new");
    }

  });


  Canary.OnboardController = new OnboardController();
})();

