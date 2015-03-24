var TimelineView = React.createClass({
  render: function() {
    var items = this.props.collection.models.map(function(m) {
      switch (m.get("kind")) {

        case "new_app":
          return <EventNewApp model={m} />;
        case "new_server":
          return <EventNewServer model={m} />;
        case "vuln":
          return <EventVuln model={m} />;
        case "not_vuln":
          return <EventNotVuln model={m} />;
      }});

      return (
        <div>
          {items}
        </div>
      );
  }
});
