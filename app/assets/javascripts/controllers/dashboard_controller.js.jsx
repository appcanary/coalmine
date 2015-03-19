(function() {

  var DashboardController = Canary.Controller.extend({

    initialize: function() {
      
    },

    index: function() {
      React.render(
        <h1>Hello World</h1>,
        document.getElementById("main")
      )
    },

  });


  Canary.DashboardController = new DashboardController();
})();
