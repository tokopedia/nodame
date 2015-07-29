###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

path    = require('./path')
toml    = require('./toml')
json    = require('./json')
fs      = require('fs')

class Config
  _keys   : ['module', 'menu']
  _MODULE : 0
  _MENU   : 1
  config  : {}
  configPath : ''

  constructor: (argv, appPath = '') ->
    @_argv = argv
    @_path = appPath
    @configPath = @_getPath()
    configFile = fs.readFileSync @configPath
    @config = toml.parse configFile
    @_assignDefault @config
    toml.parseVar @config
    return

  _getPath: ->
    stream = path.safe "#{@_path}/configs/main.toml"

    # Throw if argv is not set
    throw 'nodame/config requires nodame/argv to be ran first.' unless @_argv?

    if @_argv.config?
      unless @_argv.config.substring(0, 1) is '/'
        stream = path.safe "#{@_path}/#{@_argv.config}"
      else
        stream = path.safe @_argv.config
    return stream

  _getDefaultConfig: ->
    cfgPath = path.join(__dirname, 'config.json')
    return require(cfgPath)

  _assignDefault: ->
    defCfg = @_getDefaultConfig()
    @_pairConfigs defCfg, @config
    @_assignDefaultMod defCfg, @config, @_MODULE
    @_assignDefaultMod defCfg, @config, @_MENU
    return

  _pairConfigs: (obj1, obj2) ->
    for prop of obj1
      if typeof obj1[prop] is 'object'
        unless prop is '__default'
          unless obj2[prop]?
            obj2[prop] = obj1[prop]
          else
            @_pairConfigs obj1[prop], obj2[prop]
      else
        obj2[prop] = obj1[prop] unless obj2[prop]?
    return

  _assignDefaultMod: (obj1, obj2, key) ->
    key = @_keys[key]
    defObj = obj1[key].items.__default

    for item of obj2[key].items
      for prop of defObj
        unless obj2[key].items[item][prop]?
          if prop is 'font_icon'
            val = item
          else
            val = defObj[prop]
          obj2[key].items[item][prop] = val
    return

module.exports = Config
