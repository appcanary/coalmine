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
          <h1>LOL SERVER {server.get("name")}</h1>,
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


