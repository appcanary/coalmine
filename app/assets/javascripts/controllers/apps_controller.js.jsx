(function() {

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
      var app = Canary.AppCollection.get(id)
      React.render(
        <AppLayout>
            <Sidepanel model={app}/>
            <div id="app-timeline">
              <TimelineView collection={Canary.Timeline.filterCollection(function(m) {return m.get("app").id.toString() === id})}/>
            </div>
          </AppLayout>,
        document.body
      );
    });
    }
    
  });


  Canary.AppsController = new AppsController();
})();


