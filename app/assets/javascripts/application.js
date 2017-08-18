// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require jquery-ui
//= require jquery.slick
//= require initialize
//= require_self
//= require typed
//= require turbolinks
//= require materialize-sprockets
//= require materialize/extras/nouislider
//= require_tree .

$(document).on("turbolinks:click", function() {
    $(".se-pre-con").show();
    $('.turbolinks-progress-bar').show();
});

$(document).on("turbolinks:load", function() {
    $(".se-pre-con").fadeOut("slow");
});

$(document).on('turbolinks:load', function() {

    $('#game-select').material_select();
    $('.game_type_select').change(function() {
        $("#filter_game_form").submit();
    });

    $('div#difficulty').hide();
    $('#checkpoint').hide();
    $('#micropost_raid_difficulty').val('Normal');

    $("#micropost_raid_difficulty").click(function() {
        if ($('#micropost_raid_difficulty').prop('checked')) {
            $('#micropost_raid_difficulty').val('Hard');
        } else {
            $('#micropost_raid_difficulty').val('Normal');
        }
    });

    // if ($("#tabs").length) {
    //     $("#tabs").tabs({
    //         beforeActivate: function(event, ui) {
    //             var div = ui.newPanel.attr('id');
    //             var title = '';
    //             switch (div) {
    //                 case 'trials':
    //                     title = "Trials of Osiris"
    //                     break;
    //                 case 'raids':
    //                     title = "Raids"
    //                     break;
    //                 case 'pvp':
    //                     title = "PVP"
    //                     break;
    //                 case 'profile':
    //                     title = "Profile"
    //                     break;
    //             }

    //             $('h2.subtitle.profile').text(title);
    //         }
    //     });
    // }
    $('.collapsible').collapsible();
    $(".button-collapse").sideNav({
        closeOnClick: true,
        draggable: true
    });

    $('.carousel').carousel();
    $('ul.tabs').tabs();

    Materialize.updateTextFields();

    $('.tap-target').tapTarget('open');
    $('.tap-target').tapTarget('close');


    $('.parallax').parallax();
    $('.tooltipped').tooltip({ delay: 50 });


    $('#game-select').change(function() {
        selection = $(this).val();

        if (selection != 'Trials of Osiris' && selection != "Nightfall") {
            $('div#difficulty').show();
            $('#checkpoint').show();
        } else {
            $('div#difficulty').hide();
            $('#checkpoint').hide();
        }

    });

});




//allow close out functionality for notifications 
$(document).on('click', '.notification > button.delete', function() {
    $(this).parent().addClass('is-hidden');
    return false;
});


// function openNav() {
//     document.getElementById("sideNavigation").style.width = "250px";
//     document.getElementById("main").style.marginLeft = "250px";
// }

// function closeNav() {
//     document.getElementById("sideNavigation").style.width = "0";
//     document.getElementById("main").style.marginLeft = "0";
// }

$(document).on("turbolinks:load", function() {
    // $('.modal').modal();
    $('.modal').modal({
        dismissible: true,
        opacity: .5, 
        inDuration: 300, 
        outDuration: 200, 
        startingTop: '4%', 
        endingTop: '10%'
    });

    $('#team-search-modal').modal('open');

    $('#team-search-modal').modal('close');
});


$(document).on("turbolinks:load", function() {

    $(document).ready(function() {
        $('.parallax').parallax();
    });

    $(document).ready(function() {
        $('.materialboxed').materialbox();
    });

    $(document).ready(function() {
        $('.slider').slider();
    });

    $('.slider').slider('pause');
    // Start slider
    $('.slider').slider('start');
    // Next slide
    $('.slider').slider('next');
    // Previous slide
    $('.slider').slider('prev');

    $("h1#home-header").hide().fadeIn(4000);
});