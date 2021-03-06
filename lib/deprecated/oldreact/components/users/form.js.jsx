var React = require("react");
var Canary = require("../../canary");


var UserForm = React.createClass({
  getInitialState: function() {
    var attr = {}

    if (this.props.sign_up_page !== undefined) {
        attr["password_confirmation"] = "";
        attr["button_value"] = "Sign Up";
    } else {
        attr["button_value"] = "Login";
    }
    return attr;

  },

  componentDidMount: function() {
    this.props.user.on("error", function() {
      // if there was an error, we want to clear out the
      // sign-up form, and we achieve this by resetting the
      // state.
      this.setState(this.getInitialState());
    }, this);
  },

  componentWillUnmount: function() {
    this.props.user.off(null, null, this);
  },

  handleChange: function() {

    var attr = {
      email: this.refs.email.getDOMNode().value,
      password: this.refs.password.getDOMNode().value,
    }

    if (this.props.sign_up_page !== undefined) {
      attr["password_confirmation"] = this.refs.password_confirmation.getDOMNode().value ;
    }

    return this.setState(attr);
  },

  submitForm: function(e) {
    e.preventDefault();

    this.refs.email.getDOMNode().focus();
    Canary.Herald.dispatch({
      actionType: this.props.actionType,
      form: this.state,
      user: this.props.user
    });
  },

  render: function() {
    var error_alert = undefined;
    if(this.props.user.errors !== undefined){
      var error_msgs = _.map(this.props.user.errors.full_messages, function(msg, i) {
        return <li>{msg}</li>;
      });

      error_alert = (
        <div className="error_explanation" role="alert">
          <h4>Oops. We encountered an error:</h4>
          <ul>
            {error_msgs}
          </ul>
        </div>
      )

    }


    var password_confirmation_view =  (
      <div className="form-group">
        <input className="form-control" placeholder="The same password again, just to confirm" data-match="#user_password" data-error="Passwords must match" type="password" name="password_confirmation" id="user_password_confirmation" ref="password_confirmation" required onChange={this.handleChange} value={this.state.password_confirmation} />
        <span className="help-block with-errors"></span>
      </div>
    )

      
    return (
      <section>
        <div className="user-login">
          <form data-toggle="validator" className="new_user" action="/users" method="post" role="form" ref="form" onSubmit={this.submitForm} >

            {error_alert}

            <h3>{this.props.title}</h3>
            <div className="form-group">
              <input className="form-control" placeholder="Your email address" type="email" name="email" id="user_email" ref="email" required onChange={this.handleChange} value={this.state.email}/>
            </div>

            <div className="form-group">
              <input className="form-control" placeholder="A password, or a secret between us" data-minlength="6" data-error="At least 6 characters" type="password" name="password" id="user_password" ref="password" required onChange={this.handleChange}value={this.state.password} />
              <span className="help-block with-errors"></span>
            </div>

            { this.props.sign_up_page ? password_confirmation_view : null }

           
            <div className="form-group">
              <input type="submit" name="commit" value={this.state.button_value} className="btn btn-black" />
            </div>

          </form>
        </div>
      </section>
    )
  }
});

module.exports = UserForm;
