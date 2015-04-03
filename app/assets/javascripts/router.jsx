var Backbone = require('backbone');
var Canary = require('./canary');

var Navigator = Backbone.Router.extend({

  routes: {
    "sign_up":        "sign_up",    
    "login":          "login",    
    "dashboard":      "dashboard", 
    "welcome":        "welcome", 
    "servers/new":    "servers_new", 
    "servers/:id":    "servers_show",
    "apps/:id":       "apps_show",
  },

  sign_up: function() {
    Canary.UsersController.new();
  },

  login: function() {
    Canary.UsersController.login();
  },

  dashboard: function(onboard) {
    Canary.DashboardController.index(onboard);
  },

  welcome: function() {
    Canary.OnboardController.index();
  },

  servers_new: function(action) {
    Canary.ServersController.new();
  },

  servers_show: function(id) {
    Canary.ServersController.show(id);
  },

  apps_show: function(id) {
    Canary.AppsController.show(id)
  },

});

module.export = Canary.Navigator = new Navigator();

