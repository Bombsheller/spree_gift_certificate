// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'

(function ($) {
    $(window).ready(function () {
        $('#show_gift_certificate_value_input').click(function () {
            $('input#gift_certificate_amount').show();
        });
    });
})(jQuery);