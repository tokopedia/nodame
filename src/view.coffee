Path = require('./path')
Swig = require('swig')

class View
  constructor: (app) ->
    if app?
      engine = 'html'
      dir = 'views'
      cache = !nodame.isDev()
      app.engine('html', Swig.renderFile)
      app.set('views', Path.safe(dir))
      app.set('view engine', engine)

      if cache
        Swig.setDefaults {locals: @_locals}
      else
        app.set('view cache', cache)
        Swig.setDefaults {locals: @_locals, cache: cache}

      Swig.setFilter('push', @_filterPush)
      Swig.setFilter('range', @_filterRange)
      Swig.setFilter('even', @_filterEven)

    return

  _locals:
    currentYear: (new Date()).getFullYear()
    is_dev: nodame.isDev()
    menu: nodame.config('menu')

  path: (req, moduleName, file) ->
    template = nodame.config('view.default_template')
    device = 'desktop'
    mobile = nodame.config('view.adaptive')

    if req?.device?.type? and req.device.type is 'phone' and mobile
      device = 'mobile'

    Path.join device, template, moduleName, file

  _filterPush: (input, val) ->
    input.push val
    return input

  _filterRange: (input, start, end, step = 1) ->
    throw TypeError 'Step cannot be zero' if step is 0
    throw TypeError 'Start and end must be defined' unless start? or end?
    step = -step if end < start

    switch typeof start
      when 'number'
        return (x for x in [start..end] by step)
      when 'string'
        throw TypeError "Only support byte. start = #{start}, end = #{end}" unless start.length is 1 or end.length is 1
        start = start.charCodeAt(0)
        end   = end.charCodeAt(0)
        return (String.fromCharCode(x) for x in [start..end] by step)
      else
        throw TypeError 'Only support byte and number'
        return

  _filterEven: (input) ->
    return input % 2 is 0

module.exports = View
