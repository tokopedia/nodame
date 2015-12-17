###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

Path         = require('./path')

# TODO: Optimize the assets variable!
# So pricey!

class Assets
  start = 0
  constructor: (opt) ->
    @_DESKTOP = 'desktop'
    @_MOBILE  = 'mobile'
    @_CSS     = 'css'
    @_JS      = 'js'
    @_type    = @_CSS
    @_module  = undefined
    @_appPath = opt.appPath
    @_isDev   = opt.isDev
    @_url     = opt.url
    @_assets  = opt.assets
    @_dir     = opt.dir
    @_device  = if nodame.config('view.adaptive') then opt.device else 'desktop'
    
  css : (mod) -> @_get_assets(@_CSS, mod)
  js  : (mod) -> @_get_assets(@_JS, mod)

  _get_assets: (type, mod) ->
    start = new Date()
    @_device = @_MOBILE unless @_device is @_DESKTOP
    @_type = type
    @_module = mod
    assets = []
    # global assets
    assetsName = @_get_valid_name('global')
    assets.push @_html(assetsName)
    # local assets
    assetsName = @_get_valid_name(@_module)
    assets.push @_html(assetsName) if assetsName?

    return assets.join('')

  _get_valid_name: (mod) ->
    type = @_type
    name = @_get_name(mod).replace(/[.][a-z]+$/gi, '')
    re = new RegExp(name, 'gi')

    for i of @_assets[type]
      for _name of @_assets[type][i]
        return _name if _name.match(re)

    return

  _get_config_dir: ->
    confDir = @_dir

    if confDir.substr(0, 1) is '/'
      confDir = confDir
    else
      confDir = Path.safe("#{@_appPath}/#{confDir}")

    return confDir

  _get_name: (mod) -> "#{@_device}.#{mod}.min.#{@_type}"

  _html: (name) ->
    data = @_assets[@_type]
    _html = []

    if @_isDev
      for i of data
        if data[i][name]?
          for j of data[i][name]
            filepath = data[i][name][j]
            _html.push @_html_tag(@_type, filepath)
    else
      _html.push @_html_tag(@_type, name)

    end = new Date() - start

    split_filename = name.split('.')
    device = split_filename[0]
    module = split_filename[1]
    app_name = nodame.config('logger.clients.datadog.app_name')
    log.stat.histogram "#{app_name}.assets.load_time", end, [
      'env:' + nodame.env()
      'filename:' + name
      'type:' + @_type
      'device:' + device
      'module:' + module
    ]

    return _html.join('')

  _html_tag: (type, filepath) ->
    configDir = @_get_config_dir()
    typeDir   = if @_isDev then @_type else 'min'
    filepath  = "#{@_url}/#{typeDir}/#{filepath}"

    switch type
      when @_CSS
        _html = "<link href=\"#{filepath}\" type=\"text/css\" rel=\"stylesheet\">"
      when @_JS
        _html = "<script src=\"#{filepath}\" type=\"text/javascript\"></script>"

    return _html

module.exports = Assets
