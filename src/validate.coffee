validate = require 'validate.js'

validate.isDefinedAll = () ->
  if arguments.length > 0
    for i of arguments
      return false unless arguments[i]?
    return true
  false

validate.isEmptyValue = (obj, value) ->
  if validate.isEmpty obj
    return value
  obj

validate.isMatch = (value, regex) ->
  found = value.match regex
  !validate.isEmpty found

module.exports = validate
