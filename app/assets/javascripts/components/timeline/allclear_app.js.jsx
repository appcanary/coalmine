var EventAllClearApp = React.createClass({
  mixins: [TimeagoMixin],
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },


  render: function() {
    return (
      <section>
        <div className="event-box">
          <div className="event-wrapper resolved">
            <div className="event-header">
              <section>
                <div className="note">
                  <span className="last_synched_at timestamp" title={this.props.model.get("created_at")}>{this.props.model.get("created_at") }</span>
                  <p>⭐️&nbsp;Good job! Your app has no vulnerable dependencies.</p>
                </div>
              </section>
            </div>
            <div className="event-description">
              <section>
                <div className="name">
                  <p>
                    <AvatarWidget model={this.props.model.app()} onClicked={Canary.Herald.trigger("app-show",{id: this.props.model.app().id})} />
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
