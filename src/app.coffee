###
# @author  Argi Karunia <https:#github.com/hkyo89>
# @link    https:#github.com/tokopedia/nodame
# @license http:#opensource.org/licenses/MIT
#
# @version 1.0.0
###

# Global handler
process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ', err

timeout_func = () -> console.log 'Caught something'
setTimeout timeout_func, 500
# Intentionally cause an exception, but don't catch it.

# third-party modules
CookieParser    = require('cookie-parser')
BodyParser      = require('body-parser')
XMLBodyParser   = require('express-xml-bodyparser')
MethodOverride  = require('method-override')
ExpressDevice   = require('express-device')
YAMLParser      = require('js-yaml')
fs              = require('fs')
Async           = require('async')
# private modules
Router  = require('./router')
View    = require('./view')
Locals  = require('./locals')
Path    = require('./path')
File    = require('./file')
Logger  = require('./logger')
Parser  = require('./parser')
# expressjs initialization
app     = nodame.express()
app.env = nodame.env()

# load package information
package_path = Path.safe("#{nodame.sysPath()}/package.json")
Package     = File.readJSON(package_path)

nodame.set 'app',
  name    : Package.name
  version : Package.version
  homepage: Package.homepage
  authors : Package.authors
  license : Package.license

# local variables
is_dev    = nodame.isDev()
app_path  = nodame.appPath()
CONFIG    = nodame.config()

# trust proxy setup
app.set('trust proxy', 'uniquelocal')
app.enable('trust proxy')

# load and store assets config
assets_file  = if is_dev then 'assets.yaml' else '.assets'
assets_stream    = Path.safe("#{app_path}/configs/#{assets_file}")
if is_dev
  assets = fs.readFileSync(assets_stream)
  assets = YAMLParser.safeLoad(assets)
  assets = Parser.to_grunt(assets)
else
  assets = File.readJSON(assets_stream)
nodame.set('assets', assets)

# Load build data
build_data_stream = Path.safe("#{app_path}/configs/.build")
build_data = File.readJSON(build_data_stream)
nodame.set('build', build_data)

# x-powered-by header
app.set('x-powered-by', CONFIG.server.powered_by)

# Device capture  setup
app.use(ExpressDevice.capture()) if CONFIG.view.device_capture

# log setup
# TODO: disable logger
app.use(Logger.error())
app.use(Logger.output())

# block favicon request
block_favicon = (req, res, next) ->
  if req.url is '/favicon.ico'
    res.writeHead(200, {'Content-Type': 'image/x-icon'})
    res.end()
  else
    next()
  return

app.use(block_favicon) if CONFIG.server.block_favicon

# static server setup
if CONFIG.assets.enable_server
  ServeStatic = require('serve-static')
  module_root = CONFIG.module.root
  unless module_root[0] is '/'
    module_root = "/#{module_root}"
  static_route = CONFIG.assets.route
  if static_route[0] is '/'
    static_route = static_route.substr(1)
  #TODO FIX THIS FOR WINDOW
  static_route = "#{module_root}/#{static_route}"
  static_dir   = Path.safe("#{app_path}/#{CONFIG.assets.dir}")
  app.use(static_route, ServeStatic(static_dir))

setHeaders = (res, path) ->
  if path.match(/.svgz$/)
    res.setHeader('Content-Encoding', 'gzip');

# view engine setup
new View(app)

# redirect non-https on production
enforce_secure = (req, res, next) ->
  unless is_dev and req.secure
    res.redirect("#{CONFIG.url.hostname}#{req.originalUrl}")
    next = false
  return next() if next

app.use(enforce_secure) if not is_dev and CONFIG.server.enforce_secure

# middlewares Setups
app.use(BodyParser.json())
app.use(BodyParser.urlencoded({ extended: false }))
app.use(XMLBodyParser())
app.use(CookieParser(nodame.config('cookie.secret')))
app.use(MethodOverride())

# Locals setup
locals = new Locals()
locals.set(app)

# i18n setup
require('./locale')(app)

# numeral setup
require('./numeral')(app)

# enforce mobile setup
enforce_mobile = CONFIG.view.device_capture and CONFIG.view.enforce_mobile
app.use(nodame.enforce_mobile()) if enforce_mobile

# locals helper setup
local_path_helper = (req, res, next) ->
  fullpath = req.originalUrl
  appName = CONFIG.app.name
  res.locals.path =
    full    : fullpath
    module  : fullpath.replace("/#{appName}", '')

  return next() if next
app.use(nodame.locals(app))
app.use(local_path_helper)

# maintenance setup
server_maintenance = (req, res, next) ->
  # Bypass whitelist_ips
  return next() if next and nodame.is_whitelist(req.ips)
  # Partial maintenance
  if CONFIG.server.partial_maintenance
    for module, i in CONFIG.server.module_maintenance
      if req.url.indexOf(CONFIG.app.name + '/' + module) >= 0
        break
      if i + 1 == CONFIG.server.module_maintenance.length
        return next()
  # Set maintenance
  Render = require('./render')
  render = new Render(req, res)

  Async.waterfall [
    (cb) => render.cache("error:maintenance", true, cb)
  ], (err, is_cache) =>
    unless is_cache
      render.path('errors/503')
      render.code(503)
    render.send()
    return undefined
  return
app.use(server_maintenance) if CONFIG.server.maintenance

# routes setup
new Router(app)

# hooks setup
if CONFIG.server.hooks.length > 0
  nodame.require("hook/#{hook}") for hook in CONFIG.server.hooks

# errors setup
require('./error')(app)

module.exports = app
