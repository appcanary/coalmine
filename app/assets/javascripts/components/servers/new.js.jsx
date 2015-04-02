var NewServer = React.createClass({
  componentDidMount: function() {
    $(React.findDOMNode(this)).find(".event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  },


  create_server: function(e) {
    Canary.Herald.trigger("servers-create")(e);   
  },

  render: function() {
    return (
      <AppLayout>

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
                    <p>It looks like you're using Ubuntu!</p>
                    <p>Add us to your apt sources</p>
                    <pre>                                                
                      echo deb <span className="blur">https://apt.appcanary.com/debian/</span> appcanary non-free &gt;&gt; \ <br/>
                      &nbsp;&nbsp;/etc/apt/sources.list.d/appcanary.list
                    </pre>
                    <p>Put your trust in us:</p>
                    <pre>
                      wget -O- <span className="blur">https://dist.appcanary.com/apt/canary.gpg</span> | apt-key add -
                    </pre>
                    <p>Welcome canary into your heart:</p>
                    <pre>
                      apt-get update <br/>
                      apt-get install canary-agent
                    </pre>

                    <p>Setup the agent</p>
                    <pre>canary-agent --init <span className="blur">dd6bc9064adf782b2924da728fcab9bb</span></pre>
                    <p>It will prompt you for the location of any apps you have installed. </p>
                    <p>Start the daemon</p>
                    <pre>start canary-agent</pre>
                  </div>
                </section>
              </div>

              <div clasName="event-actions">
                <section>
                  <div className="action-bar">
                    <div className="pull-right">
                      <Eui_button href={this.create_server} value="This is a demo. Pretend that I did this." style="primary" />
                    </div>
                  </div>
                </section>
              </div>
            </div>
          </div>
        </section>

      </AppLayout>
    )
  }
});
