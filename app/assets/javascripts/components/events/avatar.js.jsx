var React = require("react");
var AvatarWidget = React.createClass({
  render: function() {
    var size = this.props.size || ""
    var handler = this.props.onClicked || function(e) {e.preventDefault()}
    return (
      <span>
        <img src={"data:image.png;base64," + this.props.model.avatar} className={"icon " + size} onClick={this.props.onClicked}/>
        <strong>&nbsp;<a href= "#" onClick={handler}>{this.props.model.name}</a></strong>
      </span>

    );
  }
});

module.exports = AvatarWidget;
