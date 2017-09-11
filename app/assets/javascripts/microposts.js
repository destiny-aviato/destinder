// app/assets/javascripts/microposts.js

$(document).on('turbolinks:load', function(){
    
    if ($("select").length) {
        $('select').material_select();
    }

    $('.scroller-test').on('swipe', function(event, slick, direction){
        console.log(direction);
        // left
        $('ul.tabs').tabs();
      });

    var options = [
        {selector: 'div#post-fire', offset: 0, callback: function(el) {
        // Materialize.toast("Hey! You can choose a game mode for Destiny 2, but your new characters won't pull in quite yet. Pardon our dust!", 5000 );
        console.log("I see you.");
        } }
      ];
      Materialize.scrollFire(options);


      $('input#elo_min').val(null);
      $('input#elo_max').val(null);
      $('input#kd_min').val(null);
      $('input#kd_max').val(null);
  });