var TimelineView = React.createClass({
  getInitialState: function() {
    return {tour_tick: Canary.current_user.tour_tick()}
  },
  
  componentDidMount: function() {
    this.dispatchToken =
     Canary.Herald.register_action({
       "advance-tour": function() {
         var tour_tick = this.state.tour_tick + 1;
         this.setState({tour_tick: tour_tick});
         Canary.current_user.save({tour_tick: tour_tick});
       }.bind(this)
     });
  },
  
  render: function() {
    var self = this;
    var items = this.props.collection.models.filter(function(m) { return ((self.state.tour_tick >= m.get("tour_enter")) && (self.state.tour_tick < m.get("tour_exit")))}).map(function(m) {
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
