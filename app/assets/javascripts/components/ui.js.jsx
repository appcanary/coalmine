var Eui_button = React.createClass({
  render: function() {
    var btn_type = this.props.style || "default"
    return (
      <eui-button className={"ember-view eui-button-medium-" + btn_type}>
        <button aria-label={this.props.value}></button>
        <div className="eui-component">
          <div className="eui-component-wrapper">
            <div className="eui-label">
              <a href="" className="eui-label-value" onClick={this.props.href}>
                {this.props.value}
              </a>
            </div>
          </div>
        </div>
      </eui-button>
    )
  }
});
