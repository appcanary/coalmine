var React = require("react");
var NewApp = require("../events/new_app");
var NewServer = require("../events/new_server");
var NotVulnApp = require("../events/not_vuln_app");
var NotVulnServer = require("../events/not_vuln_server");
var AllClearApp = require("../events/all_clear_app");
var AllClearServer = require("../events/all_clear_server");

var TimelineView = React.createClass({
  render: function() {
    var self = this;
    var items = this.props.collection.models.map(function(m) {
      switch (m.get("kind")) {

        case "new_app":
          return <NewApp model={m} />;
        case "new_server":
          return <NewServer model={m} />;
        case "not_vuln_app":
          return <NotVulnApp model={m} />;
        case "not_vuln_server":
          return <NotVulnServer model={m} />;
        case "allclear_server":
          return <AllClearServer model={m} />;
        case "allclear_app":
          return <AllClearApp model={m} />;
      }});

      return (
        <div>
          {items}
        </div>
      );
  }
});

module.exports = TimelineView
