###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

# -------------- MODULE -------------- #
Render  = require('./render')
Async   = require('async')
# -------------- CONFIG -------------- #
config  = nodame.config('logger')

errors = (app) ->
  # catch 404 and forward to error handler
  catch_404_handler = (req, res, next) ->
    err         = new Error('Not Found')
    err.status  = 404
    next(err)
    return

  app.use(catch_404_handler)
  app.use(error_handler)
  return

error_handler = (err, req, res, next) ->
  err_code = err.status || 500
  err_view = get_err_view(err_code)
  res.locals.is_error = true
  res.status(err_code)

  # development error handler
  # print stacktrace
  data =
    message: if err_code isnt 404 then get_err_message(err.message) else 'Page Not Found'
    error: err
    isDev: nodame.isDev()

  # production error handler
  # no stacktraces leaked to user
  unless nodame.isDev()
    data.error =
      status: err_code

  # log critical
  if err_code >= 500
    log.critical(err_code, data.message)
  else
    log.info(err_code, data.message)

  # datadog
  app_name = nodame.config('logger.clients.datadog.app_name')
  log.stat.increment("#{app_name}.errors", ["env:#{nodame.env()}", "status:#{err_code}"])

  render = new Render(req, res)
  render.cache "error:#{err_view}", true, (err, is_cache) ->
    unless is_cache
      render.set('data', data)
      render.path("errors/#{err_view}")
      render.send()
    return undefined
  return undefined

get_err_message = (message) ->
  return "#{message}\n#{getStackTrace()}"

# check later whether this is a recursive func
getStackTrace = () ->
  obj = {}
  Error.captureStackTrace(obj, getStackTrace)
  return obj.stack

get_err_view = (err_code) ->
    errors = [404, 500, 503]
    return if errors.indexOf(err_code) < 0 then '500' else String(err_code)

module.exports = errors
