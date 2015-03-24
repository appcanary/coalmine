var NewAppEvent = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  componentDidUpdate: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
  },

  render: function() {
    return (
      <section>
        <div className="event-box">
          <div className="event-wrapper">
            <div className="event-header">
              <section>
                <div className="note">
                  <span className="last_synched_at timestamp" title={this.props.model.get("created_at")}>{this.props.model.get("created_at")}</span>
                  <p>🎉&nbsp;You added a new app!</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="name">
                  <p>
                    <AvatarWidget model={this.props.model.app()}/>
                  </p>
                </div>

                <div className="platforms">
                  <p>
                    <strong>
                      Platforms:
                    </strong>
                    &nbsp;
                    {this.props.model.get("app")["platforms"]}
                  </p>
                </div>

                <div className="app-server">
                  <p>
                    <strong>
                      Server:
                    </strong>
                    &nbsp;
                    <AvatarWidget model={this.props.model.app().server} onClicked={Canary.Herald.trigger("servers-show", {id: this.props.model.app().server.id})} size="tiny"/>
                  </p>
                </div>
              </section>
            </div>

          </div>
        </div>
      </section>
    )
  }
});
