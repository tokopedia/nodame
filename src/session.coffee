###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @link     https://gihtub.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/maintenance
#
# @version  1.2.0
###

SESSION = nodame.config('session')
COOKIE  = nodame.config('cookie')
MODULES = nodame.config('module')
ASSETS  = nodame.config('assets')
URL     = nodame.config('url')
HTML    = nodame.require('nodame/html')

class Session
  constructor: ->
    @_key = SESSION.key
    @_domain = ".#{COOKIE.domain}"
    @_options =
      domain  : @_domain
      httpOnly: true
      expires : new Date(Date.now() + SESSION.expires * 1000)
      signed  : true
    @_option_domain =
      domain  : @_domain

    return

  # Register middleware function
  middleware: (req, res, next) =>
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
            @evaluate_session()
            # Evaluate access
            unless @evaluate_access()
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

  # Evaluate existence of session
  evaluate_session: ->
    if @is_live()
      @_req.is_auth         = true
      @_res.locals.is_auth  = true
    else
      @_req.is_auth         = false
      @_res.locals.is_auth  = false

    return

  # Evaluate access
  evaluate_access: ->
    access = true
    # Validate access
    if @_mod.auth_only or @_mod.guest_only
      if @_mod.auth_only and not @_req.is_auth
        access = false
      if @_mod.guest_only and @_req.guest_only
        access = false

    return access

  # Check whether session is live
  # TODO: Better validation
  is_live: -> @_req.signedCookies[@_key]?

  # Establish new session
  create: (session) ->
    console.log 'CREATE'
    @_res.cookie(@_key, session, @_options)
    return

  # Destroy session
  clear: ->
    console.log 'CLEAR'
    @_res.clearCookie(@_key, @_option_domain)
    return

module.exports = new Session()
