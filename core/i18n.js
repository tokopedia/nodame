var I18n = nodame.import('i18n');

function i18n(app) {
    I18n.expressBind(app, {
        locales: ['id', 'en'],
        defaultLocale: 'id',
        cookieName: 'lang',
        directory: nodame.appPath() + '/locales/'
    });
    app.use(function (req, res, next) {
        req.i18n.setLocaleFromQuery();
        req.i18n.setLocaleFromCookie();
        next();
    });
}

module.exports = i18n;
