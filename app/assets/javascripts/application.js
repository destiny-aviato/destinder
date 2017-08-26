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
//= require tooltipster.bundle.min
//= require Chart.min
//= require react
//= require react_ujs
//= require components
//= require_tree .

$(document).on("turbolinks:click", function() {
    $(".se-pre-con").show();
    $('.turbolinks-progress-bar').show();
});

$(document).on("turbolinks:load", function() {
    $(".se-pre-con").fadeOut("slow");
});

$(document).on('turbolinks:load', function() {

    $('#pve-game-select').material_select();
    $('#pvp-game-select').material_select();

    $('.game_type_select').change(function() {
        $('#new-post-modal').modal('close');
        $("#filter_game_form").submit();
    });

    // $('.microphone_select').change(function() {
    //     $('#new-post-modal').modal('close');
    //     $("#filter_game_form").submit();
    // });

    $('.looking_for_select').change(function() {
        $('#new-post-modal').modal('close');
        $("#filter_game_form").submit();
    });

    $('#checkpoint').hide();
    $('div#difficulty').hide();
    $('label.difficulty-label').hide();
    
    $('#micropost_raid_difficulty').val('Normal');

    $("#micropost_raid_difficulty").click(function() {
        if ($('#micropost_raid_difficulty').prop('checked')) {
            console.log("checked! setting to hard");
            $('#micropost_raid_difficulty').val('Hard');
        } else {
            $('#micropost_raid_difficulty').val('Normal');
            console.log("unchecked! setting to normal");
        }
    });

    // $("#micropost_mic_required").click(function() {
    //     if ($('#micropost_mic_required').prop('checked')) {
    //         $('#micropost_mic_required').val(true);
    //     } else {
    //         $('#micropost_mic_required').val(false);
    //     }
    // });

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
    $('.tooltipped').tooltip({ 
        delay: 50,
        html: true
     });


    $('#pve-game-select').change(function() {
        selection = $(this).val();
        

        if ($.inArray(selection, ["Wrath of the Machine", "King's Fall", "Crota's End", "Vault of Glass"]) >= 0) {
            $('#pve-gametype-select').attr('class', 'input-field col s12 m6');
            $('div#difficulty').show();
            $('label.difficulty-label').show();
            $('#checkpoint').show();
        } else {
            $('#pve-gametype-select').attr('class', 'input-field col s12');
            $('div#difficulty').hide();
            $('label.difficulty-label').hide();
            $('#checkpoint').hide();
        }

    });

});




//allow close out functionality for notifications 
$(document).on('click', '.notification > button.delete', function() {
    $(this).parent().addClass('is-hidden');
    return false;
});


$(document).on("turbolinks:load", function() {
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
    $('.tooltip').tooltipster({ 
        theme: ['tooltipster-noir', 'tooltipster-noir-customized'],
        delay: 50
    });

    //////// WEAPON CHARTS ////////////
    if ($(".chart-container1").length) {
        var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
        // var char_data = chart_data[0];
        var weaponctx1 = document.getElementById("weapon-breakdown-chart1").getContext('2d');
        var weaponChart1 = new Chart(weaponctx1, {
          type: 'polarArea',
          data: {
            labels: ["Auto Rifle", "Hand Cannon", "Pulse Rifle", "Scout Rifle", "Sniper", "Shotgun"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#95a5a6",
                "#9b59b6",
                "#f1c40f",
                "#e74c3c",
                "#34495e"
              ],
              data: [char_data1["Character Stats"]["Kill Stats"]["Auto Rifle"], char_data1["Character Stats"]["Kill Stats"]["Hand Cannon"], char_data1["Character Stats"]["Kill Stats"]["Pulse Rifle"], char_data1["Character Stats"]["Kill Stats"]["Scout Rifle"], char_data1["Character Stats"]["Kill Stats"]["Sniper"], char_data1["Character Stats"]["Kill Stats"]["Shotgun"]]
            }]
          }
        });
    
        var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
        // var char_data = chart_data[0];
        var weaponctx2 = document.getElementById("weapon-breakdown-chart2").getContext('2d');
        var weaponChart2 = new Chart(weaponctx2, {
          type: 'polarArea',
          data: {
            labels: ["Auto Rifle", "Hand Cannon", "Pulse Rifle", "Scout Rifle", "Sniper", "Shotgun"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#95a5a6",
                "#9b59b6",
                "#f1c40f",
                "#e74c3c",
                "#34495e"
              ],
              data: [char_data2["Character Stats"]["Kill Stats"]["Auto Rifle"], char_data2["Character Stats"]["Kill Stats"]["Hand Cannon"], char_data2["Character Stats"]["Kill Stats"]["Pulse Rifle"], char_data2["Character Stats"]["Kill Stats"]["Scout Rifle"], char_data2["Character Stats"]["Kill Stats"]["Sniper"], char_data2["Character Stats"]["Kill Stats"]["Shotgun"]]
            }]
          }
        });
    
        var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
        var weaponctx3 = document.getElementById("weapon-breakdown-chart3").getContext('2d');
        var weaponChart3 = new Chart(weaponctx3, {
          type: 'polarArea',
          options: {
            layout: {
                padding: {
                    top: 20
                    }
                }
            },
          data: {
            labels: ["Auto Rifle", "Hand Cannon", "Pulse Rifle", "Scout Rifle", "Sniper", "Shotgun"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#95a5a6",
                "#9b59b6",
                "#f1c40f",
                "#e74c3c",
                "#34495e"
              ],
              data: [char_data3["Character Stats"]["Kill Stats"]["Auto Rifle"], char_data3["Character Stats"]["Kill Stats"]["Hand Cannon"], char_data3["Character Stats"]["Kill Stats"]["Pulse Rifle"], char_data3["Character Stats"]["Kill Stats"]["Scout Rifle"], char_data3["Character Stats"]["Kill Stats"]["Sniper"], char_data3["Character Stats"]["Kill Stats"]["Shotgun"]]
            }]
          }
        });
    
        //////// ABILITY CHARTS ////////////
        // var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
        var abilityctx1 = document.getElementById("ability-chart-breakdown1").getContext('2d');
        var abilityChart1 = new Chart(abilityctx1, {
          type: 'doughnut',
          data: {
            labels: ["Intellect", "Discipline", "Strength"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#34495e"
              ],
              data: [char_data1["Character Stats"]["Intellect"], char_data1["Character Stats"]["Discipline"], char_data1["Character Stats"]["Strength"]]
            }]
          }
        });
    
        // var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
        var abilityctx2 = document.getElementById("ability-chart-breakdown2").getContext('2d');
        var abilityChart2 = new Chart(abilityctx2, {
          type: 'doughnut',
          data: {
            labels: ["Intellect", "Discipline", "Strength"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#34495e"
              ],
              data: [char_data2["Character Stats"]["Intellect"], char_data2["Character Stats"]["Discipline"], char_data2["Character Stats"]["Strength"]]
            }]
          }
        });
    
        // var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
        var abilityctx3 = document.getElementById("ability-chart-breakdown3").getContext('2d');
        var abilityChart3 = new Chart(abilityctx3, {
          type: 'doughnut',
          data: {
            labels: ["Intellect", "Discipline", "Strength"],
            datasets: [{
              backgroundColor: [
                "#2ecc71",
                "#3498db",
                "#34495e"
              ],
              data: [char_data3["Character Stats"]["Intellect"], char_data3["Character Stats"]["Discipline"], char_data3["Character Stats"]["Strength"]]
            }]
          }
        });
     }
    





});