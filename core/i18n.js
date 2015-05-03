var I18n = helper.load.util('i18n');

function i18n(app) {
    I18n.expressBind(app, {
        locales: ['id', 'en'],
        defaultLocale: 'id',
        cookieName: 'lang',
        directory: APP_PATH + '/locales/'
    });
    app.use(function(req, res, next) {
        req.i18n.setLocaleFromQuery();
        req.i18n.setLocaleFromCookie();
        next();
    });
}

module.exports = i18n;
