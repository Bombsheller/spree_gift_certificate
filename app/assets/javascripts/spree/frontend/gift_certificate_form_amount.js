(function ($) {
    $(window).ready(function () {
        var amountSelector = $('select#gift_certificate_amount');
        var amountInput = $('input#gift_certificate_amount');

        var setAmountInput = function (val) {
            amountInput.val(val);
        };

        if (amountSelector.length > 0) {
            setAmountInput( amountSelector.val() );

            amountSelector.click(function () {
                setAmountInput( amountSelector.val() );
            });
        }
    });
})(jQuery);