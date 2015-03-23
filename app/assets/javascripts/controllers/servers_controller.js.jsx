(function() {

  var ServersController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "servers-create":  this.create.bind(this),
      });

    },

    new: function(onboarded) {
      React.render(
        <NewServer />,
        document.body
      )
    },

    create: function(app) {
     this.redirect_to("dashboard");
    }

  });


  Canary.ServersController = new ServersController();
})();

