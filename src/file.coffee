###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

sha512  = require('js-sha512').sha512;
fs      = require('fs')
path    = require('./path')
YAMLParser = require('js-yaml')
toml    = require('./toml')

class File
  readJSON: (filepath) ->
    return unless fs.statSync filepath
    JSON.parse fs.readFileSync(filepath)

  readGRUNT: (filepath) ->
    json      = @readYAML filepath
    confDir   = path.dirname filepath
    config    = @readYAML "#{confDir}/main.yaml"
    assetsDir = path.safe "#{path.app}/assets"

    if config.assets.dir?
      assetsDir =
        if config.assets.dir.substr(0, 1) is '/' then config.assets.dir
        else path.safe "#{path.app}/#{config.assets.dir}"

    grunt = {}
    typeDir =
      css: 'css'
      js: 'scripts'

    for groups of json
      for group of json[groups]
        for type of json[groups][group]
          grunt[type] = [] unless grunt[type]?

          baseName = "#{groups}.#{group}"
          hash = @_hash "#{baseName}#{type}", 8
          dest = "#{baseName}.min.#{hash}.#{type}"
          destSrc = {}
          destSrc[dest] = []
          baseDir = ''

          if json[groups][group][type].length > 0
            for j of json[groups][group][type]
              filename = json[groups][group][type][j]

              if filename?
                _filepath = "#{baseDir}#{json[groups][group][type][j]}"
                destSrc[dest].push _filepath
            grunt[type].push destSrc
    grunt

  _hash: (str, len) ->
    hash = sha512 "#{str}#{new Date()}"

    if len? and len < hash.length
      lenMed = Math.floor hash.length / 2
      start = if len < lenMed then lenMed - (Math.floor len / 2) else 0
      hash = hash.substr start, len
    hash

  readYAML: (filepath) ->
    return unless fs.statSync filepath
    YAMLParser.safeLoad(fs.readFileSync(filepath))

module.exports = new File()
