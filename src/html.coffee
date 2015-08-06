###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @author   Originally by Teddy Hong <teddy.hong11@gmail.com>
# @link     https://github.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/MIT
#
# @version  1.0.0
###

Path = require('./path')
View = require('./view')
UUID = require('node-uuid')
md5  = require('md5')
ParseDuration = require('parse-duration')
Redis = require('./redis')

view = new View()

COOKIE = nodame.config('cookie')

HTML = {}

HTML.new = (req, res) =>
  stash =
    _stash: {}

    _get: (obj, params) ->
      return obj if params.length is 0

      if params.length > 1
        obj = obj[params[0]]
        params.shift()
        return @_get(obj, params)
      else
        obj = obj[params[0]]
        return obj

    set: (key, value) ->
      @_stash[key] = value if key?
      return

    get: (params) ->
      params = params.split('.')
      return @_get(@_stash, params)

  _init_head = ->
    unless stash.get('headTitle')
      stash.set('headTitle', nodame.config('app.title'))

    unless stash.get('headDescription')
      stash.set('headTitle', nodame.config('app.desc'))

    # Refback
    if res?.locals?.refback?
      stash.set('refback', res.locals.refback)

    unless stash.get('refback')?
      stash.set('refback', nodame.config('url.base'))

    return

  assetsName = (key) ->
    stash.set('assetsName', key)
    return

  showDrawer = (activeMenu) ->
    stash.set('showMenu', { active: activeMenu })
    return

  showRefback = (title, refback) ->
    stash.set('refback', refback)
    stash.set('refbackTitle', title)
    return

  headTitle = (title, page) ->
    default_title = nodame.config('app.title')
    separator = nodame.config('app.title_separator')
    # TODO: change with i18n
    page_text = 'Halaman'

    if title?.toLowerCase() is default_title
      head_title = default_title
    else
      head_title = "#{title} #{separator} #{default_title}"

      if page?
        head_title = "#{head_title}, #{page_text} #{page}"

    stash.set('headTitle', head_title)
    return

  headDescription = (desc) ->
    stash.set('headDescription', desc)
    return

  setMessages = (type, text) ->
    messages = stash.get('messages') ? []
    messages.push
      type: type
      text: text

    stash.set('messages', messages)
    return

  setFlashMessages = (type, text) ->
    fm = req.cookies.fm

    unless fm
      fm = UUID.v4()
      res.cookie 'fm', fm,
        domain: ".#{COOKIE.domain}"
        expires: new Date(Date.now() + 600000)
        httpOnly: true

    redisClient = Redis.getClient('session', 'master', 1)
    keyFm = "flashMessages:#{fm}"

    redisClient.rpush(keyFm, JSON.stringify({type:type,text:text}))
    redisClient.expire(keyFm, 600)

  _init_flash_message = (cb) ->
    if req?.cookies?
      fm = req.cookies.fm

      if fm
        redisClient = Redis.getClient('session', 'slave', 1)

        keyFm = "flashMessages:#{fm}"

        redisClient.lrange keyFm, 0, -1,
          (err, reply) ->
            if reply
              for reply_message in reply
                msg = JSON.parse(reply_message)
                setMessages(msg.type, msg.text)

              redisClient.del(keyFm)

              res.clearCookie 'fm',
                domain: ".#{COOKIE.domain}"

            cb()
      else
        cb()
    else
      cb()

  render = (args) ->
    flash_message_cb = ->
      _init_head()
      view_path = view.path(req, args.module, args.file)

      res.render view_path, stash._stash,
        (err, html) ->
          if err?
            log.emergency('Fatal error in parsing view', err.stack)
            res.send("Cannot find or parse view #{view_path}")
          else
            if args.cache
              key = ''
              redisClient = Redis.getClient('html', 'master', 1)
              hostname = nodame.config('url.hostname')
              uri = req.originaUrl
              url = Path.normalize("#{hostname}#{uri}")

              if args.key?
                key = args.key

              keyRedis = "html:#{md5(url + key)}"
              redisClient.hset keyRedis, req.device.type, html,
                (err, reply) ->
                  if err?
                    console.log 'hset render err', err
                  else
                    redisClient.expire(keyRedis, ParseDuration(args.cache) / 1000)
            res.send(html)
            return

    _init_flash_message(flash_message_cb)
    return

  renderCache = (key, cb) ->
    redisClient = Redis.getClient('html', 'slave', 1)
    hostname = nodame.config('url.hostname')
    uri = req.originaUrl
    url = Path.normalize("#{hostname}#{uri}")

    key = '' unless key?

    keyRedis = "html:#{md5(url + key)}"

    build_time = nodame.settings.build.time
    time = Math.floor(Date.now() / 1000)
    purge_time = nodame.config('view.purge_time')
    time_diff = time - build_time
    is_purge = time_diff < purge_time

    if nodame.config('view.cache')
      if is_purge
        cb(false)
      else
        redisClient.hget keyRedis, req.device.type,
          (err, reply) ->
            if reply?
              res.send(reply.toString())
              cb(true)
            else
              cb(false)
    return

  locales = (locales) ->
    stash.set('locales', locales)
    return


  stash: stash
  assetsName: assetsName
  showDrawer: showDrawer
  showRefback: showRefback
  headTitle: headTitle
  headDescription: headDescription
  setMessages: setMessages
  setFlashMessages: setFlashMessages
  locales: locales
  render: render
  renderCache: renderCache
  req: req
  res: res

module.exports = HTML
