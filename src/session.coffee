###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @link     https://gihtub.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/maintenance
#
# @version  1.2.0
###

# CONFIGS
SESSION = nodame.config('session')
CACHE   = nodame.config('cache')
COOKIE  = nodame.config('cookie')
MODULES = nodame.config('module')
ASSETS  = nodame.config('assets')
URL     = nodame.config('url')
APP     = nodame.config('app')
# MODULES
HTML    = require('./html')
Hash    = require('js-sha512')
Redis   = require('./redis')
Async   = require('async')

class Session
  ###
  # @constructor
  ###
  constructor: (req, res) ->
    @_key = SESSION.key
    @_identifier = "#{APP.name}/session"
    @_domain = ".#{COOKIE.domain}"
    @_options =
      domain  : @_domain
      httpOnly: true
      expires : new Date(Date.now() + SESSION.expires * 1000)
      signed  : true
    @_option_domain =
      domain  : @_domain
    
    if req? and res?
      @middleware(req, res)

    return
  ###
  # @method Check if session is enabled and ready
  # @throw  Error if not ready
  # @return bool
  ### 
  _is_enable: ->
    # Check if session is enable in configuration
    unless SESSION.enable
      return false
    # Get db engine
    db_server = CACHE.db_server
    # Check if db engine is enable
    unless CACHE.db[db_server].enable
      throw new Error "#{db_server} is not enabled"
    # Assign client configuration
    client = CACHE.db[db_server]
    # Check host and port configuration
    if not client.host? or not client.port?
      throw new Error "Missing host or port config for #{db_server}"
    # Session is enable
    return true
  ###
  # @method Evaluate if session is enabled
  # @private
  # @throw  error if session method is used when disabled
  ###
  _evaluate_session_enable: ->
    unless @_is_enable()
      throw new Error "You are using session method while \
      session isn't enabled by config"
    return
  ###
  # @method Register middleware function
  # @public
  # @param  object  request object
  # @param  object  response object
  # @param  object  optional  next object
  ###
  middleware: (@req, @res, next) =>
    # NOTE: CHECKPOINT
    # Check if session is enabled
    unless @_is_enable()
      return next() if next?
      return
    # Return if this wasn't requested from router
    return unless next?
    # NOTE: CHECKPOINT
    # Check if path exists
    return next() unless @req.path?
    # Assign paths from req.path
    @__paths = @req.path.split('/')
    # NOTE: CHECKPOINT
    # Check if route exists
    return next() unless @__paths[1]?
    # Set path depends on whether path is root
    path_idx = if "/#{@__paths[1]}" is MODULES.root then 2 else 1
    # Assign path
    @__path = @__paths[path_idx] || ''
    # Get real path for ajax
    # TODO: Add config to disable session on xhr
    @__path = @__paths[path_idx + 1] || '' if @__path is 'ajax'
    # Set no path to default
    @__path = MODULES.default if @__path is ''
    # NOTE: CHECKPOINT
    # Validate if path is module
    return next() unless MODULES.items[@__path]?
    # Assign module
    @_mod = MODULES.items[@__path]
    # Get redis key
    redis_key = @_get_redis_key()
    # Get redis client
    redis = Redis.client()
    # Get redis value
    redis.get redis_key, (err, reply) =>
      # Validate error
      unless err?
        # Validate reply
        if reply?
          # Parse reply
          session = JSON.parse(reply)
      # Evaluate and register session
      @_evaluate_session(session)
      # Evaluate access
      unless @_evaluate_access()
        # Unauthorized access goes here
        switch MODULES.forbidden
          # Forbidden type is 'redirect'
          when 'redirect'
            @res.redirect("#{URL.base}/#{MODULES.default}")
          # Default, return error page
          else
            html = HTML.new(@req, @res)
            html.render
              module: 'errors'
              file: MODULES.forbidden
        return undefined
      return next()
    return
  ###
  # @method Evaluate existence of session
  # @private
  ###
  _evaluate_session: (session) ->
    # Check if session is alive
    if @_is_alive()
      # Register session
      @_register_session(session)
      return
    # Session isn't alive
    # Unregister session
    @_register_session()
    return
  ###
  # @method Register session to environment
  # @private
  ###
  _register_session: (session) ->
    # Register session
    if session?
      @req.session         = session
      @res.locals.session  = session
      @req.is_auth         = true
      @res.locals.is_auth  = true
    # Unregister session
    else
      @req.session         = {}
      @res.locals.session  = {}
      @req.is_auth         = false
      @res.locals.is_auth  = false
    return
  ###
  # @method Evaluate access
  # @private
  # @return bool
  ###
  _evaluate_access: ->
    # Validate access if it's set in config
    if @_mod.auth_only or @_mod.guest_only
      # Validate auth only access
      if @_mod.auth_only and not @req.is_auth
        # Return revoke access
        return false
      # Validate guest only access
      if @_mod.guest_only and @req.is_auth
        # Return revoke access
        return false
    # Return permit access
    return true
  ###
  # @method Check session existence
  # @private
  # @return bool
  ###
  _is_alive: ->
    # Return whether session cookie does exist
    return @req.signedCookies[@_key]?
  ###
  # @method Generate session id
  # @private
  # @param  object  session
  # @return string
  ###
  _generate_session_id: (session) ->
    # TODO: Validate session_id
    session_id = Hash.sha384("#{JSON.stringify(session)}:#{COOKIE.secret}:#{new Date()}")
    return session_id
  ###
  # @method Generate redis key
  # @private
  # @return string
  ###
  _generate_redis_key: (session_id) ->
    return "#{@_identifier}-#{session_id}"
  ###
  # @method Get session id
  # @public
  # @return string
  ###
  get_session_id: ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Return session id
    return @req.signedCookies[@_key]
  ###
  # @method Establish new session
  # @public
  # @param  object
  ###
  set: (session, callback) ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Set session id
    session_id = @_generate_session_id(session)
    # Set redis key
    redis_key = @_generate_redis_key(session_id)
    # Set session and cookie
    @res.cookie(@_key, session_id, @_options)
    # Set to redis
    redis = Redis.client()
    redis.expire(redis_key, SESSION.expires)
    redis.set [redis_key, JSON.stringify(session)], (err, result) ->
      # Validate result
      return callback(err, undefined) if err?
      # rReturn callback
      return callback(null, session_id)
    return
  ###
  # @method Get redis Keys
  # @private
  # @return string redis_key
  ###
  _get_redis_key: ->
    # Get session id
    session_id = @get_session_id()
    # Return redis key
    return @_generate_redis_key(session_id)
  ###
  # @method Get session
  # @public
  # @return callback session
  ###
  get: (callback) ->
    redis_key = @_get_redis_key()
    redis = Redis.client()
    redis.get redis_key, (err, reply) ->
      callback(err, reply)
      return undefined
    return
  ###
  # @method Destroy session
  # @public
  ###
  clear: ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Get redis key
    redis_key = @_get_redis_key()
    # Clear session and cookie
    @res.clearCookie(@_key, @_option_domain)
    # Clear redis key
    redis = Redis.client()
    redis.del(redis_key)
    return
# Export module as new object
module.exports = Session
