###
# @author  Argi Karunia <https://github.com/hkyo89>
# @author  Teddy Hong <teddy.hong11@gmail.com>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Session = require('./session')
MODULES = nodame.config('module')

class Router
  locals: (req, res, next) ->
    if req.query.refback?
      res.locals.refback = refback
    next()
    return

  constructor: (app) ->
    @default_module  = MODULES.default
    @forbidden = MODULES.forbidden
    @modules  = MODULES.items
    @hostname = nodame.config('url.hostname')
    @root = "#{nodame.config('module.root')}"
    # normalize root path
    if @root.length > 1
      unless @root[0] is '/'
        @root = "/#{@root}"
      if @root[@root.length - 1] is '/'
        @root = @root.slice(0, -1)
    else
      if @root[0] is '/'
        @root = ''
    # Run session evaluation middleware
    app.use(Session.middleware)
    # Register modules
    for mod of @modules
      # Assign config
      config = @modules[mod]
      # Check if module is enabled and not default module
      if config.enable and module isnt '__default'
        # Check whether it's development only module
        continue if config.dev_only and !nodame.isDev()
        # Load handler
        handler = nodame.require "handler/#{mod}"
        route   = "#{@root}"
        # Check access restriction

        if mod isnt @default_module then route += "/#{mod}"
        else default_route = "#{route}/#{mod}"

        # Init middleware
        if config.middleware
          middleware = nodame.require "middleware/#{mod}"
          app.use "#{route}/", middleware.init

        # Init module, only if it's not set as "xhr only"
        unless config.ajax and config.xhr_only
          app.use "#{route}/", handler

          # Enable access to default route using its module name
          app.use "#{default_route}/", handler if mod is @default_module

        # Init xhr
        app.use "#{@root}/ajax/#{mod}/", handler if config.ajax

    return

  redirectNotFound: (req, res) ->
    url = "#{@hostname}#{@root}"
    res.redirect url
    res.end
    return

module.exports = Router
