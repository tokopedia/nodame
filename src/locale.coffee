i18n = require('./i18n')
path = require('./path')

locale = (app) ->
  default_locale = nodame.config('locale.default')
  unless default_locale
    default_locale = "en"

  i18n.expressBind app,
    locales: ['id', 'en']
    defaultLocale: default_locale
    cookieName: 'lang'
    directory: path.safe('locales/')

  app.use (req, res, next) ->
    req.i18n.setLocaleFromQuery()
    req.i18n.setLocaleFromCookie()
    next()
    return

  return

module.exports = locale
