(function() {

  var DashboardController = Canary.Controller.extend({

     initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "dashboard-add-first-app":  this.add_app.bind(this),
      });

    },

    index: function(onboarded) {
      React.render(
        <Dashboard current_user={Canary.current_user} 
                   timeline={Canary.Timeline} />,
        document.body
      )
    },

    add_app: function() {
      Canary.current_user.set("onboard_state", true);
    }

  });


  Canary.DashboardController = new DashboardController();
})();
