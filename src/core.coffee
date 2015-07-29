###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Path    = require('nodame/path')
Config  = require('nodame/config')
Locals  = require('nodame/locals')
Argv    = require('nodame/argv')
Env     = require('nodame/env')
QueryString = require('query-string')

class Core
  settings: {}
  sysPath: -> Path.sys
  appPath: -> Path.app

  constructor: ->
    @settings.__systems = {}
    # Init argv
    @settings.__systems.argv = Argv.set()
    # Init config
    config = new Config(@settings.__systems.argv, @appPath())
    @settings.config = config.config
    @settings.__systems.configPath = config.configPath

    # Init environment
    release_env = @settings.config.server.release_env
    @settings.__systems.env = Env.set(@settings.__systems, release_env)

  argv: -> @settings.__systems.argv

  set: (key, obj) ->
    throw new Errors 'Invalid settings parameters.' unless key? and obj?
    @settings[key] = obj

  express: require('express')
  router: -> @express.Router()

  config: (key) ->
    return @settings.config unless key?

    read = (obj, params) ->
      return obj if params.length is 0
      if params.length > 1
        obj = obj[params[0]]
        params.shift()
        return read(obj, params)
      else
        obj = obj[params[0]]
        return obj

    return read(@settings.config, key.split('.'))

  _getFilePath: (mod, name) -> Path.safe "#{@appPath()}/#{mod}/#{name}"

  ###
  #  Native's require wrapper
  #
  #  This method is required to call nodame's modules and custom modules
  #
  #  @param {string} name Module's name or Path
  #  @return {object} module
  ###
  require: (name) ->
    vars = name.split('/')
    tags = ['module', 'hook', 'service', 'middleware', 'handler']
    if tags.indexOf(vars[0]) isnt -1
      return require(@_getFilePath("#{vars[0]}s", vars[1]))
    else
      return require(name)

  ###
  #  Enforce mobile views
  #  Load mobile's view. This is a middleware
  #  @return {object} middleware
  ###
  enforceMobile: ->
    config = @config('view')
    _enforce_mobile = (req, res, next) ->
      if config.mobile? and config.enforce_mobile?
        switch config.enforce_mobile_type
          when 'soft'
            req.device.type = 'phone'
          when 'hard'
            req.device.type = 'desktop'
            html = require('nodame/html').new(req, res)
            html.headTitle(config.app.title)
            html.headDescription(config.app.desc)
            html.render
              module: 'errors'
              file: 'interrupt'
        return next() if next and config.enforce_mobile_type isnt 'hard'
      else
        return next()
    return _enforce_mobile

  ###
  #  View's variables setter
  #
  #  Set variable to view's locals. This is a middleware.
  #
  #  @param {obj} app Express
  #  @return {object} middleware
  ###
  locals: (app) ->
    locals = new Locals()
    config =
      url: @config('url')
      app: @config('app')
      assets: @config('assets')
    assets = @settings.assets
    return locals.nodame(app, config, assets)
  # locals: (app) ->
  #   config = @config
  #   configs =
  #     url: @config('url')
  #     app: @config('app')
  #     assets: @config('assets')
  #   assets = @settings.assets
  #
  #   time = (num) ->
  #     return String(num).replace(/([0-9]{2})([0-9]{2})/, '$1:$2 WIB')
  #
  #   lead_zero = (num) -> ('0' + num).slice(-2)
  #
  #   date = (date_str, format = 'normal') ->
  #     _date = new Date(date_str)
  #     # TODO: Move to config
  #     weekdays =
  #       Sun: 'Minggu'
  #       Mon: 'Senin'
  #       Tue: 'Selasa'
  #       Wed: 'Rabu'
  #       Thu: 'Kamis'
  #       Fri: 'Jumat'
  #       Sat: 'Sabtu'
  #     # TODO: Move to config
  #     months =
  #       Jan: { word: 'Januari',   num: 1  }
  #       Feb: { word: 'Februari',  num: 2  }
  #       Mar: { word: 'Maret',     num: 3  }
  #       Apr: { word: 'April',     num: 4  }
  #       May: { word: 'Mei',       num: 5  }
  #       Jun: { word: 'Juni',      num: 6  }
  #       Jul: { word: 'Juli',      num: 7  }
  #       Aug: { word: 'Agustus',   num: 8  }
  #       Sep: { word: 'September', num: 9  }
  #       Oct: { word: 'Oktober',   num: 10 }
  #       Nov: { word: 'November',  num: 11 }
  #       Dec: { word: 'Desember',  num: 12 }
  #
  #     format_date = (match, $1, $2, $3, $4, offset, original) ->
  #       res = ''
  #       switch format
  #         when 'normal'
  #           res = "#{weekdays[$1]}, #{$3} #{months[$2].word} #{$4}"
  #         when 'short'
  #           res = "#{lead_zero($3)}/#{lead_zero($2)}/#{$4}"
  #       return res
  #
  #     replace_date = ->
  #       re = ///^
  #       ([a-z]{1,3})\         # $1 short day
  #       ([a-z]{1,3})\         # $2 short month
  #       ([0-9]{1,2})\         # $3 date
  #       ([0-9]{1,4})\         # $4 year
  #       ([0-9]{1,2}):         # $5 hours
  #       ([0-9]{1,2}):         # $6 minutes
  #       ([0-9]{1,2})\         # $7 seconds
  #       GMT([-+][0-9]{1,4})\  # $8 GMT
  #       (\([a-z ]+\))         # $9 timezone
  #       $///i
  #
  #       return _date.toString().replace(re, format_date)
  #
  #     return replace_date()
  #
  #   thousands = (num) -> Numeral(num).format(0.0)
  #
  #   locale = (data) ->
  #     html = ''
  #
  #     if data?
  #       if Array.isArray(data) and data.length > 0
  #         locales = {}
  #
  #         for i of data
  #           key = data[i]
  #           locales[key] = res.locals.__(key)
  #
  #         localesData = "b=#{JSON.stringify(locales)}"
  #
  #         html += """
  #           <script type="text/javascript">
  #           function __(a) {#{localesData} return b[a]}
  #           </script>
  #         """
  #     return html
  #
  #   url = ->
  #     base: (uri, params) ->
  #       uri = Path.normalize("/#{uri}")
  #       url = "#{configs.url.base}#{uri}"
  #       return stringify(url, params)
  #
  #     assets: (uri, params) ->
  #       uri = Path.normalize("/#{uri}")
  #       url = "#{configs.url.assets}#{uri}"
  #       return stringify(url, params)
  #
  #     stringify = (url, params) ->
  #       return "#{url}#{getQueries(params)}"
  #
  #     getQueries = (params) ->
  #       queries = ''
  #
  #       if Object.keys(params).length > 0
  #         queries = "?#{QueryString.stringify(params)}"
  #
  #       return queries
  #
  #   get_assets =
  #     css: ''
  #     js: ''
  #   #     __device: 'mobile',
  #   #     __type: 'css',
  #   #     __module: undefined,
  #   #     css: function (module) {
  #   #         return this.__assets('css', module)
  #   #     },
  #   #     js: function (module) {
  #   #         return this.__assets('js', module)
  #   #     },
  #   #     __assets: function (type, module) {
  #   #         device = 'desktop'
  #   #
  #   #         if (req.device.type !== 'desktop') {
  #   #             device = 'mobile'
  #   #         }
  #   #
  #   #         this.__device = device
  #   #         this.__type = type
  #   #         this.__module = module
  #   #
  #   #         // Global
  #   #         assetsName = this.__getValidName('global')
  #   #         assets = this.__html(assetsName)
  #   #
  #   #         assetsName = this.__getValidName(this.__module)
  #   #
  #   #         if (assetsName) {
  #   #             assets += this.__html(assetsName)
  #   #         }
  #   #
  #   #         return assets
  #   #     },
  #   #     __getValidName: function (module) {
  #   #         type = this.__type
  #   #         name = this.__getName(module)
  #   #         name = name.replace(/[.][a-z]+$/gi, '')
  #   #         re = new RegExp(name, 'gi')
  #   #
  #   #         for (i in assets[type]) {
  #   #             for (__name in assets[type][i]) {
  #   #                 if (__name.match(re)) {
  #   #                     return __name
  #   #                 }
  #   #             }
  #   #         }
  #   #
  #   #         return
  #   #     },
  #   #     __getConfigDir: function () {
  #   #         confDir = configs.assets.dir
  #   #
  #   #         if (confDir.substr(0, 1) == '/') {
  #   #             confDir = confDir
  #   #         } else {
  #   #             confDir = Path.safe(self.appPath() + '/' + confDir)
  #   #         }
  #   #
  #   #         return confDir
  #   #     },
  #   #     __getName: function (module) {
  #   #         return this.__device + '.' + module + '.min.' + this.__type
  #   #     },
  #   #     __html: function (name) {
  #   #         type = this.__type
  #   #         data = assets[type]
  #   #         html = ''
  #   #
  #   #         if (self.isDev()) {
  #   #             for (i in data) {
  #   #                 if (data[i][name] !== undefined) {
  #   #                     if (self.isDev()) {
  #   #                         for (j in data[i][name]) {
  #   #                             filepath = data[i][name][j]
  #   #                             html += this.__htmlTag(type, filepath)
  #   #                         }
  #   #                     } else {
  #   #                         html = this.__htmlTag(type, name)
  #   #                     }
  #   #                 }
  #   #             }
  #   #         } else {
  #   #             html = this.__htmlTag(type, name)
  #   #         }
  #   #
  #   #         return html
  #   #     },
  #   #     __htmlTag: function (type, filepath) {
  #   #         html = ''
  #   #         configDir = this.__getConfigDir()
  #   #         typeDir = Env.isDev() ? this.__type : 'min'
  #   #
  #   #         filepath = configs.url.assets + '/' + typeDir + '/' + filepath
  #   #
  #   #         switch (type) {
  #   #             case 'css':
  #   #                 html = '<link href="' + filepath + '" type="text/css" rel="stylesheet">\n'
  #   #                 break
  #   #             case 'js':
  #   #                 html = '<script src="' + filepath + '" type="text/javascript"></script>\n'
  #   #                 break
  #   #         }
  #   #
  #   #         return html
  #   #     }
  #   # }
  #
  #   _locals = (req, res, next) ->
  #     app.locals.nodame =
  #       config: config
  #       time: time
  #       leadZero: lead_zero
  #       date: date
  #       thousands: thousands
  #       locale: locale
  #       url: url
  #       assets: get_assets
  #
  #     return next() if next
  #
  #   return _locals

  isDev: Env.isDev
  env: Env.env

module.exports = Core
