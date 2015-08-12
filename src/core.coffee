###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Path    = require('./path')
Config  = require('./config')
Locals  = require('./locals')
Argv    = require('./argv')
Env     = require('./env')
QueryString = require('query-string')

class Core
  settings: {}
  hooks: {}
  clients: {}
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

  client: (key, obj) ->
    @_set('clients', key, obj)
    return

  hook: (key, obj) ->
    @_set('hooks', key, obj)
    return

  set: (key, obj) ->
    @_set('settings', key, obj)
    return

  _set: (mod, key, obj) ->
    throw new Error 'Invalid settings parameters.' unless key? and obj?

    mods = ['settings', 'hooks', 'clients']

    if mods.indexOf(mod) is -1
      throw new Error 'Invalid module of Nodame.'
      return

    @[mod][key] = obj
    return

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

    name = "./#{vars[1]}" if vars[0] is 'nodame'
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
            html = require('./html').new(req, res)
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

  isDev: Env.isDev
  env: Env.env

module.exports = Core
