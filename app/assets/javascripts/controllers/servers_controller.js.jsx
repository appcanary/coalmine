var Canary = require("../canary");
var Controller = require("../canary/controller");

var React = require("react");
var NewServer = require("../components/servers/new");

var AppLayout = require("../components/layout");
var Sidepanel = require("../components/dashboard/sidepanel");
var TimelineView = require("../components/timeline/timeline");

var ServerCollection = require("../stores/server_store");


var ServersController = Controller.extend({

  initialize: function() {
    this.dispatchToken = 
      Canary.Herald.register_action({
      "servers-create":  function(s) {this.redirect_to("dashboard")}.bind(this),
      "servers-show":  function(s) {this.redirect_to("servers/" + s.id)}.bind(this),
    });

  },

  new: function(onboarded) {
    React.render(
      <NewServer />,
      document.body
    )
  },

  show: function(id) {

    ServerCollection.fetch().done(function() {
      var server = ServerCollection.get(id);
      Canary.Timeline.fetch().done(function() {
        React.render(
          <AppLayout>
            <Sidepanel model={server}/>
            <div id="app-timeline">
              <TimelineView collection={Canary.Timeline.filterCollection(function(m) {return m.get("server").id.toString() === id})}/>
            </div>
          </AppLayout>,
          document.body
        )

      });
    });
  },
});


module.exports = new ServersController();
