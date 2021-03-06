var React = require("react");
var Logo = require("./logo");
var UserForm = require("./form");

var SignUp = React.createClass({
  render: function() {
    return (
      <div id="main" className="container">
        <Logo />
        <UserForm user={this.props.user} sign_up_page={true} title={"Before we get started, tell us:"} actionType={"user-sign-up"} />
      </div>
    );
  },
});

module.exports = SignUp;
