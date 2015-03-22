var TimelineView = React.createClass({
  render: function() {
    var items = this.props.collection.models.map(function(m) {
      if(m.get("kind") == "first_app") {
        return <NewAppEvent model={m} />;
      }
    });
    return (
      <div>
        {items}
      </div>
    );
  }
});

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
                    event.app.platforms
                  </p>
                </div>

                <div className="edit-action">
                  <Eui_button title="Edit details" />
                </div>
              </section>
            </div>

          </div>
        </div>
      </section>
    )
  }
});


var NotVuln = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".timeline-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  render: function() {
    return (
      <section>
        <div className="timeline-box">
          <div className="timeline-wrapper resolved">
            <div className="title">
              <section>
                <div className="app-name">
                  <p>
                    <strong><a href="/apps/1">{ this.props.name }</a></strong>

                  </p>
                </div>

                <div className="message">
                  <p>{"Congrats! Your app doesn't have vulnerable dependencies."}</p>
                </div>

                <div className="timeago">
                  <span className="pull-right timestamp" title={this.props.event.get("app")["last_synced_at"]}>{ this.props.event.get("app")["last_synced_at"] }</span>
                </div>
              </section>
            </div>
          </div>
        </div>
      </section>
    );
  }
});
