(function() {

  var AppsController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "apps-create":  this.create.bind(this),
      });

    },

    new: function(onboarded) {
    },

    create: function(app) {
      debugger
    }

  });


  Canary.AppsController = new AppsController();
})();


