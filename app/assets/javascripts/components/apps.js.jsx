var NewApp= React.createClass({

  componentDidMount: function() {
  },


  render: function(){

    return (
      <div>
        <div className="navigation">
          <Navbar />
        </div>
        <div id="main" className="main-drawer container">
          <section>
            <div className="col-sm-12">
              <h1>Add an app</h1>
            </div>
          </section>
        </div>
      </div>
    )
  }
});


