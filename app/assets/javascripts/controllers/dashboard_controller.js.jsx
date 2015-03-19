(function() {

  var DashboardController = Canary.Controller.extend({

    initialize: function() {
      
    },

    index: function() {
      React.render(
        <Dashboard />,
        document.body
      )
    },

  });


  Canary.DashboardController = new DashboardController();
})();
