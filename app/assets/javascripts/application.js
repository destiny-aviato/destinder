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
//= require timeago
//= require_self
//= require typed
//= require select2
//= require turbolinks
//= require materialize-sprockets
//= require materialize/extras/nouislider
//= require tooltipster.bundle.min
//= require introjs
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

    $('#d1-game-select').material_select();
    $('#d2-game-select').material_select();
    // $('#pvp-game-select').material_select();

    $('.game_type_select').change(function() {
        selection = $(this).val();
        // console.log(selection);
        $("#game-type-filter").val(selection);
        if (selection == "Trials of Osiris" || selection == "Trials of the Nine") {
            $('#filter-sliders').show();
        } else {
            $('#filter-sliders').hide();
        }
        // $('#new-post-modal').modal('close');
        // $("#filter_game_form").submit();
    });

    $('.game_type_select2').change(function() {
        selection = $(this).val();
        // console.log(selection);
        $("#game-type-filter").val(selection);
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
    $('div#difficulty-d1').hide();
    $('div#difficulty-d2').hide();
    $('label.difficulty-label-d1').hide();
    $('label.difficulty-label-d2').hide();
    $('div#checkpoint-d1').hide();
    $('div#checkpoint-d2').hide();
    $('#filter-sliders').hide();

    $('#micropost_raid_difficulty_d1').val('Normal');
    $('#micropost_raid_difficulty_d2').val('Normal');

    $("#micropost_raid_difficulty_d1").click(function() {
        if ($('#micropost_raid_difficulty_d1').prop('checked')) {
            $('#micropost_raid_difficulty_d1').val('Heroic');
        } else {
            $('#micropost_raid_difficulty_d1').val('Normal');
        }
    });
    $('#micropost_raid_difficulty_d2').val('Normal');

    $("#micropost_raid_difficulty_d2").click(function() {
        if ($('#micropost_raid_difficulty_d2').prop('checked')) {
            $('#micropost_raid_difficulty_d2').val('Heroic');
        } else {
            $('#micropost_raid_difficulty_d2').val('Normal');
        }
    });

    $('#micropost_game_version').val('2');
    $("#d1-options").hide();

    $("#micropost_game_version").click(function() {
        if ($('#micropost_game_version').prop('checked')) {
            $('#micropost_game_version').val('2');
            $("#d1-options").hide();
            $("#d2-options").show();
        } else {
            $('#micropost_game_version').val('1');
            $("#d2-options").hide();
            $("#d1-options").show();
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
            var auto1 = parseInt(char_data1["character_stats"]["kill_stats"]["auto_rifle"]);
            var hand1 = parseInt(char_data1["character_stats"]["kill_stats"]["hand_cannon"]);
            var pulse1 = parseInt(char_data1["character_stats"]["kill_stats"]["pulse_rifle"]);
            var scout1 = parseInt(char_data1["character_stats"]["kill_stats"]["scout_rifle"]);
            var sniper1 = parseInt(char_data1["character_stats"]["kill_stats"]["sniper"]);
            var shotgun1 = parseInt(char_data1["character_stats"]["kill_stats"]["shotgun"]);
            var fusion1 = parseInt(char_data1["character_stats"]["kill_stats"]["fusion_rifle"]);
            var sidearm1 = parseInt(char_data1["character_stats"]["kill_stats"]["side_arm"]);
            var heavy1 = parseInt(char_data1["character_stats"]["kill_stats"]["rocket_launcher"]) + parseInt(char_data1["character_stats"]["kill_stats"]["Sub Machine Gun"]) + parseInt(char_data1["character_stats"]["kill_stats"]["sword"]);
            var total_kills1 = (auto1 + hand1 + pulse1 + scout1 + sniper1 + shotgun1 + fusion1 + sidearm1 + heavy1);

            // console.log(total_kills1);
            var weaponChart1 = new Chart(weaponctx1, {
                type: 'pie',
                data: {
                    labels: ["Auto", "Hand Cannon", "Pulse", "Scout", "Sniper", "Shotgun", "Fusion", "Sidearm", "Heavy"],
                    datasets: [{
                        backgroundColor: [
                            "#FA8708",
                            "#3498db",
                            "#2ecc71",
                            "#9b59b6",
                            "#f1c40f",
                            "#e74c3c",
                            "#34495e",
                            "#AA885F",
                            "#95a5a6"
                        ],
                        data: [((auto1 / total_kills1) * 100).toFixed(0), ((hand1 / total_kills1) * 100).toFixed(0), ((pulse1 / total_kills1) * 100).toFixed(0), ((scout1 / total_kills1) * 100).toFixed(0), ((sniper1 / total_kills1) * 100).toFixed(0), ((shotgun1 / total_kills1) * 100).toFixed(0), ((fusion1 / total_kills1) * 100).toFixed(0), ((sidearm1 / total_kills1) * 100).toFixed(0), ((heavy1 / total_kills1) * 100).toFixed(0)]
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
            var auto2 = parseInt(char_data2["character_stats"]["kill_stats"]["auto_rifle"]);
            var hand2 = parseInt(char_data2["character_stats"]["kill_stats"]["hand_cannon"]);
            var pulse2 = parseInt(char_data2["character_stats"]["kill_stats"]["pulse_rifle"]);
            var scout2 = parseInt(char_data2["character_stats"]["kill_stats"]["scout_rifle"]);
            var sniper2 = parseInt(char_data2["character_stats"]["kill_stats"]["sniper"]);
            var shotgun2 = parseInt(char_data2["character_stats"]["kill_stats"]["shotgun"]);
            var fusion2 = parseInt(char_data2["character_stats"]["kill_stats"]["fusion_rifle"]);
            var sidearm2 = parseInt(char_data2["character_stats"]["kill_stats"]["side_arm"]);
            var heavy2 = parseInt(char_data2["character_stats"]["kill_stats"]["rocket_launcher"]) + parseInt(char_data2["character_stats"]["kill_stats"]["Sub Machine Gun"]) + parseInt(char_data2["character_stats"]["kill_stats"]["sword"]);
            var total_kills2 = (auto2 + hand2 + pulse2 + scout2 + sniper2 + shotgun2 + fusion2 + sidearm2 + heavy2);

            var weaponChart2 = new Chart(weaponctx2, {
                type: 'pie',
                data: {
                    labels: ["Auto", "Hand Cannon", "Pulse", "Scout", "Sniper", "Shotgun", "Fusion", "Sidearm", "Heavy"],
                    datasets: [{
                        backgroundColor: [
                            "#FA8708",
                            "#3498db",
                            "#2ecc71",
                            "#9b59b6",
                            "#f1c40f",
                            "#e74c3c",
                            "#34495e",
                            "#AA885F",
                            "#95a5a6"
                        ],
                        data: [((auto2 / total_kills2) * 100).toFixed(0), ((hand2 / total_kills2) * 100).toFixed(0), ((pulse2 / total_kills2) * 100).toFixed(0), ((scout2 / total_kills2) * 100).toFixed(0), ((sniper2 / total_kills2) * 100).toFixed(0), ((shotgun2 / total_kills2) * 100).toFixed(0), ((fusion2 / total_kills2) * 100).toFixed(0), ((sidearm2 / total_kills2) * 100).toFixed(0), ((heavy2 / total_kills2) * 100).toFixed(0)]
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
            var auto3 = parseInt(char_data3["character_stats"]["kill_stats"]["auto_rifle"]);
            var hand3 = parseInt(char_data3["character_stats"]["kill_stats"]["hand_cannon"]);
            var pulse3 = parseInt(char_data3["character_stats"]["kill_stats"]["pulse_rifle"]);
            var scout3 = parseInt(char_data3["character_stats"]["kill_stats"]["scout_rifle"]);
            var sniper3 = parseInt(char_data3["character_stats"]["kill_stats"]["sniper"]);
            var shotgun3 = parseInt(char_data3["character_stats"]["kill_stats"]["shotgun"]);
            var fusion3 = parseInt(char_data3["character_stats"]["kill_stats"]["fusion_rifle"]);
            var sidearm3 = parseInt(char_data3["character_stats"]["kill_stats"]["side_arm"]);
            var heavy3 = parseInt(char_data3["character_stats"]["kill_stats"]["rocket_launcher"]) + parseInt(char_data3["character_stats"]["kill_stats"]["Sub Machine Gun"]) + parseInt(char_data3["character_stats"]["kill_stats"]["sword"]);
            var total_kills3 = (auto3 + hand3 + pulse3 + scout3 + sniper3 + shotgun3 + fusion3 + sidearm3 + heavy3);

            var weaponChart3 = new Chart(weaponctx3, {
                type: 'pie',
                data: {
                    labels: ["Auto", "Hand Cannon", "Pulse", "Scout", "Sniper", "Shotgun", "Fusion", "Sidearm", "Heavy"],
                    datasets: [{
                        backgroundColor: [
                            "#FA8708",
                            "#3498db",
                            "#2ecc71",
                            "#9b59b6",
                            "#f1c40f",
                            "#e74c3c",
                            "#34495e",
                            "#AA885F",
                            "#95a5a6"
                        ],
                        data: [((auto3 / total_kills3) * 100).toFixed(0), ((hand3 / total_kills3) * 100).toFixed(0), ((pulse3 / total_kills3) * 100).toFixed(0), ((scout3 / total_kills3) * 100).toFixed(0), ((sniper3 / total_kills3) * 100).toFixed(0), ((shotgun3 / total_kills3) * 100).toFixed(0), ((fusion3 / total_kills3) * 100).toFixed(0), ((sidearm3 / total_kills3) * 100).toFixed(0), ((heavy3 / total_kills3) * 100).toFixed(0)]
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

        //////WINS CHARTS //////////
        if ($(".chart-container1").length) {
            var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
            var abilityctx1 = document.getElementById("ability-chart-breakdown1").getContext('2d');
            var win1 = parseInt(char_data1["character_stats"]["games_won"]);
            var loss1 = parseInt(char_data1["character_stats"]["games_lost"]);
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
            var win2 = parseInt(char_data2["character_stats"]["games_won"]);
            var loss2 = parseInt(char_data2["character_stats"]["games_lost"]);
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
            var win3 = parseInt(char_data3["character_stats"]["games_won"]);
            var loss3 = parseInt(char_data3["character_stats"]["games_lost"]);
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
            var given1 = parseInt(char_data1["character_stats"]["kill_stats"]["revives_performed"]);
            var received1 = parseInt(char_data1["character_stats"]["kill_stats"]["revives_received"]);
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
            var given2 = parseInt(char_data2["character_stats"]["kill_stats"]["revives_performed"]);
            var received2 = parseInt(char_data2["character_stats"]["kill_stats"]["revives_received"]);
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
            var given3 = parseInt(char_data3["character_stats"]["kill_stats"]["revives_performed"]);
            var received3 = parseInt(char_data3["character_stats"]["kill_stats"]["revives_received"]);
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
            var temp_data1 = [];
            var temp_wins1 = [];
            var temp_dates1 = [];
            // console.log(char_data1);

            if (char_data1["recent_games"] != null) {
                $.each(char_data1["recent_games"].reverse(), function(index, value) {
                    temp_data1.push(value["kd_ratio"]);
                    temp_wins1.push(value["standing"]);
                    temp_dates1.push(value["game_date"]);

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
                            }
                        ]
                    },
                    options: {
                        scales: {
                            xAxes: [{
                                scaleLabel: {
                                    display: true,
                                    labelString: 'Last 15 Games'
                                }
                            }]
                        },
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
                        },
                        tooltips: {
                            callbacks: {
                                label: function(tooltipItem, data) {
                                    console.log(temp_dates1[tooltipItem.index]);
                                    return "K/D: " + tooltipItem.yLabel + " (" + $.timeago(temp_dates1[tooltipItem.index]) + ")";
                                }
                            }
                        }
                    }
                });
            }
        }

        if ($(".chart-container2").length) {
            if (char_data1["recent_games"] != null) {
                var char_data2 = JSON.parse($(".chart-container2").attr("data-chart-data"));
                var killctx2 = document.getElementById('kill-chart-breakdown2').getContext('2d');
                var temp_data2 = [];
                var temp_wins2 = [];
                var temp_dates2 = [];
                // console.log(char_data2);

                $.each(char_data2["recent_games"].reverse(), function(index, value) {
                    temp_data2.push(value["kd_ratio"]);
                    temp_wins2.push(value["standing"]);
                    temp_dates2.push(value["game_date"]);

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
                            }
                        ]
                    },
                    options: {
                        scales: {
                            xAxes: [{
                                scaleLabel: {
                                    display: true,
                                    labelString: 'Last 15 Games'
                                }
                            }]
                        },
                        legend: {
                            display: false
                        },
                        title: {
                            display: true,
                            text: 'Recent Games'
                        },
                        tooltips: {
                            callbacks: {
                                label: function(tooltipItem, data) {
                                    return "K/D: " + tooltipItem.yLabel + " (" + $.timeago(temp_dates2[tooltipItem.index]) + ")";
                                }
                            }
                        }
                    }
                });
            }
        }

        if ($(".chart-container3").length) {
            var char_data3 = JSON.parse($(".chart-container3").attr("data-chart-data"));
            var killctx3 = document.getElementById('kill-chart-breakdown3').getContext('2d');
            var temp_data3 = [];
            var temp_wins3 = [];
            var temp_dates3 = [];
            // console.log(char_data3);

            if (char_data1["recent_games"] != null) {
                $.each(char_data3["recent_games"].reverse(), function(index, value) {
                    temp_data3.push(value["kd_ratio"]);
                    temp_wins3.push(value["standing"]);
                    temp_dates3.push(value["game_date"]);

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
                            }
                        ]
                    },
                    options: {
                        scales: {
                            xAxes: [{
                                scaleLabel: {
                                    display: true,
                                    labelString: 'Last 15 Games'
                                }
                            }]
                        },
                        legend: {
                            display: false
                        },
                        title: {
                            display: true,
                            text: 'Recent Games'
                        },
                        tooltips: {
                            callbacks: {
                                label: function(tooltipItem, data) {
                                    return "K/D: " + tooltipItem.yLabel + " (" + $.timeago(temp_dates3[tooltipItem.index]) + ")";
                                }
                            }
                        }
                    }
                });
            }
        }
    }

    function collapseAll() {
        $(".collapsible-header").removeClass(function() {
            return "active";
        });
        $(".collapsible").collapsible({ accordion: true });
        $(".collapsible").collapsible({ accordion: false });
    }

    function expandAll() {
        $(".collapsible-header").addClass("active");
        $(".collapsible").collapsible({ accordion: false });
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
                tooltips: [true, true],
                orientation: 'horizontal', // 'horizontal' or 'vertical'
                range: {
                    'min': 0.0,
                    'max': 4.0
                },
                format: wNumb({
                    decimals: 1
                })
            });



            var kdMin = document.getElementById('kd-field-min'),
                kdMax = document.getElementById('kd-field-max');

            kdSlider.noUiSlider.on('update', function(values, handle) {
                if (handle) {
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

            eloSlider.noUiSlider.on('update', function(values, handle) {
                if (handle) {
                    eloMax.innerHTML = parseInt(values[handle]).toFixed(0);
                    $('input#elo_max').val(parseInt(values[handle]).toFixed(0));
                } else {
                    eloMin.innerHTML = parseInt(values[handle]).toFixed(0);
                    $('input#elo_min').val(parseInt(values[handle]).toFixed(0));

                }
            });
        }
    });




    $(".collapsible-header").click(function() {
        $(".more", this).toggle()
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

    $("#tags-d1").select2({
        placeholder: 'Tag your team',
        allowClear: true,
        maximumSelectionLength: 4
    });

    $("#tags-d2").select2({
        placeholder: 'Tag your team',
        allowClear: true,
        maximumSelectionLength: 4
    });

    $('.parallax').parallax();
    $('.tooltipped').tooltip({
        delay: 50,
        html: true
    });


    $('#d1-game-select').change(function() {
        selection = $(this).val();
        console.log('clicked' + selection);

        if ($.inArray(selection, ["7", "8", "9", "10"]) >= 0) {
            $('#d1-gametype-select').attr('class', 'input-field col s12 m6');
            $('div#difficulty-d1').show();
            $('label.difficulty-label-d1').show();
            // $('label.checkpoint-label').show();
            $('div#checkpoint-d1').show();
        } else {
            $('#d1-gametype-select').attr('class', 'input-field col s12');
            $('div#difficulty-d1').hide();
            $('label.difficulty-label-d1').hide();
            // $('label.checkpoint-label').hide();
            $('div#checkpoint-d1').hide();
        }

    });

    $('#d2-game-select').change(function() {
        selection = $(this).val();


        if ($.inArray(selection, ["7", "8", "9", "10"]) >= 0) {
            // $('#d2-gametype-select').attr('class', 'input-field col s12 m6');
            // $('div#difficulty-d2').show();
            // $('label.difficulty-label-d2').show();
            // $('label.checkpoint-label').show();
            $('div#checkpoint-d2').show();
        } else {
            // $('#d2-gametype-select').attr('class', 'input-field col s12');
            // $('div#difficulty-d2').hide();
            // $('label.difficulty-label-d2').hide();
            // $('label.checkpoint-label').hide();
            $('div#checkpoint-d2').hide();
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

    if (('#load-link').length) {
        $('#load-link').click();
    }


    // if ($(".chart-container1").length) {
    //     // console.log("length");
    //     var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
    //     console.log(char_data1);
    //     // var char_data = chart_data[0];
    //     var weaponctx1 = document.getElementById("weapon-breakdown-chart1").getContext('2d');
    //     var auto1 = parseInt(char_data1["character_stats"]["kill_stats"]["auto_rifle"]);
    //     console.log(auto1);
    //     var hand1 = parseInt(char_data1["character_stats"]["kill_stats"]["hand_cannon"]);
    //     console.log(hand1);
    //     var pulse1 = parseInt(char_data1["character_stats"]["kill_stats"]["pulse_rifle"]);
    //     console.log(pulse1);
    //     var scout1 = parseInt(char_data1["character_stats"]["kill_stats"]["scout_rifle"]);
    //     console.log(scout1);
    //     var sniper1 = parseInt(char_data1["character_stats"]["kill_stats"]["sniper"]);
    //     console.log(sniper1);
    //     var shotgun1 = parseInt(char_data1["character_stats"]["kill_stats"]["shotgun"]);
    //     console.log(shotgun1);
    //     var fusion1 = parseInt(char_data1["character_stats"]["kill_stats"]["fusion_rifle"]);
    //     console.log(fusion1);
    //     var sidearm1 = parseInt(char_data1["character_stats"]["kill_stats"]["side_arm"]);
    //     console.log(sidearm1);
    //     // var heavy1 = parseInt(char_data1["character_stats"]["kill_stats"]["rocket_launcher"]) + parseInt(char_data1["character_stats"]["kill_stats"]["sub_machine_gun"]) + parseInt(char_data1["character_stats"]["kill_stats"]["sword"]));
    //     var heavy1 = 0;
    //     var total_kills1 = (auto1 + hand1 + pulse1 + scout1 + sniper1 + shotgun1 + fusion1 + sidearm1  + 0);
    //     console.log(total_kills1);
    //     // console.log(total_kills1);
    //     var weaponChart1 = new Chart(weaponctx1, {
    //         type: 'pie',
    //         data: {
    //             labels: ["Auto", "Hand Cannon", "Pulse", "Scout", "Sniper", "Shotgun", "Fusion", "Sidearm", "Other"],
    //             datasets: [{
    //                 backgroundColor: [
    //                     "#FA8708",
    //                     "#3498db",
    //                     "#2ecc71",
    //                     "#9b59b6",
    //                     "#f1c40f",
    //                     "#e74c3c",
    //                     "#34495e",
    //                     "#AA885F",
    //                     "#95a5a6"
    //                 ],
    //                 data: [((auto1 / total_kills1) * 100).toFixed(0), ((hand1 / total_kills1) * 100).toFixed(0), ((pulse1 / total_kills1) * 100).toFixed(0), ((scout1 / total_kills1) * 100).toFixed(0), ((sniper1 / total_kills1) * 100).toFixed(0), ((shotgun1 / total_kills1) * 100).toFixed(0), ((fusion1 / total_kills1) * 100).toFixed(0), ((sidearm1 / total_kills1) * 100).toFixed(0), ((heavy1 / total_kills1) * 100).toFixed(0)]
    //             }]
    //         },
    //         options: {
    //             legend: {
    //                 position: 'bottom',
    //                 labels: {
    //                     boxWidth: 15,
    //                     fontColor: '#f5f5f5',
    //                     fontSize: 15
    //                 }
    //             },
    //             title: {
    //                 display: true,
    //                 text: '% Kills by Weapon Types'
    //             }
    //         }
    //     });
    // }

    // if ($(".chart-container1").length) {
    //     var char_data1 = JSON.parse($(".chart-container1").attr("data-chart-data"));
    //     var killctx1 = document.getElementById('kill-chart-breakdown1').getContext('2d');
    //     var temp_data1 = [];
    //     var temp_wins1 = [];
    //     var temp_dates1 = [];
    //     // console.log(char_data1);

    //     if (char_data1["recent_games"] != null) {
    //         $.each(char_data1["recent_games"].reverse(), function(index, value) {
    //             temp_data1.push(value["kd_ratio"]);
    //             temp_wins1.push(value["standing"]);
    //             temp_dates1.push(value["game_date"]);

    //         });

    //         var pointBackgroundColors1 = [];
    //         for (i = 0; i < temp_wins1.length; i++) {
    //             if (temp_wins1[i] == 0) {
    //                 pointBackgroundColors1.push("#2ecc71");
    //             } else {
    //                 pointBackgroundColors1.push("#e74c3c");
    //             }
    //         }

    //         var killChart1 = new Chart(killctx1, {
    //             type: 'line',
    //             data: {
    //                 labels: ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
    //                 datasets: [{
    //                         fill: false,
    //                         label: 'KD',
    //                         data: temp_data1,
    //                         pointBackgroundColor: pointBackgroundColors1,
    //                         borderColor: "#f5f5f5",
    //                         pointBorderColor: "white",
    //                         pointRadius: 10,
    //                         pointHoverRadius: 12,
    //                         borderWidth: 4,
    //                         pointBorderWidth: 1,
    //                         datalabels: {
    //                             align: 'start',
    //                             anchor: 'start'
    //                         }
    //                     },
    //                     {
    //                         fill: false,
    //                         data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    //                         backgroundColor: "#EEEEEE",
    //                         label: "",
    //                         borderColor: "#01d4d4",
    //                         pointRadius: 0,
    //                         borderWidth: 4,
    //                         pointHoverRadius: 0
    //                     }
    //                 ]
    //             },
    //             options: {
    //                 plugins: {
    //                     datalabels: {
    //                         backgroundColor: 'blue',
    //                         borderRadius: 4,
    //                         color: 'white',
    //                         font: {
    //                             weight: 'bold'
    //                         },
    //                         formatter: Math.round
    //                     }
    
    //                 },
    //                 scales: {
    //                     xAxes: [{
    //                         display: false,  
    //                         scaleLabel: {
    //                             display: false,
    //                             labelString: 'Last 15 Games'
    //                         },
    //                         gridLines: {
    //                             display: false
    //                         }
    //                     }],
    //                     yAxes: [{
    //                         gridLines: {
    //                             display: false
    //                         },
    //                         ticks: {                          
    //                             max: 10,
    //                             beginAtZero: true                            
    //                         },
    //                         display: false
    //                     }]
    //                 },
    //                 legend: {
    //                     display: false
    //                 },
    //                 title: {
    //                     display: false,
    //                     text: 'Recent Games'
    //                 },
    //                 layout: {
    //                     padding: {
    //                         left: 0,
    //                         right: 0,
    //                         top: 0,
    //                         bottom: 0
    //                     }
    //                 },
    //                 tooltips: {
    //                     bodyFontSize: 22,
    //                     bodySpacing: 150,
    //                     callbacks: {
    //                         label: function(tooltipItem, data) {
    //                             console.log(temp_dates1[tooltipItem.index]);
    //                             return "K/D: " + tooltipItem.yLabel + " (" + $.timeago(temp_dates1[tooltipItem.index]) + ")";
    //                         },
    //                     }
    //                 },
                    
    //             }
    //         });
    //     }
    // }
    
});

$(document).on("turbolinks:load", function() {
    $('#trials-stuff').hide();
    var options = [
        {selector: '#fire-test', offset: 50, callback: function(el) {
            // $('#staggered-test').hide();
            $('#trials-stuff').toggle( "bounce", { times: 1, distance: 30 }, 1500 );
            // console.log("SCROLL INTIATED");
        } },
        {selector: '#fire-test', offset: 205, callback: function(el) {
            console.log("205");
        } },
        {selector: '#fire-test', offset: 1000, callback: function(el) {            
            console.log("at stag");
        } }
      ];
      Materialize.scrollFire(options);

      (function() {
        window.addEventListener('scroll', function(event) {
          var depth, i, layer, layers, len, movement, topDistance, translate3d;
          topDistance = this.pageYOffset;
          layers = document.querySelectorAll("[data-type='parallax']");
          for (i = 0, len = layers.length; i < len; i++) {
            layer = layers[i];
            depth = layer.getAttribute('data-depth');
            movement = -(topDistance * depth);
            translate3d = 'translate3d(0, ' + movement + 'px, 0)';
            layer.style['-webkit-transform'] = translate3d;
            layer.style['-moz-transform'] = translate3d;
            layer.style['-ms-transform'] = translate3d;
            layer.style['-o-transform'] = translate3d;
            layer.style.transform = translate3d;
          }
        });
      
      }).call(this);
});
// //start of JS for tutorial
// $(document).ready(function(){
//     var goToTeamLU = ()=>{
//         console.log("teamLU");
//         introJs().exit();
//     };
//     if(window.location.pathname.indexOf("brock") > -1){
//         // $('').on("click", function(e) { //uncomment this and it's enclosure and put a css selector in to attach it to a button
//             // e.preventDefault();
//         setTimeout(function() {
//             currentStep = introJs().setOption('showProgress', true).start();

//             $('.introjs-tooltipbuttons').prepend('<a href="/test" id="teamLUButton" class="introjs-button destinder_tutorial" style="display:none;">TeamLU Tutorial</a>', '<a id="LFGButton" class="introjs-button destinder_tutorial">LFG Tutorial</a>', '<a id="playerLUButton" class="introjs-button destinder_tutorial" style="display:none;">PlayerLU Tutorial</a>','<a id="profileButton" class="introjs-button destinder_tutorial" style="display:none;">Profile Tutorial</a>');
//             currentStep.onchange(()=>{
//                 switch(currentStep._currentStep + 1) {
//                     case 1:
//                         $('.destinder_tutorial').hide();
//                         $('#LFGButton').show();
//                         break;
//                     case 2:
//                         $('.destinder_tutorial').hide();
//                         $('#teamLUButton').show();
//                         break;
//                     case 3:
//                         $('.destinder_tutorial').hide();
//                         $('#playerLUButton').show();
//                         break;
//                     case 4:
//                         $('.destinder_tutorial').hide();
//                         $('#profileButton').show();
//                         break;
//                 }
//             });
//             $('#teamLUButton').on("click", goToTeamLU);
//             return false;
//         // }); //also uncomment this
//         }, 250);
//     }
// });
    //end of JS for tutorial