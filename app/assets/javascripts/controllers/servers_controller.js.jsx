(function() {

  var ServersController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "servers-create":  this.create.bind(this),
        "servers-show":  this.fetchShow.bind(this),
      });

    },

    new: function(onboarded) {
      React.render(
        <NewServer />,
        document.body
      )
    },

    create: function(app) {
      this.redirect_to("dashboard");
    },

    show: function(id) {
      Canary.ServerCollection.fetch().done(function() {
        var server = Canary.ServerCollection.get(id);

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
    },

    fetchShow: function(payload) {
      return this.redirect_to("servers/" + payload.id);
    }

  });


  Canary.ServersController = new ServersController();
})();


