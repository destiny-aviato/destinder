# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = -> 
    $('span#home-subtitle').typed
        strings: ['elite', "winners", "salty", "complainers", "ragers", "try hards", "losers", "good looking", "masses"]
        loop: true
        startDelay: 2000
        backDelay: 1000
        typeSpeed: 70
        showCursor: true
        cursorChar: "|"
        shuffle: true
        
$(document).on('turbolinks:load', ready)
