var EventVuln = React.createClass({
  mixins: [TimeagoMixin],
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timeline-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  vuln: function() {
    return this.props.model.vuln();
  },

  getInitialState: function() {
    return {
      view_details: false
    }
  },

  render: function() {
    var apps_affected = [<li><AvatarWidget model={this.props.model.app()} onClicked={Canary.Herald.trigger("apps-show", {id: this.props.model.app().id})} size="tiny" /></li>]
    if(this.props.model.get("app2") !== null) {
      apps_affected = apps_affected.concat(<li><AvatarWidget model={this.props.model.get("app2")} onClicked={Canary.Herald.trigger("apps-show", {id: this.props.model.get("app2").id})} size="tiny" /></li>)
    }

    var server_affected = <AvatarWidget model={this.props.model.server()} onClicked={Canary.Herald.trigger("servers-show", {id: this.props.model.server().id})}size="tiny" />

    var details = undefined;
    details = (
      <div className="resolution">
        <section>
          <div className="description">
            <p><strong>{this.vuln()["title"]}</strong></p>
            <p>{this.vuln()["description"]}</p>
            <p className="highlight">Upgrade to <span>{this.vuln()["patch_to"]}</span></p>
          </div>
        </section>
      </div>
    )


      var dependency = ""

    if(this.props.model.get("app2") !== null) {
        dependency = (<p>
                      <%= image_tag("ubuntu_logo.png", :className=> "icon") %>
                      &nbsp;<strong>Package:</strong> {this.vuln()["artifact"]}
                    </p>)

    } else {
      dependency = (<p>
                      <%= image_tag("icon-ruby.png", :className=> "icon") %>
                      &nbsp;<strong>RubyGem:</strong> {this.vuln()["artifact"]}
                    </p>)
    }




      return (
        <section>
          <div className="timeline-box">
            <div className="timeline-wrapper vuln">
              <div className="title">
                <section>

                  <div className="name">
                    {dependency}
                  </div>
                  
                  <div className="version">
                    <p><strong>Version:</strong> <span>{this.vuln()["vuln_version"]}</span></p>
                  </div>
                  
                  <div className="risk">
                    <p><strong>Risk:</strong> { this.vuln()["criticality"] }</p>
                  </div>

                  <div className="timeago">
                    <span className="timestamp pull-right" title={this.vuln()["notified_at"]}>{this.vuln()["notified_at"]}</span>
                  </div>
                </section>
              </div>

              <div className="affected">
                
                <section>
                  <div className="apps">
                    <h3>Apps affected</h3>
                    <ul>
                      {apps_affected}
                    </ul>
                  </div>

                  <div className="servers">
                    <h3>Servers affected</h3>
                    <ul>
                      <li>{server_affected}</li>
                    </ul>
                  </div>
                </section>
              </div>

              {details}

              <div className="resolution">
                <section>
                  <div className="actions">
                    <div className="pull-left">
                      <Eui_button value="Ignore for now" />
                    </div>
                    <div className="pull-right">
                      <Eui_button value="Create ticket" style="primary" />
                    </div>

                  </div>
                </section>
              </div>
            </div>
          </div>
        </section>
      );
  }
});

