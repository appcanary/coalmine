var NewAppEvent = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
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
                  <p>🎉 You added a new app!</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="name">
                  <p>
                    <img src={"data:image.png;base64," + this.props.model.get("app")["avatar"]} className="icon" />
                    <strong>&nbsp;<a href="#">{this.props.model.get("app")["name"]}</a></strong>
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
                    <img src={"data:image.png;base64," + this.props.model.get("app")["server"]["avatar"]} className="icon tiny" />
                    <strong>&nbsp;<a href="#">{this.props.model.get("app")["server"]["name"]}</a></strong>
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
