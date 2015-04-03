var Router = require('backbone').Router;
var Canary = require('./canary');

var DashboardController = require('./controllers/dashboard_controller');
var UsersController = require('./controllers/users_controller');

var Navigator = Router.extend({

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
    UsersController.login();
  },

  dashboard: function(onboard) {
    DashboardController.index(onboard);
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

