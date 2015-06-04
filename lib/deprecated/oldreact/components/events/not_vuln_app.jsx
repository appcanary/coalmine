var $ = require("jquery");
var React = require("react");
var AvatarWidget = require("./avatar");
var TimeagoMixin = require("../../canary/mixins").TimeagoMixin;

var EventNotVulnApp = React.createClass({
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
                  <p><h3>Servers: </h3>
                    <AvatarWidget model={this.props.model.get("server")} onClicked={Canary.Herald.trigger("servers-show", {id: this.props.model.get("server").id})} size="tiny"/></p>
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
                    <AvatarWidget model={this.props.model.app()} onClicked={Canary.Herald.trigger("apps-show", {id: this.props.model.app().id})}/>
                  </p>
                </div>
                
                <div className="col-sm-4">
                  <p>
                    <img src={assets_path.ruby_logo} className= "icon" />
                    &nbsp;
      <strong>RubyGem:</strong> {this.vuln()["artifact"]}
      
                  </p>
                </div>
                <div className="col-sm-4">
                  <p className="pull-right"d><strong>Version:</strong>&nbsp; <span className="vuln-version">{this.vuln()["vuln_version"]}</span> <i className="fa fa-long-arrow-right"/> <span className="patched-version">{this.vuln()["patch_to"]}</span></p>
                </div>
              </section>
            </div>
          </div>
        </div>
      </section>
    );
  }
});


module.exports = EventNotVulnApp;
