var Canary = require("../canary");

var AppsController = Canary.Controller.extend({

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
    Canary.AppCollection.fetch().done(function() {
      var app = Canary.AppCollection.get(id);
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


Canary.AppsController = new AppsController();


