var Eui_button = React.createClass({

  handleClick: function(e) {
    e.preventDefault();
    if(this.props.href !== undefined) {
      this.props.href(e);
    } else {
      $(React.findDOMNode(this)).tooltip({title: "Sorry! Not in this demo."}).tooltip("show");
    }
  },
  render: function() {
    var btn_type = this.props.style || "default"
    return (
      <eui-button className={"ember-view eui-button-medium-" + btn_type}>
        <button aria-label={this.props.value}></button>
        <div className="eui-component">
          <div className="eui-component-wrapper">
            <div className="eui-label">
              <a href="#" className="eui-label-value" onClick={this.handleClick}>
                {this.props.value}
              </a>
            </div>
          </div>
        </div>
      </eui-button>
    )
  }
});
