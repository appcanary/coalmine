var EventNewServer = React.createClass({
  mixins: [TimeagoMixin],
  componentDidMount: function() {
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
                  <span className="last_synched_at timestamp" title={this.props.model.get("created_at")}>{this.props.model.get("created_at") }</span>
                  <p>🎉&nbsp;You added a new server!</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="name">
                  <p>
                    <AvatarWidget model={this.props.model.server()} onClicked={Canary.Herald.trigger("servers-show",{id: this.props.model.server().id})} />
                  </p>
                </div>
                <div className="os">
                  <p>
                    <strong>
                     Operating System:
                    </strong>
                    &nbsp;
                    Ubuntu 12.04.4
                  </p>
                </div>
                  <div className="server-platforms">
                  <p>
                    <strong>
                      Platforms:
                    </strong>
                    &nbsp;
                    Ruby, Node
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
