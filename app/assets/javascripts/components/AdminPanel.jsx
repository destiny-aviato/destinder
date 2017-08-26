var people = ['Rowe', 'Prevost', 'Gare'];
 
var peopleLIs = people.map(function(person, i){
    // return statement goes here:
    return <li key={'person_' + i}>{person}</li>;
});

var TestingClass = React.createClass({
    render: function() {
    return (
        <ul>{peopleLIs}</ul>
    );
  }
});

var data = [{ a: 1, b: 2 }];

var Hello = React.createClass({
    render: function() {
    return (
        <div>
            <pre>{JSON.stringify(data, null, 2) }</pre>
            <p>{data[0]["a"]}</p>
        </div>
        );
    }
});

var AdminPanel = React.createClass({
    
  render: function() {

    return (
        <div>           
            <p>Character type: {this.props.chartData[0]["Character Type"]}</p>
        </div>  
          
    );
  }
});

var Navigation = React.createClass({
    getDefaultProps: function() {
      return { 
        tabList: [
          {
            id: 1,
            title: "Manage Posts",
            className: "tab col s4 active",
            paneId: "manage-pane",
            component: ManagePosts
          },
          {
            id: 2,
            title: "Create Post",
            className: "tab col s4",
            paneId: "create-pane",
            component: CreatePost
          },
          {
            id: 3,
            title: "Preview Post",
            className: "tab col s4",
            paneId: "preview-pane",
            component: PreviewPost
          }
        ]
      }
    },
    render: function() {
      return (
        <div>
          <NavTabs data={this.props.tabList}/>
          <NavPanes data={this.props.tabList}/>
        </div>
      );
    }
  });

  var ManagePosts = React.createClass({
    render: function() {
        return (
            <p>ManagePosts Pane</p>
        );
    }
});

var CreatePost = React.createClass({
    render: function() {
        return (
            <p>CreatePost Pane</p>
        );
    }   
});

var PreviewPost = React.createClass({
    render: function() {
        return (
            <p>PreviewPost Pane</p>
        );
    }
});

var NavTabs = React.createClass({
  render: function() {
    var tabList = this.props.data.map(function(tab) {
      return (
        <Tab key={tab.id} data={tab} />
      );
    });
    return (
      <ul className="tabs tabs-fixed-width">
        {tabList}
      </ul>
    );
  }
});

var Tab = React.createClass({
  render: function() {
    return (
      <li role="presentation" className={this.props.data.className}>
        <a href={"#"+this.props.data.paneId} data-toggle="tab">
          {this.props.data.title}
        </a>
      </li>  
    );
  }
});

var NavPanes = React.createClass({
  render: function() {
    var paneList = this.props.data.map(function(pane) {
      return (
        <Pane key={pane.id} data={pane} />
      );
    });
    return (
      <div className="tab-content">
        {paneList}
      </div>
    );
  }
});

var Pane = React.createClass({
  render: function() {
    return (
      <div role="tabpanel" className={this.props.data.className} className={"tab-pane "+this.props.data.className} id={this.props.data.paneId}>
        {this.props.data.title}
      </div>
    );
  }
});