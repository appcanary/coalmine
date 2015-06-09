var React = require('react');
var AvatarWidget = require('../events/avatar');
var TimeagoMixin = require("../../canary/mixins").TimeagoMixin

var Sidepanel = React.createClass({
  mixins: [TimeagoMixin],
  componentDidMount: function() {
    this.animateIn();
  },

  componentDidUpdate: function() {
    if(!$(".app-sidepanel").is(":visible")) {
      this.animateIn();
    }
  },

  animateIn: function() {
    $(".app-sidepanel").velocity({'z-index': -2 }).velocity("transition.slideLeftBigIn", 400).velocity({'z-index': 1});
  },

  render: function() {
    //TODO: these should all be compoonenets
    var navTabs = "";
    if (this.props.isApp) {
      navTabs =(
        <ul className="nav nav-tabs">
          <li role="presentation" className="active"><a href="#">Production</a></li>
          <li role="presentation"><a href="#">Staging</a></li>
          <li role="presentation"><a href="#">Dev</a></li>
        </ul>
      );
    }

    var rubyGems = "";
    if (this.props.model.get("rubygems")) {
      rubyGems = (
        <tr>
          <td>
            <strong>Rubygems</strong>
          </td>
          <td>
            <span>
              {this.props.model.get("rubygems")}
            </span>
            <i className="fa fa-angle-right pull-right"></i>
          </td>
        </tr>
      )
    }

    var NPM = "";
    if (this.props.model.get("npm")) {
      rubyGems = (
        <tr>
          <td>
            <strong>Rubygems</strong>
          </td>
          <td>
            <span>
              {this.props.model.get("npm")}
            </span>
            <i className="fa fa-angle-right pull-right"></i>
          </td>
        </tr>
      )
    }

    var systemPackages = "";
    if (this.props.model.get("system_packages")) {
      systemPackages  =
      (<tr>
          <td>
            <strong>System Packages</strong>
          </td>
          <td>
            <span>
              830
            </span>
            <i className="fa fa-angle-right pull-right"></i>
          </td>
      </tr> )
    }
    
    return (
      <div className="app-sidepanel">
        <section>
          <div className="nav-identity">
            <p>
              <a className="dashboard" href="#" onClick={Canary.Herald.trigger("dashboard-index")}><b className='eui-trailing-icon fa fa-angle-double-left'></b> Dashboard</a>
            </p>
            <h3><AvatarWidget model={this.props.model.attributes}/></h3>
          </div>
        </section>
        <section>
          <div className="col-md-12">
            {navTabs}
            <table className="table unstyled info">
              <tbody>
              <tr>
                <td>
                  <strong>Last Updated</strong>
                </td>
                <td>
                  <span className="timestamp" title={this.props.model.get("last_synced_at")}>{this.props.model.get("last_synced_at")}</span>
                </td>
              </tr>


              <tr>
                <td>
                  <strong>Platforms</strong>
                </td>
                <td className="platforms">
                  {this.props.model.get("platforms")}
                </td>
              </tr>

              {rubyGems}
              {NPM}
              </tbody>
      
            </table>

            <section className="issues-nav">
              <div className="all-issues">
                <h4 className="selected">All issues <span className="pull-right"><i className="fa fa-angle-right"></i></span></h4>
              </div>
            </section>

            <table className="table issues">
              <tbody>
              <tr className="">
                <td>
                  Active
                </td>
                <td>
                  <span>2 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>

              <tr>
                <td>
                  Resolved
                </td>
                <td>
                  <span>56 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>

              <tr>
                <td>
                  Ignored
                </td>
                <td>
                  <span>3 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

    )
  }
});

module.exports = Sidepanel;
