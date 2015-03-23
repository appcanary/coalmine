var AvatarWidget = React.createClass({
  render: function() {
    var size = this.props.size || ""
    return (
      <span>
        <img src={"data:image.png;base64," + this.props.image} className={"icon " + size} />
        <strong>&nbsp;<a href="#">{this.props.name}</a></strong>
      </span>

    );
  }
});
