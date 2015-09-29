###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 2.0.0
###

path    = require('./path')
Parser  = require('./parser')
YAMLParser = require('js-yaml')
fs      = require('fs')

class Config
  _keys   : ['module', 'menu']
  _MODULE : 0
  _MENU   : 1
  config  : {}
  config_path : ''

  constructor: (argv, appPath = '') ->
    @_argv = argv
    @_path = appPath
    @config_path = @_get_path()
    config_file = fs.readFileSync(@config_path)
    @config = YAMLParser.safeLoad(config_file)
    @_assign_default(@config)
    Parser.parse_var(@config)
    return

  _get_path: ->
    stream = path.safe("#{@_path}/configs/main.yaml")

    # Throw if argv is not set
    throw 'nodame/config requires nodame/argv to be ran first.' unless @_argv?

    if @_argv.config?
      unless @_argv.config.substring(0, 1) is '/'
        stream = path.safe("#{@_path}/#{@_argv.config}")
      else
        stream = path.safe(@_argv.config)
    return stream

  _get_default_config: ->
    cfgPath = path.join(__dirname, 'config.json')
    return require(cfgPath)

  _assign_default: ->
    defCfg = @_get_default_config()
    @_pair_config(defCfg, @config)
    @_assign_default_mod(defCfg, @config, @_MODULE)
    @_assign_default_mod(defCfg, @config, @_MENU)
    return

  _pair_config: (obj1, obj2) ->
    for prop of obj1
      if typeof obj1[prop] is 'object'
        unless prop is '__default'
          unless obj2[prop]?
            obj2[prop] = obj1[prop]
          else
            @_pair_config(obj1[prop], obj2[prop])
      else
        obj2[prop] = obj1[prop] unless obj2[prop]?
    return

  _assign_default_mod: (obj1, obj2, key) ->
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
