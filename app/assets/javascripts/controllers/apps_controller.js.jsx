var Canary = require("../canary");
var Controller = require("../canary/controller");

var React = require("react");
var AppLayout = require("../components/layout");
var Sidepanel = require("../components/dashboard/sidepanel");
var TimelineView = require("../components/timeline/timeline");
var AppCollection = require("../stores/app_store");

var AppsController = Controller.extend({

  initialize: function() {
    this.dispatchToken = 
      Canary.Herald.register_action({
      "apps-create":  this.create.bind(this),
      "apps-show": function(app) {this.redirect_to("apps/" + app.id)}.bind(this)
    });

  },

  new: function(onboarded) {
  },

  create: function(app) {
    debugger
  },

  show: function(id) {
    AppCollection.fetch().done(function() {
      var app = AppCollection.get(id);
      Canary.Timeline.fetch().done(function() {
        React.render(
          <AppLayout>
            <Sidepanel model={app} isApp={true}/>
            <div id="app-timeline">
              <TimelineView collection={Canary.Timeline.filterCollection(function(m) {return m.get("app").id.toString() === id || (m.get("app2") && m.get("app2").id.toString() === id)})}/>
            </div>
          </AppLayout>,
          document.body
        );
      });
    });
  }

});


module.exports = new AppsController();

