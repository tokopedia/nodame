###
# @author  Argi Karunia <arugikaru@yahoo.co.jp>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class Strings
  _trim: (str, middle) ->
    str = str.replace(/[ ]+/g, ' ')
    if middle
      str = str.replace(/^[ ]+|[ ]+$/g, '')
    return str

  trim: (data, middle) ->
    if typeof data is 'object'
      dataIsArray = Object.prototype.toString.call(data) is '[object Array]'
      temp = if dataIsArray then [] else {}
      for key of data
        if data.hasOwnProperty key
          dataIsString = typeof data[key] is 'string'

          if dataIsString
            _tmp = @_trim(data[key], middle)
          else
            _tmp = data[key]

          if dataIsString
            if dataIsArray then temp.push _tmp
            else temp[key] = _tmp
          else
            if dataIsArray then temp.push _tmp
            else temp[key] = _tmp
      return temp
    else
      if typeof data is 'string'
        return @_trim(data, middle)
      else
        return data

module.exports = new Strings()
