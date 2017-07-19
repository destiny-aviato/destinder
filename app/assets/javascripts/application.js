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
//= require jquery.turbolinks
//= require materialize
//= require jquery_ujs
//= require jquery-ui
//= require jquery.slick
//= require initialize
//= require_self
//= require turbolinks
//= require materialize-sprockets
//= require materialize/extras/nouislider
//= require_tree .

$(document).on('turbolinks:load', function() {
    if ($("#tabs").length) {
        $("#tabs").tabs({
            beforeActivate: function(event, ui) {
                var div = ui.newPanel.attr('id');
                var title = '';
                switch (div) {
                    case 'trials':
                        title = "Trials of Osiris"
                        break;
                    case 'raids':
                        title = "Raids"
                        break;
                    case 'pvp':
                        title = "PVP"
                        break;
                    case 'profile':
                        title = "Profile"
                        break;
                }

                $('h2.subtitle.profile').text(title);
            }
        });
    }
    $('.collapsible').collapsible();
    $(".button-collapse").sideNav();

    $('.carousel').carousel();
    $('ul.tabs').tabs();

    Materialize.updateTextFields();
});





//allow close out functionality for notifications 
$(document).on('click', '.notification > button.delete', function() {
    $(this).parent().addClass('is-hidden');
    return false;
});

//Handle hamburger menu 
jQuery(document).ready(function($) {

    var $toggle = $('#navbar-burger');
    var $menu = $('#navbar-menu');

    $toggle.click(function() {
        $(this).toggleClass('is-active');
        $menu.toggleClass('is-active');
    });
});


// // Get the modal
// var modal = document.getElementById('myModal');

// // Get the button that opens the modal
// var btn = document.getElementById("myBtn");

// // Get the <span> element that closes the modal
// var span = document.getElementsByClassName("close")[0];

// // When the user clicks on the button, open the modal 
// btn.onclick = function() {
//     modal.style.display = "block";
// }

// // When the user clicks on <span> (x), close the modal
// span.onclick = function() {
//     modal.style.display = "none";
// }

// // When the user clicks anywhere outside of the modal, close it
// window.onclick = function(event) {
//     if (event.target == modal) {
//         modal.style.display = "none";
//     }
// }


function openNav() {
    document.getElementById("sideNavigation").style.width = "250px";
    document.getElementById("main").style.marginLeft = "250px";
}

function closeNav() {
    document.getElementById("sideNavigation").style.width = "0";
    document.getElementById("main").style.marginLeft = "0";
}

$(document).ready(function() {
    // the "href" attribute of the modal trigger must specify the modal ID that wants to be triggered
    $('.modal').modal();
});




$('.modal').modal({
    dismissible: true, // Modal can be dismissed by clicking outside of the modal
    opacity: .5, // Opacity of modal background
    inDuration: 300, // Transition in duration
    outDuration: 200, // Transition out duration
    startingTop: '4%', // Starting top style attribute
    endingTop: '10%', // Ending top style attribute
    ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
        alert("Ready");
        console.log(modal, trigger);
    },
    complete: function() { alert('Closed'); } // Callback for Modal close
});

$('#modal1').modal('open');

$('#modal1').modal('close');

$('#modal2').modal('open');

$('#modal2').modal('close');

$('#modal3').modal('open');

$('#modal3').modal('close');

$('#modal4').modal('open');

$('#modal4').modal('close');

$('#modal5').modal('open');

$('#modal5').modal('close');


$('.tap-target').tapTarget('open');
$('.tap-target').tapTarget('close');


var options = [{

        selector: '#staggered-test',
        offset: 255,
        callback: function(el) {
            Materialize.showStaggeredList($(el));
        }
    },

];
Materialize.scrollFire(options);

$(document).ready(function() {
    $('.parallax').parallax();
});