(function() {

  var AppsController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "apps-create":  this.create.bind(this),
      });

    },

    new: function(onboarded) {
      React.render(
        <NewApp />,
        document.body
      )
    },

    create: function(app) {
      debugger
    }

  });


  Canary.AppsController = new AppsController();
})();


