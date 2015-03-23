var NewServer = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".timestamp").timeago();
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },

  addServer: function(e) {
    e.preventDefault();
    return Canary.Herald.dispatch({
      actionType: "servers-create",
    });

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
                      <h3>Add a Server</h3>
                    </div>
                  </section>
                </div>

                <div className="event-description">
                  <section>
                    <div className="col-sm-12">
                      <p>It looks like you're using Ubuntu 14.04!</p>
                      <p>Add us to your apt sources</p>
                      <pre>                                                
                        echo deb https://apt.appcanary.com/debian/ appcanary non-free &gt;&gt; \ <br/>
                        &nbsp;&nbsp;/etc/apt/sources.list.d/appcanary.list
                      </pre>
                      <p>Put your trust in us:</p>
                      <pre>
                        wget -O- https://dist.appcanary.com/apt/canary.gpg | apt-key add -
                      </pre>
                      <p>Welcome canary into your heart:</p>
                      <pre>
                        apt-get update <br/>
                        apt-get install canary-agent
                      </pre>

                      <p>Setup the agent</p>
                      <pre>canary-agent --init dd6bc9064adf782b2924da728fcab9bb</pre>
                      <p>It will prompt you for the location of any apps you have installed. </p>
                      <p>Start the daemon</p>
                      <pre>start canary-agent</pre>
                      <p>Once you're done, check back here. We'll wait</p>
                    </div>
                  </section>
                </div>

                <div clasName="event-actions">
                  <section>
                    <div className="action-bar">
                      <div className="pull-right">
                        <Eui_button href={this.addServer} value="This is a demo. Pretend that I did this." />
                      </div>
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
