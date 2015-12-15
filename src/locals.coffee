###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Assets = require('./assets')
Numeral = require('numeral')
DateParser = require('./date')

class Locals
  set: (app) ->
    configs =
      url: nodame.config('url')
      app: nodame.config('app')
      assets: nodame.settings.assets

    for config of configs
      app.locals[config] = {}
      for key of configs[config]
        app.locals[config][key] = configs[config][key]

  nodame: (app, config, assets) ->
    _res = {}
    _req = {}
    _cookies = {}

    now = -> new Date()

    _device = (req) ->
      # Get default device
      DEVICES = nodame.config('devices')
      # Check if cookie exists
      if req.cookies[DEVICES.cookie]?
        src = req.cookies[DEVICES.cookie]
        # TODO: Optimize this
        for item in DEVICES.types
          # Return device
          return req.__device = item if item.id is src
      # Return default device
      return req.__device = DEVICES._default

    time = (num) ->
      return String(num).replace(/([0-9]{2})([0-9]{2})/, '$1:$2 WIB')

    lead_zero = (num) -> ('0' + num).slice(-2)

    date = DateParser.toString

    thousands = (num) -> Numeral(num).format(0.0)

    locale = (data) ->
      __locale_html = (__content = '') ->
        return """\
          <script type="text/javascript">\
          function __(a){#{__content}}\
          </script>\
        """

      if data?
        if Array.isArray(data) and data.length > 0
          locales = {}

          for i of data
            key = data[i]
            locales[key] = _res.locals.__(key)

          localesData = "b=#{JSON.stringify(locales)}"
          script_content = "#{localesData};return b[a]"

      return __locale_html(script_content)

    url = ->
      base: (uri, params) ->
        uri = Path.normalize("/#{uri}")
        url = "#{config.url.base}#{uri}"
        return stringify(url, params)

      assets: (uri, params) ->
        uri = Path.normalize("/#{uri}")
        url = "#{config.url.assets}#{uri}"
        return stringify(url, params)

      stringify = (url, params) ->
        return "#{url}#{getQueries(params)}"

      getQueries = (params) ->
        queries = ''

        if Object.keys(params).length > 0
          queries = "?#{QueryString.stringify(params)}"

        return queries

    assets = ->
      return new Assets
        appPath: nodame.appPath()
        isDev: nodame.isDev()
        url: nodame.config('url.assets')
        assets: nodame.settings.assets
        dir: nodame.config('assets.dir')
        device: _req.device.type
    _config = (key) ->
      return nodame.settings.config unless key?

      read = (obj, params) ->
        return obj if params.length is 0
        if params.length > 1
          obj = obj[params[0]]
          params.shift()
          return read(obj, params)
        else
          obj = obj[params[0]]
          return obj

      return read(nodame.settings.config, key.split('.'))

    _locals = (req, res, next) ->
      _res = { locals: res.locals }
      _req = { device: req.device }
      _device(req)

      app.locals.nodame =
        now: now()
        config: _config
        time: time
        leadZero: lead_zero
        date: date
        thousands: thousands
        locale: locale
        url: url
        assets: assets()
        device: req.__device

      return next() if next

    return _locals

module.exports = Locals
