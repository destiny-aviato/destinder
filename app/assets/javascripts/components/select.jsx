var UserSelect = React.createClass({
    render: function () {
        var userLIs = this.props.users.map(function(user, i){
            // return statement goes here:
            return <option value={user.id}>{user.display_name}</option>;
        });

        return (
            
           <select class="js-example-responsive" id="e1" multiple="multiple" >
               <optgroup label="Xbox">
                    {userLIs}
                </optgroup>
            </select>
        )
    }
});