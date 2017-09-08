var UserSelectD1 = React.createClass({
    render: function () {
        var xbUserLIs = this.props.xb_users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });

        var psUserLIs = this.props.ps_users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });

        return (
            
           <select id="tags-d1" multiple="multiple" name='micropost[fireteam][]'>
               <optgroup label="Xbox">
                    {xbUserLIs}
                </optgroup>
               <optgroup label="Playstation">
                    {psUserLIs}
                </optgroup>
            </select>
        )
    }
});

var UserSelectD2 = React.createClass({
    render: function () {
        var xbUserLIs = this.props.xb_users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });

        var psUserLIs = this.props.ps_users.map(function(user, i){
            return <option key={user.id} value={user.id}>{user.display_name}</option>;
        });

        return (
            
           <select id="tags-d2" multiple="multiple" name='micropost[fireteam][]'>
               <optgroup label="Xbox">
                    {xbUserLIs}
                </optgroup>
               <optgroup label="Playstation">
                    {psUserLIs}
                </optgroup>
            </select>
        )
    }
});