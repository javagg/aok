Settings = {

    settings: {},

    /**
     * Default settings, these will be overridden by settings defined on the server.
     * NOTE: Please note if these are changed they must also be updated in console.git/js/utils/settings.js
     */
    setting_defaults: {
        product_name: 'Stackato',
        company_name: 'ActiveState Software',
        vendor_version: '3.2',
        default_locale: 'en',
        product_logo_favicon_url: '/console/img/stackato_logo_favicon.png',
        product_logo_header_url: '/console/img/stackato_logo_header.png',
        product_logo_footer_url: '/console/img/stackato_logo_footer.png',
        background_color: '#ffffff',
        style: ''
    },

    refreshServerSettings: function (done) {

        var origin = window.location.origin;
        if (!origin) {
            // not supported in all browsers (i.e. IE)
            origin = window.location.protocol + "//"
                + window.location.hostname
                + (window.location.port ? ':' + window.location.port : '');

        }

        var parseResponse = function (jqXHR) {
            try {
                return JSON.parse(jqXHR.responseText)
            } catch (e) {
                return jqXHR.responseText;
            }
        };

        var self = this;
        $.ajax({
                url: origin + '/srest/settings/namespace/console',
                accept: "application/json",
                dataType: "json",
                type: 'GET',
                async: true,
                timeout: 30000,
                cache: false,
                processData: false,
                complete: function (jqXHR) {

                    if (jqXHR.status == 200) {

                        self.settings = parseResponse(jqXHR);

                        Object.keys(self.settings).forEach(function (k) {
                            if (self.settings[k] === null || self.settings[k].length <= 0) {
                                delete self.settings[k];
                            }
                        });
                    } else {
                        if (console && console.log) {
                            console.log('Unable to load settings, falling back to defaults. Status: ' + jqXHR.status +
                                '. Response: ' + jqXHR.responseText);
                        }
                    }

                    done();
                }}
        );
    },

    getSettings: function () {

        var merged_settings = {};

        merged_settings = $.extend(merged_settings, this.setting_defaults, this.settings);

        return merged_settings;
    }
};

$().ready(function () {

    // Note that to support white labeling the body starts off with display:none, we then load settings from srest
    // and update the page before rendering it.

    Settings.refreshServerSettings(function () {

        var settings = Settings.getSettings();

        // Use the product name to set the window title
        document.title = (settings.product_name + ' - ' + settings.company_name);

        // Set the favicon
        $("#favicon").attr("href", settings.product_logo_favicon_url);

        // Set the header logo
        $('.navbar-brand').attr('src', settings.product_logo_header_url);

        $('.form-signin-heading').html('Welcome to ' + settings.product_name);

        // NOTE: apply additional theme colors in this statement
        $("head").append("<style type=\"text/css\" charset=\"utf-8\"> body{background-color:" + settings.background_color + "}</style>");

        // This must be the last theme/styling to be applied
        if (settings.style) {
            $("head").append("<style type=\"text/css\" charset=\"utf-8\">" + settings.style + "</style>");
        }

        // Show the page
        $('body').css('display', 'block');

        // Update sign in button state when clicked
        $('.signin-button').click(function () {
            $('#invalid_credentials').hide();
            $('.signin-button').button('loading');
        });

        $('input').first().focus();

        function getParams() {
            var params = {};

            if (location.search) {
                var parts = location.search.substring(1).split('&');

                for (var i = 0; i < parts.length; i++) {
                    var nv = parts[i].split('=');
                    if (!nv[0]) continue;
                    params[nv[0]] = nv[1] || true;
                }
            }

            return params;
        }

        var params = getParams();
        if (params['message']) {
            if(params['message'] === 'unauthorized'){
                $('#failed-login-alert').text("The administrator has not granted you access to " + settings.product_name + ".");
            }
            $('#failed-login-alert').removeClass('hide');
        }
    });
});