var NewServer = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },


  render: function() {
    return (
      <div>
        <div className="navigation">
          <Navbar />
        </div>
        <div id="main" className="main-drawer container">
          <section>
            <div className="event-box">
              <div className="event-wrapper">
                <div className="event-header">
                  <section>
                    <div className="note">
                      <span className="last_synched_at timestamp"></span>
                      <h3>Add a server</h3>
                    </div>
                  </section>
                </div>

                <div className="event-description">
                  <section>
                    <div className="name">
                      <p>
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

                  </section>
                </div>

                <div clasName="event-actions">
                  <section>
                    <div className="action-bar">
                      <Eui_button value="Edit details" />
                    </div>
                  </section>
                </div>
              </div>
            </div>
          </section>

        </div>
      </div>
    )
  }
});
