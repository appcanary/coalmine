(function() {

  var DashboardController = Canary.Controller.extend({

    initialize: function() {

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
