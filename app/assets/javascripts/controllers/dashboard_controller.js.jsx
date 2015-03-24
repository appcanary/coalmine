(function() {

  var DashboardController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken =
      Canary.Herald.register_action({
        "dashboard-index": function() { this.redirect_to("dashboard") }.bind(this)
      });
    },

    index: function(onboarded) {
      if(Canary.current_user.has_onboarded()) {
        React.render(
          <Dashboard current_user={Canary.current_user} 
            timeline={Canary.Timeline} />,
              document.body
        )
        Canary.Timeline.fetch();
      }
      else {
        this.redirect_to("welcome")
      }
    },

  });


  Canary.DashboardController = new DashboardController();
})();
