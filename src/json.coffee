###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
# 
# @version 1.0.0
###

class JSON
  read: (obj, params) ->
    throw ReferenceError 'obj is undefined' unless obj?
    throw ReferenceError 'params is undefined' unless params?

    if typeof params is 'string'
      params = params.split('.')
    if params.length is 0
      return obj
    if params.length > 1
      obj = obj[params[0]]
      params.shift()
      @read obj, params
    else
      obj = obj[params[0]]
      obj

module.exports = new JSON()
