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

class Session
  ###
  # @constructor
  ###
  constructor: ->
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
    # Get storage engine
    storage = SESSION.storage
    # Check if storage engine is enable
    unless CACHE.clients[storage]?
      throw new Error "Session storage engine '#{storage}' in not enabled"
    # Assign client configuration
    client = CACHE.clients[storage]
    # Assign map
    map = SESSION.storage_map
    # Check if map exists
    unless not client.enable and client.map?[map]?
      throw new Error "Map 'session' doesn't exist in #{storage} config"
    # Assign shard
    shard = client.map[map]
    # Check if dhard exists
    unless client[shard]?
      throw new Error "Shard #{shard} doesn't exist in #{storage} config"
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
  middleware: (req, res, next) =>
    # Check if session is enabled
    unless @_is_enable()
      return next() if next?
      return

    @_req = req
    @_res = res

    @_path = @_req.path
    if @_path?
      @_path = @_path.split('/')
      if @_path[1]?
        @_path = @_path[1]
        # Set no path to defaul
        @_path = MODULES.default if @_path is ''
        # Validate if path is module
        if MODULES.items[@_path]?
          @_mod = MODULES.items[@_path]
          # Check if this was called from router
          if next?
            # Evaluate session
            @_evaluate_session()
            @_generate_redis_key()
            # Evaluate access
            unless @_evaluate_access()
              switch MODULES.forbidden
                when 'redirect'
                  @_res.redirect("#{URL.base}/#{MODULES.default}")
                else
                  html = HTML.new(@_req, @_res)
                  html.render
                    module: 'errors'
                    file: MODULES.forbidden
              return

    return next() if next?
    return
  ###
  # @method Evaluate existence of session
  # @private
  ###
  _evaluate_session: ->
    if @_is_live()
      @_req.is_auth         = true
      @_res.locals.is_auth  = true
    else
      @_req.is_auth         = false
      @_res.locals.is_auth  = false

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
      if @_mod.auth_only and not @_req.is_auth
        # Return revoke access
        return false
      # Validate guest only access
      if @_mod.guest_only and @_req.is_auth
        # Return revoke access
        return false
    # Return permit access
    return true
  ###
  # @method Check session existence
  # @private
  # @return bool
  ###
  _is_live: ->
    # Return whether session cookie does exist
    return @_req.signedCookies[@_key]?
  ###
  # @method Generate session id
  # @private
  # @param  object  session
  # @return string
  ###
  _generate_session_id: (session) ->
    session_id = Hash.sha384("#{session}:#{COOKIE.secret}")
    return session_id
  ###
  # @method Generate redis key
  # @private
  # @return string
  ###
  _generate_redis_key: ->
    @_redis_key = "#{@_identifier}-"
    return
  ###
  # @method Get session id
  # @public
  # @return string
  ###
  get_session_id: ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Return session id
    return @_req.signedCookies[@_key]
  ###
  # @method Establish new session
  # @public
  # @param  object
  ###
  set: (session, callback) ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Set session and cookie
    session_id = @_generate_session_id(session)
    @_res.cookie(@_key, session_id, @_options)
    # TODO: Move to redis
    @_res.cookie('_tmp', session, @_options)
    callback(null, session_id)
    return
  ###
  # @method Destroy session
  # @public
  ###
  clear: ->
    # Check if session is enabled
    @_evaluate_session_enable()
    # Clear session and cookie
    @_res.clearCookie(@_key, @_option_domain)
    # TODO: Move to redis
    @_res.clearCookie('_tmp', @_option_domain)
    return
# Export module as new object
module.exports = Session
