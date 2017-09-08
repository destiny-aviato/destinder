var UserSelect = React.createClass({
    render: function () {
        var xbUserLIs = this.props.xb_users.map(function(user, i){
            return <option value={user.id}>{user.display_name}</option>;
        });

        var psUserLIs = this.props.ps_users.map(function(user, i){
            return <option value={user.id}>{user.display_name}</option>;
        });

        return (
            
           <select class="js-example-responsive" id="e1" multiple="multiple" >
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