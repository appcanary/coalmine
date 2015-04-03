var React = require("react");
var TimelineView = React.createClass({
  render: function() {
    var self = this;
    var items = this.props.collection.models.map(function(m) {
      switch (m.get("kind")) {

        case "new_app":
          return <EventNewApp model={m} />;
        case "new_server":
          return <EventNewServer model={m} />;
        case "vuln":
          return <EventVuln model={m} />;
        case "not_vuln_app":
          return <EventNotVulnApp model={m} />;
        case "not_vuln_server":
          return <EventNotVulnServer model={m} />;
        case "allclear_server":
          return <EventAllClearServer model={m} />;
        case "allclear_app":
          return <EventAllClearApp model={m} />;
      }});

      return (
        <div>
          {items}
        </div>
      );
  }
});

module.exports = TimelineView
