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
      </div>
    )
  }
});
