var Sidepanel = React.createClass({
  componentDidMount: function() {
     $(".app-sidepanel").velocity({'z-index': -1 }).velocity("transition.slideLeftBigIn", 400);
  },
  render: function() {
    return (
      <div className="app-sidepanel">
        <section>
          <div className="nav-identity">
            <p>
              <a className="dashboard"><b className='eui-trailing-icon fa fa-angle-double-left'></b> Dashboard</a>
            </p>
            <h3>ServerNameHere</h3>
          </div>
        </section>
        <section>
          <div className="col-md-12">

            <ul className="nav nav-tabs">
              <li role="presentation" className="active"><a href="#">Production</a></li>
              <li role="presentation"><a href="#">Staging</a></li>
              <li role="presentation"><a href="#">Dev</a></li>
            </ul>

            <table className="table unstyled info">
              <tr>
                <td>
                  <strong>Last Updated</strong>
                </td>
                <td>
                  <span className="timestamp" title=''></span>
                </td>
              </tr>


              <tr>
                <td>
                  <strong>Platforms</strong>
                </td>
                <td className="platforms">
                  Ruby
                </td>
              </tr>


              <tr>
                <td>
                  <strong>Rubygems</strong>
                </td>
                <td>
                  <span>
                    35-40
                  </span>
                  <i className="fa fa-angle-right pull-right"></i>
                </td>
              </tr>

            </table>

            <section className="issues-nav">
              <div className="all-issues">
                <h4 className="selected">All issues <span className="pull-right"><i className="fa fa-angle-right"></i></span></h4>
              </div>
            </section>

            <table className="table issues">
              <tr className="">
                <td>
                  Active
                </td>
                <td>
                  <span>2 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>

              <tr>
                <td>
                  Resolved
                </td>
                <td>
                  <span>56 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>

              <tr>
                <td>
                  Ignored
                </td>
                <td>
                  <span>3 <i className="fa fa-angle-right"></i></span>
                </td>
              </tr>
            </table>
          </div>
        </section>
      </div>

    )
  }
});
