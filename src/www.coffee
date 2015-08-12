# global variable
lib = "#{__dirname}/../lib"
`var Nodame  = require(lib + '/core')
sprintf     = require('sprintf-js').sprintf
vsprintf    = require('sprintf-js').vsprintf
nodame      = new Nodame()
validate    = require(lib + '/validate')`

# load modules
app     = require("#{lib}/app")
debug_name = nodame.config('app.debug_name')
debug   = require('debug')(debug_name)
http    = require('http')
path    = require("#{lib}/path")
colors  = require('colors')
Notification = require("#{lib}/notification")

# normalize port
normalize_port = (val) ->
  port = parseInt(val, 10)
  # named pipe
  return val if isNaN(port)
  # port number
  return port if port >= 0
  # incorrect path input
  return false

# get port from inputs
get_port = ->
  # set default port
  port = '3000'
  port_env  = process.env.PORT
  port_conf = nodame.config('server.port')
  port_argv = nodame.argv.port

  # get port from environment and store in Express.
  if port_env?
    port = port_env
  # overwrite port from config
  if port_conf?
    port = port_conf
  # overwrite from argv
  if port_argv?
    port = port_argv

  return normalize_port(port)

# set port
port = get_port()

# parse bool to enable string
enable = (bool) -> if bool then 'enabled' else 'disabled'

# console.log wrapper for shorter syntax
echo = (str = '') ->
  console.log(str)
  return

# console.log wrapper with prefix
echo_pfx = (str = '') ->
  date = "#{date_str()} -".green
  pfx = "[nodame]".yellow
  console.log(date, pfx, str)
  return

# parse datestring
date_str = ->
  # Wed Jul 15 2015 10:54:30 GMT+0000 (UTC)
  date = new Date().toString().split(' ')
  return "#{date[2]} #{date[1]} #{date[4]}"

# print welcome message
welcome = ->
  ver = nodame.settings.app.version
  CFG = nodame.settings.config
  APP = nodame.settings.app
  SYS = nodame.settings.__systems
  ver_spc = Array(10 - ver.length).join(' ')
  spc = Array(12).join(' ')
  env_str = nodame.env().underline.bold
  dev_str = if nodame.isDev() then 'dev' else 'release'
  device_capture = nodame.config('view.device_capture').underline
  stderr = path.safe(CFG.logger.clients.syslog.error_stream)
  stdout = path.safe(CFG.logger.clients.syslog.output_stream)

  echo()
  echo()
  echo("#{spc}               .    #{ver_spc} #{ver}".cyan.bold)
  echo("#{spc}     ,-. ,-. ,-| ,-. ,-,-. ,-.".cyan.bold)
  echo("#{spc}     | | | | | | ,-| | | | |-'".cyan.bold)
  echo("#{spc}     ' ' `-' `-' `-^ ' ' ' `-'".cyan.bold)
  echo("#{spc} http://tokopedia.github.io/nodame".gray)
  echo()
  echo('Hi Nobita! Doraemon is serving you!'.green.bold)
  echo()
  echo_pfx("listening to port #{port}".yellow)
  echo_pfx("running in #{env_str} (#{dev_str} mode)".yellow)
  echo_pfx("device capture is #{enable(device_capture)}".yellow)
  echo_pfx("reading config #{SYS.configPath}".yellow)
  echo_pfx("reading stderr #{stderr}".yellow)
  echo_pfx("reading stdout #{stdout}".yellow)
  echo_pfx("#{CFG.url.hostname} is ready".green.bold)
  echo()
  return

# Start server
start = (app) ->
  server = http.createServer(app)
  server.listen(port)
  server.on('error', on_error)
  server.on('listening', on_listening)
  welcome()

  notification = new Notification()
  title = 'restarted'
  notification.send(title)
  return

# Event listener for HTTP server "error" event.
on_error = (error) ->
  throw error if error.syscall isnt 'listen'
  bind = if typeof port is 'string' then 'Pipe' else 'Port'
  bind = "#{bind} #{port}"

  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      console.error("#{bind} requires elevated privileges".red)
      process.exit(1)
    when 'EADDRINUSE'
      console.error("#{bind} is already in use".red)
      process.exit(1)
    else
      throw error

  return

# Event listener for HTTP server "listening" event.
on_listening = ->
  bind = if typeof port is 'string' then "pipe" else "port"
  debug("Listening on #{bind} #{port}")
  return

# register port to app
app.set('port', port)
# start app
start(app)
