var TimelineView = React.createClass({
  render: function() {
    var items = this.props.collection.models.map(function(m) {
      if(m.get("kind") == "first_app") {
        return <NewAppEvent model={m} />;
      }
    });
    return (
      <div>
        {items}
      </div>
    );
  }
});
