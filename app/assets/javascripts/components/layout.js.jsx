var AppLayout = React.createClass({
  getInitialState: function() {
    return {
      tour_tick: Canary.current_user.tour_tick(),
    }
  },


  componentWillMount: function() {
    Canary.Herald.register_action({
      "advance-tour": function() {
        var tour_tick = this.state.tour_tick + 1;
        this.setState({tour_tick: tour_tick});
      }.bind(this)
    });

  },

  render: function() {
    var demo = ""
    if(Canary.current_user.tour_tick() > 0 && Canary.current_user.tour_tick() < LeDemo.messages.length + 1) {
      demo = <DemoGuide message={LeDemo.currentMessage(this.state.tour_tick)} buttonValue={LeDemo.currentButton(this.state.tour_tick)}/>
    }



    return (
      <div>
        <div className="navigation">
          <Navbar />
        </div>
        <div id="main" className="main-drawer container">
          {this.props.children}
        </div>
        {demo}
      </div>
    )
  }
});

var LeDemo = {
  messages: [
    "You've added your first server! We're going to scan it for applications.",
    "Sweet! We found two apps. What happens a new vulnerability comes out?",
    "Oh no! One of your apps is vulnerable. We've notified you via email.",
    "Awesome. You updated your gems. But what about your servers?",
    "Oh jeez, Heartbleed is on CNN! But we got your back.",
    "Good job. This concludes the tour. Feel free to poke around; this resets on logout",
  ],

  currentMessage: function(i) {
    return this.messages[i-1];
  },

  currentButton: function(i) {
    if(i == this.messages.length) {
      return "Awesome."
    } else {
      return "Simulate the passage of time"
    }
  }
}

var DemoGuide = React.createClass({
  
  componentDidMount: function() {
    if(Canary.demo_mounted === undefined) {
      $("#demo-drawer").velocity("transition.slideUpIn", 2000).velocity({opacity: 0.9});
      Canary.demo_mounted = true;
    }


     
  },
  render: function() {
    var drawer =  (
      <div id="demo-drawer">
        <div className="container">
          <section>
            <div className="col-sm-10">
              <h3>{this.props.message}</h3>
            </div>
            <div className="col-sm-2">
              <div style={{marginTop: "20px"}}>
                <Eui_button value={this.props.buttonValue} style="primary" href={Canary.Herald.trigger("advance-tour")} />
              </div>
            </div>
          </section>
        </div>
      </div>
    )

    return drawer;
  }
});
