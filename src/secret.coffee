sha384 = require('js-sha512').sha384

exports.getHash = (type, id) ->
  secretKey = nodame.config('secret_key')
  return sha384("#{secretKey[type]}###{id}")
