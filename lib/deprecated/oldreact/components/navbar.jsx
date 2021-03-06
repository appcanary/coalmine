var React = require("react");

var Navbar = React.createClass({
  isActive: function (tab) {
    if (this.props.activeTab === tab) {
      return "active";
    } else {
      return "";
    }
  },


  handleClick: function(e, foo) {
    e.preventDefault();
    $(e.currentTarget).tooltip({title: "Sorry! Not yet."}).tooltip("show");
  },


  render: function() {
    return (
      <div className="navbar-left-side" role="navigation">
        <div className="container">
          <div className="collapsed-menu">
            <button type="button" className="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
              <span className="sr-only">Toggle navigation</span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
          </div>


          <div className="navbar-collapse collapse">
            <ul className="menu">
              <li>
                <a className="navbar-brand" href="/" onClick={Canary.Herald.trigger("dashboard-index")}>
                  <img src={assets_path.logo} />
                </a>
              </li>
            </ul>
            <ul className="menu">
              <li className="divider"></li>
              <li> <a href="/dashboard" onClick={Canary.Herald.trigger("dashboard-index")} className={this.isActive("add")}><i className="fa fa-clock-o"></i></a> </li>
              <li> <a href="/servers/new" onClick={this.handleClick} className={this.isActive("add")}><i className="fa fa-plus"></i></a> </li>

              <li> <a href="/settings" onClick={this.handleClick} className={this.isActive("settings")}><i className="fa fa-cog"></i></a> </li>
              <li>
                <a data-method="post" href="/logout"><i className="fa fa-sign-out"></i></a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    )
  }
});

module.exports = Navbar;
