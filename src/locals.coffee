###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Assets = require('nodame/assets')
Numeral = require('numeral')

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

    time = (num) ->
      return String(num).replace(/([0-9]{2})([0-9]{2})/, '$1:$2 WIB')

    lead_zero = (num) -> ('0' + num).slice(-2)

    date = (date_str, format = 'normal') ->
      _date = new Date(date_str)
      # TODO: Move to config
      weekdays =
        Sun: 'Minggu'
        Mon: 'Senin'
        Tue: 'Selasa'
        Wed: 'Rabu'
        Thu: 'Kamis'
        Fri: 'Jumat'
        Sat: 'Sabtu'
      # TODO: Move to config
      months =
        Jan: { word: 'Januari',   num: 1  }
        Feb: { word: 'Februari',  num: 2  }
        Mar: { word: 'Maret',     num: 3  }
        Apr: { word: 'April',     num: 4  }
        May: { word: 'Mei',       num: 5  }
        Jun: { word: 'Juni',      num: 6  }
        Jul: { word: 'Juli',      num: 7  }
        Aug: { word: 'Agustus',   num: 8  }
        Sep: { word: 'September', num: 9  }
        Oct: { word: 'Oktober',   num: 10 }
        Nov: { word: 'November',  num: 11 }
        Dec: { word: 'Desember',  num: 12 }

      format_date = (match, $1, $2, $3, $4, offset, original) ->
        switch format
          when 'normal'
            result = "#{weekdays[$1]}, #{$3} #{months[$2].word} #{$4}"
          when 'short'
            result = "#{lead_zero($3)}/#{$2}/#{$4}"
        return result

      replace_date = ->
        re = ///^
        ([a-z]{1,3})\         # $1 short day
        ([a-z]{1,3})\         # $2 short month
        ([0-9]{1,2})\         # $3 date
        ([0-9]{1,4})\         # $4 year
        ([0-9]{1,2}):         # $5 hours
        ([0-9]{1,2}):         # $6 minutes
        ([0-9]{1,2})\         # $7 seconds
        GMT([-+][0-9]{1,4})\  # $8 GMT
        (\([a-z ]+\))         # $9 timezone
        $///i

        return _date.toString().replace(re, format_date)

      return replace_date()

    thousands = (num) -> Numeral(num).format(0.0)

    locale = (data) ->
      html = ''
      if data?
        if Array.isArray(data) and data.length > 0
          locales = {}

          for i of data
            key = data[i]
            locales[key] = _res.locals.__(key)

          localesData = "b=#{JSON.stringify(locales)}"

          html += """\
            <script type="text/javascript">\
            function __(a){#{localesData};return b[a]}\
            </script>\
          """
      return html

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

      app.locals.nodame =
        config: _config
        time: time
        leadZero: lead_zero
        date: date
        thousands: thousands
        locale: locale
        url: url
        assets: assets()

      return next() if next

    return _locals

module.exports = Locals
