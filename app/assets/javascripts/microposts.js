// app/assets/javascripts/microposts.js

$(document).on('turbolinks:load', function(){
    
    if ($("select").length) {
        $('select').material_select();
    }

    var options = [
        {selector: 'div#post-fire', offset: 0, callback: function(el) {
          Materialize.toast("Really? Is if that hard to find someone?", 4000 );
        } }
      ];
      Materialize.scrollFire(options);

  });