var $ = require("jquery");
var React = require("react");
var Canary = require("../canary")
var Timeago = require("../vendor/jquery.timeago")

Canary.mixins.TimeagoMixin = {
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
  },
  componentDidUpdate: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
  }  
};

module.exports = Canary.mixins;

