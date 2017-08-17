$(document).on("turbolinks:load", function() {
    $('.scroller').slick({
        dots: true,
        infinite: true,
        speed: 300,
        slidesToShow: 3,
        slidesToScroll: 1,
        responsive: [{
                breakpoint: 1150,
                settings: {
                    slidesToShow: 2,
                    slidesToScroll: 1,
                    infinite: true,
                    dots: true
                }
            },
            {
                breakpoint: 750,
                settings: {
                    slidesToShow: 1,
                    slidesToScroll: 1
                }
            }
            // You can unslick at a given breakpoint now by adding:
            // settings: "unslick"
            // instead of a settings object
        ]
    });



    $('#gear-modal-0').modal('open');

    $('#gear-modal-0').modal('close');

    $('#gear-modal-1').modal('open');

    $('#gear-modal-1').modal('close');

    $('#gear-modal-2').modal('open');

    $('#gear-modal-2').modal('close');
});