redis       = require('redis')
REDIS       = nodame.config('cache.db.redis')

class RedisClient
  constructor: ->
    @_client = undefined
    return

  client: ->
    unless @_client?
      @_client = redis.createClient(REDIS.port, REDIS.host, {})
      @_client.on('error', @_errorHandler)
    return @_client

  _errorHandler: (err) ->
    console.log "Error Redis #{err}"

module.exports = new RedisClient()
