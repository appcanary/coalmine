var AppLayout = React.createClass({
  render: function() {

    return (
      <div>
        <div className="navigation">
          <Navbar />
        </div>
        <div id="main" className="main-drawer container">
          {this.props.children}
        </div>
        <DemoGuide />
      </div>
    )
  }
});


var DemoGuide = React.createClass({
  componentDidMount: function() {
    if(Canary.demo_mounted === undefined) {
      $("#demo-drawer").velocity("transition.slideUpIn", 2000).velocity({opacity: 0.9});
      Canary.demo_mounted = true;
    } 
  },
  render: function() {
    return (
      <div id="demo-drawer">
        <div className="container">
          <section>
            <div className="col-sm-10">
              <h3>Oh, look. You've added a server! We're scanning it for applications.</h3>
            </div>
            <div className="col-sm-2">
              <div style={{marginTop: "20px"}}>
                <Eui_button value="Simulate the passage of time" style="primary" />
              </div>
            </div>
          </section>
        </div>
      </div>
    )
  }
});
