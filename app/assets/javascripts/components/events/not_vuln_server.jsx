var $ = require("jquery");
var React = require("react");
var AvatarWidget = require("./avatar");
var TimeagoMixin = require("../../canary/mixins").TimeagoMixin;

var EventNotVulnServer = React.createClass({
  mixins: [TimeagoMixin], 
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timeline-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  vuln: function() {
    return this.props.model.vuln();
  },


  render: function() {
    return (
      <section>
        <div className="timeline-box">
          <div className="timeline-wrapper resolved">
            <div className="timeline-header">
              <section>
                <div className="col-sm-12">
                  <span className="last_synched_at timestamp pull-right" title={this.props.model.get("created_at")}>{this.props.model.get("created_at")}</span>
                  <p>⚡️ Congrats! You resolved a vulnerability</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="col-sm-4 affected">
                  <p><h3>Apps: </h3>
                    <ul>
                      <li><AvatarWidget model={this.props.model.get("app")} onClicked={Canary.Herald.trigger("apps-show", {id: this.props.model.get("app").id})} size="tiny"/></li>
                      <li><AvatarWidget model={this.props.model.get("app2")} onClicked={Canary.Herald.trigger("apps-show", {id: this.props.model.get("app2").id})} size="tiny"/></li>
                    </ul>
                  </p>
                </div>
                <div className="col-sm-8 affected">
                  <p><h3>Title: </h3>
                    {this.vuln().title}</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="col-sm-4">
                  <p>
                    <AvatarWidget model={this.props.model.server()} onClicked={Canary.Herald.trigger("servers-show", {id: this.props.model.server().id})}/>
                  </p>
                </div>

                <div className="col-sm-4">
                  <p>
                    <img src={assets_path.ubuntu_logo} className="icon" />

                    &nbsp;<strong>Package:</strong> {this.vuln()["artifact"]}
                  </p>
                </div>
                <div className="col-sm-4">
                  <p className="pull-right"d><strong>Version:</strong><br/><span className="vuln-version">{this.vuln()["vuln_version"]}</span> <i className="fa fa-long-arrow-right"/><br style={{lineHeight: "24px"}}/><span className="patched-version">{this.vuln()["patch_to"]}</span></p>
                </div>
              </section>
            </div>
          </div>
        </div>
      </section>
    );
  }
});

module.exports = EventNotVulnServer;
