var React = require('react');
var Eui_button = require("./eui");

var Onboard = React.createClass({
  render: function() {
    return (
      <div id="main" className="container">
      <section>
        <div className="onboard-box">
          <div className="onboard-wrapper">
            <section>
              <div className="onboard-logo">
                <img src={assets_path.logo} />
              </div>
            </section>

            <section>
              <div className="onboard-desc">
                <h3>Welcome!</h3>
                <h4>Is this page necessary?</h4>
                <ol>
                  <li>Canary works by continously monitoring your infrastructure.</li>
                  <li>Normally, you'd install our agent on a server. We're going to mock this out.</li>
                  <li>We've prepared a quick tour for you. Click on the button that will appear at the bottom right to TRAVEL THROUGH TIME.</li>
                </ol>
              </div>
            </section>


            <section>
              <div className="action-bar">
                <div className="pull-right">
                  <Eui_button value="Great. Get started!" href={Canary.Herald.trigger("welcome-add-app")} />
                </div>

              </div>
            </section>

          </div>
        </div>
      </section>
    </div>
    )
  }
})

module.exports = Onboard
