var Login = React.createClass({  
  render: function() {
    return (
      <div id="main" className="container">
        <Logo />
        <UserForm user={this.props.user} title={"Hello YC, We've created a little demo for you! Click Login to start."}  actionType={"user-login"} />
      </div>
    );
  },
});
