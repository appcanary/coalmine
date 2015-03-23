var TimelineView = React.createClass({
  render: function() {
    var items = this.props.collection.models.map(function(m) {
      switch (m.get("kind")) {
          
        case "new_app":
          return <NewAppEvent model={m} />;
        case "new_server":
          return <NewServerEvent model={m} />;
      }});

    return (
      <div>
        {items}
      </div>
    );
  }
});
