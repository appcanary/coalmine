var Canary = require("../canary");
var Controller = require("../canary/controller");
var React = require("react");

var Dashboard = require("../components/dashboard/dashboard");
var Timeline = require("../stores/timeline_store");

var DashboardController = Controller.extend({

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

// make sure this won't get us in trouble
module.exports = new DashboardController();
