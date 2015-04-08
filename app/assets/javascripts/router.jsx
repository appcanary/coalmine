var Router = require('backbone').Router;
var Canary = require('./canary');

var DashboardController = require('./controllers/dashboard_controller');
var UsersController = require('./controllers/users_controller');
var AppsController = require('./controllers/apps_controller');
var OnboardController = require('./controllers/onboard_controller');
var ServersController = require('./controllers/servers_controller');

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
    UsersController.new();
  },

  login: function() {
    UsersController.login();
  },

  dashboard: function(onboard) {
    DashboardController.index(onboard);
  },

  welcome: function() {
    OnboardController.index();
  },

  servers_new: function(action) {
    ServersController.new();
  },

  servers_show: function(id) {
    ServersController.show(id);
  },

  apps_show: function(id) {
    AppsController.show(id)
  },

});

module.export = Canary.Navigator = new Navigator();

