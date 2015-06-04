var React = require("react");

var Logo = React.createClass({
  render: function() {
    return (
      <section>
        <div className="logo">
          <img src={assets_path.logo} />
        </div>
      </section>
    );
  }
});

module.exports = Logo;
