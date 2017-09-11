var UserSelectD1 = React.createClass({
    render: function () {
        var userLIs = this.props.users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });

        return (
            
           <select id="tags-d1" multiple="multiple" name='micropost[fireteam][]'>
               <optgroup label="Users">
                    {userLIs}
                </optgroup>
            </select>
        )
    }
});

var UserSelectD2 = React.createClass({
    render: function () {
        var userLIs = this.props.users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });
    
        return (
            
           <select id="tags-d2" multiple="multiple" name='micropost[fireteam][]'>
               <optgroup label="Users">
                    {userLIs}
                </optgroup>
            </select>
        )
    }
});