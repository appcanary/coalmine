var NotVuln = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".timeline-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  componentDidUpdate: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
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
