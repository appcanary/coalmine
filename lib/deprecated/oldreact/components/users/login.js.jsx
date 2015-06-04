var React = require("react");
var Logo = require("./logo");
var UserForm = require("./form");

var Login = React.createClass({  
  render: function() {
    return (
      <div id="main" className="container">
        <Logo />
        <UserForm user={this.props.user} title={"Nice to see you again."}  actionType={"user-login"} />
      </div>
    );
  },
});

module.exports = Login;
