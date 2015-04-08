var React = require("react");
var Navbar = require("./navbar");
var AppLayout = React.createClass({
  render: function() {
    return (
      <div>
        <div className="navigation">
          <Navbar />
        </div>
        <div id="main" className="main-drawer container">
          {this.props.children}
        </div>
      </div>
    )
  }
});

module.exports = AppLayout;
