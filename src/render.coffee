###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @author   Originally by Teddy Hong <teddy.hong11@gmail.com>
# @link     https://github.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/MIT
#
# @version  1.2.0
###

Path        = require('./path')
UUID        = require('node-uuid')
Redis       = require('./redis')
Async       = require('async')

APP         = nodame.config('app')
VIEW        = nodame.config('view')
COOKIE      = nodame.config('cookie')

class Render
  ###
  # @constructor
  ###
  constructor: (@req, @res) ->
    # Local variables
    @__locals = {}
    # Locales variable
    @__locals.locales = []
    # Set default page title
    @set('page_title', APP.title)
    # Set default file name
    @__file = 'index'
    # Cache data
    @__cache_data = false
    # Header sent
    @__sent = false
    return
  ###
  # @method Set local variable
  # @public
  # @param  string  key
  # @param  object  value
  ###
  set: (key, val, is_array = false) ->
    if is_array
      @__locals[key] = @__locals[key] ? []
      @__locals[key].push(val)
    else
      @__locals[key] = val
    return @
  ###
  # @method Set local variable
  # @public
  # @param  string  page title
  # @param  int     page number
  ###
  title: (title, page_num) ->
    separator     = APP.title_separator
    default_title = APP.title
    # TODO: change with i18n
    page_text     = 'Halaman'
    # Add separator
    title = "#{title} #{separator} #{default_title}"
    # Add page number if page exists
    title = "#{title}, #{page_text} #{page_num}" if page_num?
    # Assign title
    return @set('page_title', title)
  ###
  # @method Set menu
  # @public
  # @param  string  active menu
  ###
  menu: (active_menu) ->
    # Validate empty val
    throw new Error 'Missing active_menu args' unless active_menu?
    # Assign val
    return @set('active_menu', { active: active_menu })
  ###
  # @method Set assets name
  # @public
  # @param  string  assets name
  ###
  assets: (assets_name) ->
    # Validate empty val
    throw new Error 'Missing assets_name args' unless assets_name?
    # Assign val
    return @set('assets_name', assets_name)
  ###
  # @method Set locale
  # @public
  # @param  string  locale
  ###
  locale: (name) ->
    # Validate empty val
    throw new Erorr 'Missing locale args' unless name?
    # Validate value
    @__locals.locales.push(name) if @__locals.locales.indexOf(name) is -1
    return @
  ###
  # @method Set locales
  # @public
  # @param  object  locales
  ###
  locales: (locales) ->
    # Validate empty val
    throw new Erorr 'Missing locales args' unless locales?
    # Check if is array
    if typeof locales is 'object'
      @locale(name) for name in locales
    else
      @locale(locales)
    return @
  ###
  # @method Set module name
  # @public
  # @param  string  method name
  ###
  module: (@__module) ->
    # Validate empty val
    throw new Error 'Missing module args' unless @__module?
    return @
  ###
  # @method Set file name
  # @public
  # @param  string  file name
  ###
  file: (@__file) ->
    # Validate empty val
    throw new Error 'Missing file args' unless @__file?
    return @
  ###
  # @method Set view path
  # @public
  # @param  string  path
  ###
  path: (path) ->
    # Validate empty val
    throw new Error 'Missing path args' unless path?
    # Assign variables
    default_template  = VIEW.default_template
    template          = VIEW.template
    device            = VIEW.default_device
    adaptive          = VIEW.adaptive
    # Set 'phone' and 'tablet' as 'mobile'
    # TODO: Set to switchable
    if @req.device?.type? and @req.device.type isnt 'desktop' and adaptive
      device = 'mobile'
    # Set template to default when empty
    template = default_template unless template?
    # Set module and file
    # Get view path
    @__view_path = Path.join(device, template, path)
    return @

  ###
  # @method set status code
  # @public
  # @param int status code
  ###
  code: (status_code) ->
    @res.status(status_code)
    return @

  ###
  # @method Cache view
  # @public
  # @param str key
  # @param obj value
  ###
  cache: (key = '', is_cache = true, callback) ->
    build_time= nodame.settings.build.time
    time      = Math.floor(Date.now() / 1000)
    purge_time= nodame.config('view.purge_time')
    time_diff = time - build_time
    is_purge  = time_diff < purge_time
    # Redis key
    redis_key = "#{APP.name}::render::#{key}"
    # Gatekeeper
    if !is_cache or is_purge or !nodame.config('view.cache')
      if is_purge and is_cache and nodame.config('view.cache')
        # Send cache key for re-caching
        @__cache_key = redis_key

      return callback(null, false)
    redis = Redis.client()
    redis_hash_key = "#{@req.device.type},#{@req.__device.type}"

    Async.waterfall [
      (cb) => redis.hget(redis_key, redis_hash_key, cb)
    ], (err, data) =>
      if data?
        @__cache_data = data.toString()
        return callback(null, true)
      # Send cache key for re-caching
      @__cache_key = redis_key
      return callback(null, false)
    return

  ###
  # @method write JSON response
  # @public
  # @param  str JSON
  ###
  json: (obj) ->
    # Block if header is sent
    if @__sent
      @res.end()
      return undefined
    # Convert object to string
    obj = JSON.stringify(obj) unless typeof obj is 'string'
    # Cache to Redis
    @__cache(obj)
    # Set header
    @res.set('Content-Type: application/json')
    # Set header sent status to true
    @__sent = true
    @res.send(obj)
    return undefined

  ###
  # @method write response
  # @public
  ###
  send: (callback) ->
    app = require('./app')
    app.locals.nodame.assets._device = @req.device.type
    # Block if header is sent
    return @res.end() if @__sent
    # Asynchronously check interstitial
    Async.series [
      (cb) => @__check_interstitial(cb)
    ], (err, data) =>
      @res.clearCookie 'fm',
        domain: ".#{COOKIE.domain}"
      # Check if cache
      if @__cache_data
        @res.send(@__cache_data)
        return @res.end()
      # Throw error if path is not found
      unless @__view_path?
        @res.send('View path is undefined. Please report to us.')
        return @res.end()
      # Set header sent status to true
      @__sent = true
      # Render cache
      Async.waterfall [
        (cb) => @res.render(@__view_path, @__locals, cb)
      ], (__err, html) =>
        # Cache to redis
        @__cache(html)
        # Check if callback
        return callback(__err, html) if callback?
        # Otherwise just send the html to client
        @res.send(html)
        return @res.end()
      return
    return

  ###
  # @method cache to redis
  # @private
  # @params obj Object
  ###
  __cache: (obj) ->
    if @__cache_key
      # Set cache
      redis = Redis.client()
      redis.hmset(@__cache_key, "#{@req.device.type},#{@req.__device.type}", obj)
      # TODO: Get this works!
      redis.expire(@__cache_key, nodame.config('view.cache_time'))
    return undefined

  ###
  # @method Pass interstitial view
  # @public
  # @param str key
  # @param obj value
  ###
  interstitial: (key, val, url) ->
    fm = @req.cookies.fm

    unless fm
      fm = UUID.v4()
      @res.cookie 'fm', fm,
        domain: ".#{COOKIE.domain}"
        expires: new Date(Date.now() + 600000)
        httpOnly: true

    redis = Redis.client()
    keyFm = "#{APP.name}:flashMessages:#{fm}"

    redis.set(keyFm, JSON.stringify({type:key,text:val}))
    redis.expire(keyFm, 600)

    @res.redirect(url)
    return undefined

  ###
  # @method Check interstitial
  # @private
  # @param callback
  ###
  __check_interstitial: (cb) ->
    try
      fm = @req.cookies.fm

      redis = Redis.client()
      keyFm = "#{APP.name}:flashMessages:#{fm}"
      redis.get keyFm, (err, reply) =>
        if reply
           redis.del(keyFm)
           reply = JSON.parse(reply)
           @message(reply.type, reply.text)
        cb(null)
        return
    catch e
      cb(e)
      console.log(e)
    return

  ###
  # @method Pass message
  # @public
  # @param str key
  # @param obj value
  ###
  message: (key, val) ->
    messages =
      type: key
      text: val
    @set('messages', messages, true)
    return undefined
  ###
  # @method Render 404
  # @public
  ###
  error_404: ->
    @path('errors/404')
    return @send()

module.exports = Render
