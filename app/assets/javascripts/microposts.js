// app/assets/javascripts/microposts.js

$(document).on('turbolinks:load', function(){
    
    if ($("select").length) {
        $('select').material_select();
    }

  });