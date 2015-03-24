(function() {

  var ServersController = Canary.Controller.extend({

    initialize: function() {
      this.dispatchToken = 
        Canary.Herald.register_action({
        "servers-create":  function(m) {this.redirect_to("dashboard")}.bind(this),
        "servers-show":  function(payload) {this.redirect_to("servers/" + payload.id)}.bind(this),
      });

    },

    new: function(onboarded) {
      React.render(
        <NewServer />,
        document.body
      )
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
  });


  Canary.ServersController = new ServersController();
})();


