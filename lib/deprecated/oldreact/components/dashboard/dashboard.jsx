var React = require("react");
var AppLayout = require("../layout");
var TimelineView = require("../timeline/timeline");

var Dashboard = React.createClass({
  componentDidMount: function() {
    this.props.timeline.on("sync", function() {
      this.forceUpdate();
    }, this);
  },

  componentWillUnmount: function() {
    this.props.timeline.off(null, null, this);
  },

  render: function(){
    return (
      <AppLayout>
        <TimelineView collection={this.props.timeline} />
      </AppLayout>
    )
  }
});

module.exports = Dashboard;
