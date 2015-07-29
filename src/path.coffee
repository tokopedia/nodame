###
# @author  Argi Karunia <arugikaru@yahoo.co.jp>
# @author  Originally by nodejs.org
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

os        = require('os')
isNix     = os.platform != 'win32'
Path      = require('path')
Path.sys  = Path.join __dirname, '..'
Path.app  = Path.join Path.sys, '..', '..'

Path.safe = (pathString) ->
    get = ->
      pathString = Path.normalize pathString
      pathString = Path.normalize (Path.app + Path.sep + pathString) if !Path.isAbsolute pathString

      return pathString if isNix

      _path = pathString.split Path.sep
      parse _path
      Path.normalize _path

    parse = (arr) ->
      return if typeof arr != 'object'

      if arr.length > 1
        arr[1] = Path.join arr[0], arr[1]
        arr.shift()

        return parse arr if arr.length > 1

        Path.sep + arr[0]

    get()

module.exports = Path
