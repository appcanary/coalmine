var React = require("react");

var Logo = React.createClass({
  render: function() {
    return (
      <section>
        <div className="logo">
          <img src={'<%= image_path("oval-canary.png") %>'} />
        </div>
      </section>
    );
  }
});

module.exports = Logo;
