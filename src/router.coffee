###
# @author  Argi Karunia <https://github.com/hkyo89>
# @author  Teddy Hong <teddy.hong11@gmail.com>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class Router
  locals: (req, res, next) ->
    if req.query.refback?
      res.locals.refback = refback
    next()
    return

  constructor: (app) ->
    @default_module  = nodame.config 'module.default'
    @modules  = nodame.config 'module.items'
    @hostname = nodame.config 'url.hostname'
    @root = "#{nodame.config('module.root')}"

    unless @root[0] is '/'
      @root = "/#{@root}"

    Session   = require('./session')
    app.use(Session.initSession)

    for mod of @modules
      config = @modules[mod]

      if config.enable and module isnt '__default'
        # Check whether it's development only module
        continue if config.dev_only and !nodame.isDev()

        handler = nodame.require "handler/#{mod}"
        route   = "#{@root}"

        if mod isnt @default_module then route += "/#{mod}"
        else defRoute = "#{route}/#{mod}"

        # Init middleware
        if config.middleware
          middleware = nodame.require "middleware/#{mod}"
          app.use "#{route}/", middleware.init

        # Init module, only if it's not set as "xhr only"
        unless config.ajax and config.xhr_only
          app.use "#{route}/", handler

          # Enable access to default route using its module name
          app.use "#{defRoute}/", handler if mod is @default_module

        # Init xhr
        app.use "#{@root}/ajax/#{mod}/", handler if config.ajax

    return

  redirectNotFound: (req, res) ->
    url = "#{@hostname}#{@root}"
    res.redirect url
    res.end
    return

module.exports = Router
