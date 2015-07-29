toml   = require('toml')
json   = require('./json')
parse  = toml.parse
object = {}

_parseVar = (obj, str) ->
  found = str.match /\{{2} *[a-z0-9._]+ *\}{2}/gi

  if found?
    for i of found
      search = found[i]
      params = search.match /[a-z0-9._]+/i
      return str unless params?

      params = params[0]
      replace = json.read object, params
      str = str.replace search, replace
  str

_parseFunc = (str) ->
  found = str.match /(\(.+\|[a-z_]+\))/gi

  if found?
    for i of found
      search = found[i]
      vars = search.replace /[()]+/g, ''
      vars = vars.split '|'

      if vars[1] is 'url_encode'
        replace = encodeURIComponent vars[0]
        str = str.replace search, replace
  str

toml.parseVar = (obj, path = []) ->
  if typeof obj is 'object'
    for i of obj
      if typeof obj[i] is 'string'
        obj[i] = _parseVar obj, obj[i]
        obj[i] = _parseFunc obj[i]
      else
        _path = path.slice()
        _path.push i
        toml.parseVar obj[i], _path

toml.parse = (path) ->
  object = parse path

module.exports = toml
