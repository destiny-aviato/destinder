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
        selection = $(this).val();

        if (selection == "Trials of Osiris") {
            $('#filter-sliders').show();
        } else {
            $('#filter-sliders').hide();
        }
        // $('#new-post-modal').modal('close');
        // $("#filter_game_form").submit();
    });



    // $('.microphone_select').change(function() {
    //     $('#new-post-modal').modal('close');
    //     $("#filter_game_form").submit();
    // });



    $('.looking_for_select').change(function() {
        // $('#new-post-modal').modal('close');
        // $("#filter_game_form").submit();
    });

    $('div#checkpoint').hide();
    $('div#difficulty').hide();
    $('label.difficulty-label').hide();
    $('div#checkpoint').hide();
    $('#filter-sliders').hide();

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



      function onElementRendered(selector, cb, _attempts) {
        var el = $(selector);
        _attempts = ++_attempts || 1;
        if (el.length) return cb(el);
        if (_attempts == 60) return;
        setTimeout(function() {
          onElementRendered(selector, cb, _attempts);
        }, 250);
      }

      function openCharts() {
        //////// WEAPON CHARTS ////////////

        if ($(".chart-container1").length) {
            var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
            // var char_data = chart_data[0];
            var weaponctx1 = document.getElementById("weapon-breakdown-chart1").getContext('2d');
            var auto1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Auto Rifle"]);
            var hand1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Hand Cannon"]);
            var pulse1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Pulse Rifle"]);
            var scout1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Scout Rifle"]);
            var sniper1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Sniper"]);
            var shotgun1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Shotgun"]);
            var total_kills1 =  (auto1 + hand1 + pulse1 + scout1 + sniper1 + shotgun1);

            var weaponChart1 = new Chart(weaponctx1, {
            type: 'pie',
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
                data: [((auto1 / total_kills1) * 100).toFixed(0), ((hand1 / total_kills1) * 100).toFixed(0), ((pulse1 / total_kills1) * 100).toFixed(0), ((scout1 / total_kills1) * 100).toFixed(0), ((sniper1 / total_kills1) * 100).toFixed(0), ((shotgun1 / total_kills1) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    position: 'bottom',
                    labels: {
                        boxWidth: 15
                    }
                },
                title: {
                    display: true,
                    text: '% Kills by Weapon Types'
                }
            }
            });
        }
        
        if ($(".chart-container2").length) {
            var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
            // var char_data = chart_data[0];
            var weaponctx2 = document.getElementById("weapon-breakdown-chart2").getContext('2d');
            var auto2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Auto Rifle"]);
            var hand2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Hand Cannon"]);
            var pulse2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Pulse Rifle"]);
            var scout2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Scout Rifle"]);
            var sniper2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Sniper"]);
            var shotgun2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Shotgun"]);
            var total_kills2 =  (auto2 + hand2 + pulse2 + scout2 + sniper2 + shotgun2);
            var weaponChart2 = new Chart(weaponctx2, {
            type: 'pie',
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
                data: [((auto2 / total_kills2) * 100).toFixed(0), ((hand2 / total_kills2) * 100).toFixed(0), ((pulse2 / total_kills2) * 100).toFixed(0), ((scout2 / total_kills2) * 100).toFixed(0), ((sniper2 / total_kills2) * 100).toFixed(0), ((shotgun2 / total_kills2) * 100).toFixed(0)]
            }]
            },
            options: {
                legend: {
                    position: 'bottom',
                    labels: {
                        boxWidth: 15
                    }
                },
                title: {
                    display: true,
                    text: '% Kills by Weapon Types'
                }
            }
            });
        }
    
        if ($(".chart-container3").length) {
            var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
            var weaponctx3 = document.getElementById("weapon-breakdown-chart3").getContext('2d');
            var auto3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Auto Rifle"]);
            var hand3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Hand Cannon"]);
            var pulse3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Pulse Rifle"]);
            var scout3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Scout Rifle"]);
            var sniper3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Sniper"]);
            var shotgun3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Shotgun"]);
            var total_kills3 =  (auto3 + hand3 + pulse3 + scout3 + sniper3 + shotgun3);
            var weaponChart3 = new Chart(weaponctx3, {
            type: 'pie',
            options: {
                legend: {
                    position: 'bottom',
                    labels: {
                        boxWidth: 15
                    }
                },
                title: {
                    display: true,
                    text: '% Kills by Weapon Types'
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
                data: [((auto3 / total_kills3) * 100).toFixed(0), ((hand3 / total_kills3) * 100).toFixed(0), ((pulse3 / total_kills3) * 100).toFixed(0), ((scout3 / total_kills3) * 100).toFixed(0), ((sniper3 / total_kills3) * 100).toFixed(0), ((shotgun3 / total_kills3) * 100).toFixed(0)]
            }]
            }
            });
        }

        //////WINS CHARTS //////////
        if ($(".chart-container1").length) {
            var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
            var abilityctx1 = document.getElementById("ability-chart-breakdown1").getContext('2d');
            var win1 =  parseInt(char_data1["Character Stats"]["games_won"]);
            var loss1 =  parseInt(char_data1["Character Stats"]["games_lost"]);
            var total_games1 = parseInt(win1 + loss1);
            var abilityChart1 = new Chart(abilityctx1, {
            type: 'doughnut',
            data: {
                labels: ["Win", "Loss"],
                datasets: [{
                backgroundColor: [
                    "#2ecc71",
                    "#e74c3c"
                ],
                data: [((win1 / total_games1) * 100).toFixed(0), ((loss1 / total_games1) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Win %'
                }
            }
            });
        }
              
        if ($(".chart-container2").length) {
            var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
            var abilityctx2 = document.getElementById("ability-chart-breakdown2").getContext('2d');
            var win2 =  parseInt(char_data2["Character Stats"]["games_won"]);
            var loss2 =  parseInt(char_data2["Character Stats"]["games_lost"]);
            var total_games2 = parseInt(win2 + loss2);
            var abilityChart2 = new Chart(abilityctx2, {
            type: 'doughnut',
            data: {
                labels: ["Win", "Loss"],
                datasets: [{
                backgroundColor: [
                    "#2ecc71",
                    "#e74c3c"
                ],
                data: [((win2 / total_games2) * 100).toFixed(0), ((loss2 / total_games2) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Win %'
                }
            }
            });
        }

        if ($(".chart-container3").length) {
            var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
            var abilityctx3 = document.getElementById("ability-chart-breakdown3").getContext('2d');
            var win3 =  parseInt(char_data3["Character Stats"]["games_won"]);
            var loss3 =  parseInt(char_data3["Character Stats"]["games_lost"]);
            var total_games3 = parseInt(win3 + loss3);
            var abilityChart3 = new Chart(abilityctx3, {
            type: 'doughnut',
            data: {
                labels: ["Win", "Loss"],
                datasets: [{
                backgroundColor: [
                    "#2ecc71",
                    "#e74c3c"
                ],
                data: [((win3 / total_games3) * 100).toFixed(0), ((loss3 / total_games3) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Win %'
                }
            }
            });
        }

        //////REVIVES CHARTS //////////
        if ($(".chart-container1").length) {
            var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
            var revivectx1 = document.getElementById("revive-chart-breakdown1").getContext('2d');
            var given1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Revives Performed"]);
            var received1 =  parseInt(char_data1["Character Stats"]["Kill Stats"]["Revives Received"]);
            var total_revives1 = parseInt(given1 + received1);        

            var reviveChart1 = new Chart(revivectx1, {
            type: 'doughnut',
            data: {
                labels: ["Given", "Received"],
                datasets: [{
                backgroundColor: [
                    "#3498db",
                    "#95a5a6"
                ],
                data: [((given1 / total_revives1) * 100).toFixed(0), ((received1 / total_revives1) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Revives'
                }
            }
            });
        }

        if ($(".chart-container2").length) {
            var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
            var revivectx2 = document.getElementById("revive-chart-breakdown2").getContext('2d');
            var given2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Revives Performed"]);
            var received2 =  parseInt(char_data2["Character Stats"]["Kill Stats"]["Revives Received"]);
            var total_revives2 = parseInt(given2 + received2);
            

            var reviveChart2 = new Chart(revivectx2, {
            type: 'doughnut',
            data: {
                labels: ["Given", "Received"],
                datasets: [{
                backgroundColor: [
                    "#3498db",
                    "#95a5a6"
                ],
                data: [((given2 / total_revives2) * 100).toFixed(0), ((received2 / total_revives2) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Revives'
                }
            }
            });
        }

        if ($(".chart-container3").length) {
            var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
            var revivectx3 = document.getElementById("revive-chart-breakdown3").getContext('2d');
            var given3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Revives Performed"]);
            var received3 =  parseInt(char_data3["Character Stats"]["Kill Stats"]["Revives Received"]);
            var total_revives3 = parseInt(given3 + received3);

            var reviveChart3 = new Chart(revivectx3, {
            type: 'doughnut',
            data: {
                labels: ["Given", "Received"],
                datasets: [{
                backgroundColor: [
                    "#3498db",
                    "#95a5a6"
                ],
                data: [((given3 / total_revives3) * 100).toFixed(0), ((received3 / total_revives3) * 100).toFixed(0)]
                }]
            },
            options: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Revives'
                }
            }
            });
        }
                    

        //////// KILL CHARTS//////
        if ($(".chart-container1").length) {
            var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
            var killctx1 = document.getElementById('kill-chart-breakdown1').getContext('2d');
            var temp_data1 = []
            var temp_wins1 = []
            console.log(char_data1);
        
            $.each(char_data1["recent_games"].reverse(), function (index, value) {
                temp_data1.push(value["kd_ratio"]);
                temp_wins1.push(value["standing"]);
                
            });
        
            var pointBackgroundColors1 = [];
            for (i = 0; i < temp_wins1.length; i++) {
                if (temp_wins1[i] == 0) {
                    pointBackgroundColors1.push("#2ecc71");
                } else {
                    pointBackgroundColors1.push("#e74c3c");
                }
            }
        
            var killChart1 = new Chart(killctx1, {
                type: 'line',
                data: {
                    labels: ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
                    datasets: [{
                        fill: false,
                        label: 'KD',
                        data: temp_data1,
                        pointBackgroundColor: pointBackgroundColors1,
                        borderColor: "#A5A5AF",
                        pointBorderColor: "white",
                        pointRadius: 5,
                        borderWidth: 2
                    },
                    {
                        fill: false,
                        data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        backgroundColor: "#EEEEEE",
                        label: "",
                        borderColor: "black",
                        pointRadius: 0,
                        borderWidth: 1,
                        pointHoverRadius: 0
                    }]
                },
                options: {
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Recent Games'
                    },
                    layout: {
                        padding: {
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0
                        }
                    }
                }
            });
        }

        if ($(".chart-container2").length) {
            var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
            var killctx2 = document.getElementById('kill-chart-breakdown2').getContext('2d');
            var temp_data2 = []
            var temp_wins2 = []
            console.log(char_data2);
        
            $.each(char_data2["recent_games"].reverse(), function (index, value) {
                temp_data2.push(value["kd_ratio"]);
                temp_wins2.push(value["standing"]);
                
            });
        
            var pointBackgroundColors2 = [];
            for (i = 0; i < temp_wins2.length; i++) {
                if (temp_wins2[i] == 0) {
                    pointBackgroundColors2.push("#2ecc71");
                } else {
                    pointBackgroundColors2.push("#e74c3c");
                }
            }
        
            var killChart2 = new Chart(killctx2, {
                type: 'line',
                data: {
                    labels: ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
                    datasets: [{
                        fill: false,
                        label: 'KD',
                        data: temp_data2,
                        pointBackgroundColor: pointBackgroundColors2,
                        borderColor: "#A5A5AF",
                        pointBorderColor: "white",
                        pointRadius: 6,
                        borderWidth: 2
                    },
                    {
                        fill: false,
                        data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        backgroundColor: "#EEEEEE",
                        label: "",
                        borderColor: "black",
                        pointRadius: 0,
                        borderWidth: 1,
                        pointHoverRadius: 0
                    }]
                },
                options: {
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Recent Games'
                    }
                }
            });
        }

        if ($(".chart-container3").length) {
            var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
            var killctx3 = document.getElementById('kill-chart-breakdown3').getContext('2d');
            var temp_data3 = []
            var temp_wins3 = []
            console.log(char_data3);
        
            $.each(char_data3["recent_games"].reverse(), function (index, value) {
                temp_data3.push(value["kd_ratio"]);
                temp_wins3.push(value["standing"]);
                
            });
        
            var pointBackgroundColors3 = [];
            for (i = 0; i < temp_wins3.length; i++) {
                if (temp_wins3[i] == 0) {
                    pointBackgroundColors3.push("#2ecc71");
                } else {
                    pointBackgroundColors3.push("#e74c3c");
                }
            }
        
            var killChart3 = new Chart(killctx3, {
                type: 'line',
                data: {
                    labels: ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
                    datasets: [{
                        fill: false,
                        label: 'KD',
                        data: temp_data3,
                        pointBackgroundColor: pointBackgroundColors3,
                        borderColor: "#A5A5AF",
                        pointBorderColor: "white",
                        pointRadius: 5,
                        borderWidth: 2
                    },
                    {
                        fill: false,
                        data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        backgroundColor: "#EEEEEE",
                        label: "",
                        borderColor: "black",
                        pointRadius: 0,
                        borderWidth: 1,
                        pointHoverRadius: 0
                    }]
                },
                options: {
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Recent Games'
                    }
                }
            });
        }
      }
      
      function collapseAll(){
        $(".collapsible-header").removeClass(function(){
          return "active";
        });
        $(".collapsible").collapsible({accordion: true});
        $(".collapsible").collapsible({accordion: false});    
      }

      function expandAll(){
        $(".collapsible-header").addClass("active");
        $(".collapsible").collapsible({accordion: false});        
      }
      
      $("#expand-button").click(function() {
        expandAll();
      });


      $("#collapse-button").click(function() {
        collapseAll();
      });
      
      $("#update-form").click(function() {
        $("#filter_game_form").submit();
        $('#post-filter-modal').modal('close');
      });

      $("#post-submit").click(function() {
        $('.collapsible').collapsible('close', 0);
      });

      onElementRendered('#stat-graphs', function(el) {
        $('.collapsible').collapsible({
            onOpen: function(e) {
                openCharts();
             }
        });

        expandAll();
        collapseAll();
      });

      onElementRendered('#post-filter-modal', function(el) {
        if ($("#kd-slider").length) {

            var kdSlider = document.getElementById('kd-slider');
            kdSlider.style.width = '100%';
            kdSlider.style.margin = '0 auto 30px';
            noUiSlider.create(kdSlider, {
            start: [1.0, 2.0],
            connect: true,
            step: 0.1,
            tooltips: [ true, true ],
            orientation: 'horizontal', // 'horizontal' or 'vertical'
            range: {
            'min': 0.0,
            'max': 3.0
            },
            format: wNumb({
            decimals: 1
            })
            });
            


            var kdMin = document.getElementById('kd-field-min'),
            kdMax = document.getElementById('kd-field-max');
        
            kdSlider.noUiSlider.on('update', function ( values, handle ) {
                if ( handle ) {
                    kdMax.innerHTML = values[handle];
                } else {
                    kdMin.innerHTML = values[handle];
                }
            });

        
            var eloSlider = document.getElementById('elo-slider');
            eloSlider.style.width = '100%';
            eloSlider.style.margin = '0 auto 30px';
            noUiSlider.create(eloSlider, {
            start: [1000, 2000],
            connect: true,
            step: 100,
            orientation: 'horizontal', // 'horizontal' or 'vertical'
            range: {
            'min': 0,
            'max': 3000
            },
            format: wNumb({
            decimals: 0
            })
            });

            var eloMin = document.getElementById('elo-field-min'),
            eloMax = document.getElementById('elo-field-max');
        
            eloSlider.noUiSlider.on('update', function ( values, handle ) {
                if ( handle ) {                                                         
                    eloMax.innerHTML = parseInt(values[handle]).toFixed(0);
                    $('input#elo_max').val(parseInt(values[handle]).toFixed(0));
                } else {
                    eloMin.innerHTML = parseInt(values[handle]).toFixed(0);
                    $('input#elo_min').val(parseInt(values[handle]).toFixed(0));
                    
                }
            });
        }
      });




    $( ".collapsible-header" ).click(function() {
        $(".more",this).toggle()
        $(".less", this).toggle()
    });
        


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
            // $('label.checkpoint-label').show();
            $('div#checkpoint').show();
        } else {
            $('#pve-gametype-select').attr('class', 'input-field col s12');
            $('div#difficulty').hide();
            $('label.difficulty-label').hide();
            // $('label.checkpoint-label').hide();
            $('div#checkpoint').hide();
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

});