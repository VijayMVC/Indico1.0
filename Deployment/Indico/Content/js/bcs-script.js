$(document).ready(function () {
    $(".gspec-search input[type=text]").bind("keydown", function (event) {
        // track enter key
        var keycode = (event.keyCode ? event.keyCode : (event.which ? event.which : event.charCode));
        if (keycode == 13) { // keycode for enter key
            // force the 'Enter Key' to implicitly click the Update button
            $('#' + btnsearch).trigger('click');
            return false;
        }
        else {
            return true;
        }
    });

    //initiate the plugin and pass the id of the div containing gallery images 
    $(".image-hero img").elevateZoom({
        borderSize: 2,
        cursor: 'zoom-in',
        gallery: 'imageother',
        galleryActiveClass: 'active',
        imageCrossfade: true,
        loadingIcon: '/content/img/waiting.gif',        
        zoomWindowHeight: 368
    });

    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
    })

    $('#overlay table td label.inches, #overlay p.text-info.inches').hide();
    $('#overlay table caption a').click(function () {
        $('#overlay table caption a').removeClass('active');
        if ($(this).text() == 'cm') {
            $('#overlay table td label.inches, #overlay p.text-info.inches').hide();
            $('#overlay table td label.cm, #overlay p.text-info.cm').show();
            $('#' + type).val('0');
        }
        else {
            $('#overlay table td label.inches, #overlay p.text-info.inches').show();
            $('#overlay table td label.cm, #overlay p.text-info.cm').hide();
            $('#' + type).val('1');
        }
        $(this).addClass('active');
    });
});