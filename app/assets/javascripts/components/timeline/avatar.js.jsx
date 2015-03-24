var AvatarWidget = React.createClass({
  render: function() {
    var size = this.props.size || ""
    return (
      <span>
        <img src={"data:image.png;base64," + this.props.model.avatar} className={"icon " + size} onClick={this.props.onClicked}/>
        <strong>&nbsp;<a href="#" onClick={this.props.onClicked}>{this.props.model.name}</a></strong>
      </span>

    );
  }
});
