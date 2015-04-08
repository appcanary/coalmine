var Canary = require("../canary");
var Controller = require("../canary/controller");

var Onboard = require("../components/onboard");
var React = require("react");


var OnboardController = Controller.extend({

  initialize: function() {
    this.dispatchToken = 
      Canary.Herald.register_action({
      "welcome-add-app":  this.add_app.bind(this),
    });

  },

  index: function(onboarded) {
    Canary.Timeline.fetch();
    React.render(
      <Onboard />,
      document.body
    )
  },

  add_app: function() {
    Canary.current_user.save({"onboarded": true})
    this.redirect_to("servers/new");
  }

});


module.exports = new OnboardController();
